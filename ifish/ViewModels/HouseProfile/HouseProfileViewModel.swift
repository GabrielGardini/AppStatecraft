import Foundation
import CloudKit
import SwiftUI

@MainActor
class HouseProfileViewModel: ObservableObject {
    @Published var usuarioAtual: UserModel?
    @Published var isLoggedInToiCloud = false
    @Published var usuarioJaVinculado = false
    @Published var nomeCasaUsuario = ""
    @Published var casaNomeInput = ""
    @Published var codigoConviteInput = ""
    @Published var houseModel: HouseModel?
    @Published var mostrarAlertaICloud = false
    @Published var usuariosDaCasa: [UserModel] = []

    func inicializarAppState(_ appState: AppState) async {
        await verificarConta()
        await verificarSeUsuarioJaTemCasa()

        do {
            let userRecordID = try await CKContainer.default().userRecordID()
            appState.userID = userRecordID
            print("✅ AppState.userID atribuído com: \(userRecordID.recordName)")
        } catch {
            print("❌ Erro ao obter userRecordID: \(error)")
        }

        if let usuario = self.usuarioAtual {
            appState.casaID = usuario.houseID
            print("✅ AppState.casaID atribuído com: \(usuario.houseID)")

        } else if let casaID = self.houseModel?.id {
            appState.casaID = casaID
            print("✅ AppState.casaID atribuído com: \(casaID)")
        }

        if appState.userID == nil {
            print("⚠️ AppState iniciado sem userID.")
        }
    }

    func nomeDoUsuario(id: CKRecord.ID) -> String {
        usuariosDaCasa.first(where: { $0.icloudToken == id })?.name ?? "Desconhecido"
    }

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
    
    func removerUsuarioPorID(_ id: CKRecord.ID) async {
        do {
            try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: id)
            print("✅ Usuário removido com sucesso.")

            // Atualiza a lista após a remoção
            await buscarUsuariosDaMinhaCasa()
        } catch {
            print("❌ Erro ao remover usuário: \(error.localizedDescription)")
        }
    }

    func sairDaCasa() async {
        guard let userRecordID = try? await CKContainer.default().userRecordID() else {
            print("❌ Não foi possível obter o userRecordID")
            return
        }

        // Buscar o registro correspondente na tabela "User"
        let predicate = NSPredicate(format: "UserID == %@", userRecordID.recordName)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let results = await fetchRecords(matching: query)

        guard let registroUsuario = results.first else {
            print("❌ Registro de usuário não encontrado")
            return
        }

        do {
            try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: registroUsuario.recordID)
            print("✅ Usuário removido da casa")

            // Resetar o estado local
            await MainActor.run {
                self.houseModel = nil
                self.usuarioJaVinculado = false
                self.nomeCasaUsuario = ""
                self.usuariosDaCasa = []
            }
            verificarConta()

        } catch {
            print("❌ Erro ao remover o usuário: \(error.localizedDescription)")
        }
    }

    
    func buscarUsuariosDaMinhaCasa() async {
        guard let casaID = houseModel?.id else {
            print("❌ Nenhuma casa vinculada ao usuário atual.")
            return
        }
//        appState.casaID = casaID

        print("🔍 Buscando usuários com casa ID: \(casaID.recordName)")

        let casaReference = CKRecord.Reference(recordID: casaID, action: .none)
        let predicate = NSPredicate(format: "UserHouseID == %@", casaReference)
        let query = CKQuery(recordType: "User", predicate: predicate)

        let records = await fetchRecords(matching: query)
        print("📦 Registros encontrados: \(records.count)")

        for record in records {
            print("👤 Usuário: \(record["FullName"] as? String ?? "sem nome")")
        }

        let usuarios = records.compactMap { record -> UserModel? in
            guard
                let nome = record["FullName"] as? String,
                let casaRef = record["UserHouseID"] as? CKRecord.Reference,
                let icloudTokenString = record["UserID"] as? String
            else {
                return nil
            }

            let icloudToken = CKRecord.ID(recordName: icloudTokenString)

            return UserModel(
                id: record.recordID,
                name: nome,
                houseID: casaRef.recordID,
                icloudToken: icloudToken
            )
        }

        await MainActor.run {
            self.usuariosDaCasa = usuarios
            print(usuarios)
        }

        print("✅ Total de usuários vinculados: \(usuarios.count)")
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
        await buscarUsuariosDaMinhaCasa()
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

        // 🟡 Verifica a permissão de descoberta
        let permissaoOK = await pedirPermissaoDescoberta()
        guard permissaoOK else {
            print("❌ Permissão de descoberta de usuário não concedida")
            return
        }

        // 🟢 Obtém o userRecordID
        guard let userRecordID = try? await CKContainer.default().userRecordID() else {
            print("❌ Não foi possível obter o userRecordID")
            return
        }

        // 🟢 Tenta pegar a identidade (nome do usuário)
        let identity = try? await CKContainer.default().userIdentity(forUserRecordID: userRecordID)

        let nome: String
        if let components = identity?.nameComponents {
            nome = [components.givenName, components.familyName].compactMap { $0 }.joined(separator: " ")
        } else {
            nome = "Usuário Desconhecido"
        }

        // 🟢 Cria o registro do usuário
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
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    print("❌ Erro ao executar query: \(error.localizedDescription)")
                }
                continuation.resume(returning: records ?? [])
            }
        }
    }
    
    func fetchCurrentUserRecordID() async -> CKRecord.ID? {
        do {
            return try await CKContainer.default().userRecordID()
        } catch {
            print("❌ Erro ao buscar userRecordID: \(error)")
            return nil
        }
    }
    
    func nomeAbreviado(nomeCompleto: String) -> String {
        let componentes = nomeCompleto.split(separator: " ")
        
        guard let primeiroNome = componentes.first else {
            return nomeCompleto
        }

        if componentes.count > 1, let inicialSobrenome = componentes.dropFirst().first?.first {
            return "\(primeiroNome) \(inicialSobrenome)."
        } else {
            return String(primeiroNome)
        }
    }
}
