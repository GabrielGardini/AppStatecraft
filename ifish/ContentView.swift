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

    func checkiCloudAccountStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                isLoggedInToiCloud = (status == .available)
                print(isLoggedInToiCloud ? "✅ Logado no iCloud" : "❌ Não logado: \(String(describing: error))")
            }
        }
    }

    func createCasa() {
        let casa = CKRecord(recordType: "Casa")
        casa["Nome"] = "Casa do Gardini" as CKRecordValue

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
    }

    func registrarUsuario(casa: CKRecord) {
        let container = CKContainer.default()

        // 1. Buscar o recordID do usuário
        container.fetchUserRecordID { userRecordID, error in
            if let error = error {
                print("❌ Erro ao buscar ID do usuário: \(error)")
                return
            }
            guard let userRecordID = userRecordID else { return }

            // 2. Buscar o nome completo (opcional)
            print(userRecordID)
            container.discoverUserIdentity(withUserRecordID: userRecordID) { identity, error in
                var nome = "Usuário Desconhecido"
                print(identity)
                if let userName = identity?.nameComponents?.givenName {
                    nome = userName
                }

                // 3. Criar registro na tabela Users
                let userRecord = CKRecord(recordType: "User")
                userRecord["UserID"] = userRecordID.recordName as CKRecordValue
                userRecord["FullName"] = nome as CKRecordValue
                userRecord["UserHouseID"] = CKRecord.Reference(record: casa, action: .none)

//                container.publicCloudDatabase.save(userRecord) { savedUser, error in
//                    DispatchQueue.main.async {
//                        if let error = error {
//                            print("❌ Erro ao salvar usuário: \(error)")
//                        } else {
//                            print("✅ Usuário registrado: \(nome)")
//                        }
//                    }
//                }
            }
        }
    }

    func buscarCasas() {
        let predicate = NSPredicate(value: true) // busca todos
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

