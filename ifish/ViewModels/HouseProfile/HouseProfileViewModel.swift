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
    @Published var casaRecord: CKRecord?
    @Published var mostrarAlertaICloud = false

    func verificarConta() {
        CKContainer.default().accountStatus { status, _ in
            Task { @MainActor in
                switch status {
                case .available:
                    print("usuário logado no icloud")
                    self.isLoggedInToiCloud = true
                    await self.verificarSeUsuarioJaTemCasa()
                default:
                    print("usuario nao logado")
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
                self.casaRecord = casaRecord
                self.nomeCasaUsuario = casaRecord["Nome"] as? String ?? "Casa desconhecida"
                self.usuarioJaVinculado = true
            }
        }
    }

    func criarCasa() async {
        let granted = await pedirPermissaoDescoberta()
        guard granted else { return }

        let casa = CKRecord(recordType: "Casa")
        casa["Nome"] = casaNomeInput as CKRecordValue
        casa["InviteCode"] = UUID().uuidString.prefix(6).uppercased() as CKRecordValue

        do {
            let savedCasa = try await CKContainer.default().publicCloudDatabase.save(casa)
            self.casaRecord = savedCasa
            await registrarUsuario(casa: savedCasa)
        } catch {
            print("Erro ao criar casa: \(error)")
        }
    }

    func entrarComCodigoConvite() async {
        let predicate = NSPredicate(format: "InviteCode == %@", codigoConviteInput)
        let query = CKQuery(recordType: "Casa", predicate: predicate)

        let results = await fetchRecords(matching: query)
        if let casa = results.first {
            self.casaRecord = casa
            await registrarUsuario(casa: casa)
        } else {
            print("❌ Código de convite inválido")
        }
    }

    func registrarUsuario(casa: CKRecord) async {
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
        userRecord["UserHouseID"] = CKRecord.Reference(record: casa, action: .none)

        _ = try? await CKContainer.default().publicCloudDatabase.save(userRecord)
        self.usuarioJaVinculado = true
        self.nomeCasaUsuario = casa["Nome"] as? String ?? "Casa"
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
