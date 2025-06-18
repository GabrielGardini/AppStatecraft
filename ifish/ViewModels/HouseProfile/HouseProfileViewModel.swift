import Foundation
import CloudKit
import SwiftUI

@MainActor
class HouseProfileViewModel: ObservableObject {
    @Published var isLoggedInToiCloud = false
    @Published var usuarioJaVinculado = false
    @Published var nomeCasaUsuario = ""
    @Published var casaNomeInput = ""
    @Published var codigoConviteInput = ""
    @Published var houseModel: HouseModel?
    @Published var mostrarAlertaICloud = false

    func verificarConta() {
        CKContainer.default().accountStatus { status, _ in
            Task { @MainActor in
                switch status {
                case .available:
                    print("usuário logado no iCloud")
                    self.isLoggedInToiCloud = true
                    await self.verificarSeUsuarioJaTemCasa()
                default:
                    print("usuário não logado")
                    self.isLoggedInToiCloud = false
                    self.mostrarAlertaICloud = true
                }
            }
        }
    }

    func verificarSeUsuarioJaTemCasa() async {
        guard let userRecordID = try? await CKContainer.default().userRecordID() else { return }

        let predicate = NSPredicate(format: "UserID == %@", userRecordID.recordName)
        let query = CKQuery(recordType: "User", predicate: predicate)

        let results = await fetchRecords(matching: query)
        if let user = results.first,
           let ref = user["UserHouseID"] as? CKRecord.Reference {
            if let casaRecord = try? await CKContainer.default().publicCloudDatabase.record(for: ref.recordID) {
                let casa = HouseModel(record: casaRecord)
                self.houseModel = casa
                self.nomeCasaUsuario = casa.nome
                self.usuarioJaVinculado = true
            }
        }
    }

    func criarCasa() async {
        let granted = await pedirPermissaoDescoberta()
        guard granted else { return }

        let id = CKRecord.ID(recordName: UUID().uuidString)
        let nome = casaNomeInput
        let inviteCode = String(UUID().uuidString.prefix(6)).uppercased()
        let novaCasa = HouseModel(id: id, nome: nome, inviteCode: inviteCode)

        do {
            let savedRecord = try await CKContainer.default().publicCloudDatabase.save(novaCasa.toCKRecord())
            let savedModel = HouseModel(record: savedRecord)
            self.houseModel = savedModel
            await registrarUsuario(casa: savedModel)
        } catch {
            print("Erro ao criar casa: \(error)")
        }
    }

    func entrarComCodigoConvite() async -> Bool {
        print("➡️ Tentando entrar com código \(codigoConviteInput)")
        let predicate = NSPredicate(format: "InviteCode == %@", codigoConviteInput)
        let query = CKQuery(recordType: "Casa", predicate: predicate)

        let results = await fetchRecords(matching: query)
        if let casaRecord = results.first {
            let casa = HouseModel(record: casaRecord)
            self.houseModel = casa
            await registrarUsuario(casa: casa)
            return true
        } else {
            print("❌ Código de convite inválido")
            return false
        }
    }

    func registrarUsuario(casa: HouseModel) async {
        print("👤 Registrando usuário")
        guard let userRecordID = try? await CKContainer.default().userRecordID() else { return }
        let identity = try? await CKContainer.default().userIdentity(forUserRecordID: userRecordID)

        let nome: String
        if let components = identity?.nameComponents {
            nome = [components.givenName, components.familyName].compactMap { $0 }.joined(separator: " ")
        } else {
            nome = "Usuário Desconhecido"
        }

        let userRecord = CKRecord(recordType: "User")
        userRecord["UserID"] = userRecordID.recordName as CKRecordValue
        userRecord["FullName"] = nome as CKRecordValue
        userRecord["UserHouseID"] = CKRecord.Reference(recordID: casa.id, action: .none)

        do {
            _ = try await CKContainer.default().publicCloudDatabase.save(userRecord)

            await MainActor.run {
                self.usuarioJaVinculado = true
                self.nomeCasaUsuario = casa.nome
            }

        } catch {
            print("❌ Erro ao salvar usuário: \(error)")
        }
    }

    func pedirPermissaoDescoberta() async -> Bool {
        let status = try? await CKContainer.default().requestApplicationPermission([.userDiscoverability])
        return status == .granted
    }

    func fetchRecords(matching query: CKQuery) async -> [CKRecord] {
        await withCheckedContinuation { continuation in
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, _ in
                continuation.resume(returning: records ?? [])
            }
        }
    }
}
