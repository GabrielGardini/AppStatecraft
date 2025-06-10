import SwiftUI
import CloudKit

struct ContentView: View {
    @State private var isLoggedInToiCloud = false
    @State private var casaRecord: CKRecord?
    @State private var casasEncontradas: [CKRecord] = []

    var body: some View {
        VStack(spacing: 30) {
            Text("App de Tarefas da Casa")
                .font(.largeTitle)
                .multilineTextAlignment(.center)

            Button("Logar com iCloud", action: checkiCloudAccountStatus)
                .buttonStyle(.borderedProminent)

            if isLoggedInToiCloud {
                Button("Criar Casa", action: createCasa)
                    .buttonStyle(.borderedProminent)

                Button("Buscar Casas", action: buscarCasas)
                    .buttonStyle(.bordered)

                if !casasEncontradas.isEmpty {
                    List(casasEncontradas, id: \.recordID) { casa in
                        VStack(alignment: .leading) {
                            Text(casa["nome"] as? String ?? "Sem nome")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - iCloud Login

    func checkiCloudAccountStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                isLoggedInToiCloud = (status == .available)
                print(isLoggedInToiCloud ? "✅ Logado no iCloud" : "❌ Não logado: \(String(describing: error))")
            }
        }
    }

    // MARK: - Criar Casa

    func createCasa() {
        pedirPermissaoDescoberta { granted in
            if granted {
                let casa = CKRecord(recordType: "Casa")
                casa["nome"] = "Casa do Gardini" as CKRecordValue

                let publicDB = CKContainer.default().publicCloudDatabase
                publicDB.save(casa) { savedRecord, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ Erro ao salvar casa: \(error)")
                        } else if let savedCasa = savedRecord {
                            print("✅ Casa criada")
                            casaRecord = savedCasa
                            registrarUsuario(casa: savedCasa)
                        }
                    }
                }
            } else {
                print("⚠️ Permissão de descoberta de usuário não concedida")
            }
        }
    }

    // MARK: - Permissão de Descoberta

    func pedirPermissaoDescoberta(completion: @escaping (Bool) -> Void) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { status, error in
            DispatchQueue.main.async {
                if status == .granted {
                    print("✅ Permissão de descoberta concedida")
                    completion(true)
                } else {
                    print("❌ Permissão de descoberta negada: \(String(describing: error))")
                    completion(false)
                }
            }
        }
    }

    // MARK: - Registrar Usuário

    func registrarUsuario(casa: CKRecord) {
        let container = CKContainer.default()

        container.fetchUserRecordID { userRecordID, error in
            if let error = error {
                print("❌ Erro ao buscar ID do usuário: \(error)")
                return
            }
            guard let userRecordID = userRecordID else { return }

            container.discoverUserIdentity(withUserRecordID: userRecordID) { identity, error in
                var nome = "Usuário Desconhecido"
                if let components = identity?.nameComponents {
                    let firstName = components.givenName ?? ""
                    let lastName = components.familyName ?? ""
                    nome = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                }

                let userRecord = CKRecord(recordType: "User")
                userRecord["UserID"] = userRecordID.recordName as CKRecordValue
                userRecord["FullName"] = nome as CKRecordValue
                userRecord["UserHouseID"] = CKRecord.Reference(record: casa, action: .none)

                container.publicCloudDatabase.save(userRecord) { savedUser, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ Erro ao salvar usuário: \(error)")
                        } else {
                            print("✅ Usuário registrado: \(nome)")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Buscar Casas

    func buscarCasas() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Casa", predicate: predicate)

        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erro na busca: \(error.localizedDescription)")
                } else {
                    casasEncontradas = results ?? []
                    print("✅ Encontradas \(casasEncontradas.count) casas")
                }
            }
        }
    }
}
