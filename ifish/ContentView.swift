import SwiftUI
import CloudKit

struct ContentView: View {
    @State private var isLoggedInToiCloud = false
    @State private var usuarioJaVinculado = false
    @State private var NomeCasaUsuario: String = ""
    @State private var casaNomeInput = ""
    @State private var codigoConviteInput = ""
    @State private var casaRecord: CKRecord?
    @State private var casasEncontradas: [CKRecord] = []
    
    @State private var mostrarAlertaICloud = false

    var body: some View {
        VStack(spacing: 20) {
            Text("App de Tarefas da Casa")
                .font(.title)
                .bold()

            if !isLoggedInToiCloud {
                Button(action: verificarConta) {
                    Label("Entrar com iCloud", systemImage: "icloud")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            if isLoggedInToiCloud {
                if usuarioJaVinculado {
                    VStack(spacing: 10) {
                        Text("🏠 Sua casa: \(NomeCasaUsuario)")
                        if let codigo = casaRecord?["InviteCode"] as? String {
                            Text("🔑 Código de convite: \(codigo)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        TextField("Nome da nova casa", text: $casaNomeInput)
                            .textFieldStyle(.roundedBorder)

                        Button("Criar Casa") {
                            criarCasa(Nome: casaNomeInput)
                        }
                        .buttonStyle(.borderedProminent)

                        Divider()

                        TextField("Código de convite", text: $codigoConviteInput)
                            .textFieldStyle(.roundedBorder)

                        Button("Entrar com código") {
                            entrarComCodigoConvite(codigo: codigoConviteInput)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .onAppear {
            verificarConta()
        }
        .alert("iCloud não disponível", isPresented: $mostrarAlertaICloud) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Você precisa estar logado no iCloud para usar este app.")
        }
    }

    // MARK: - Verificar Login e Casa

    func verificarConta() {
        CKContainer.default().accountStatus { status, _ in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    isLoggedInToiCloud = true
                    verificarSeUsuarioJaTemCasa()
                case .noAccount, .restricted, .couldNotDetermine:
                    isLoggedInToiCloud = false
                    mostrarAlertaICloud = true
                @unknown default:
                    isLoggedInToiCloud = false
                    mostrarAlertaICloud = true
                }
            }
        }
    }

    func verificarSeUsuarioJaTemCasa() {
        CKContainer.default().fetchUserRecordID { userRecordID, error in
            guard let userRecordID = userRecordID else { return }

            let predicate = NSPredicate(format: "UserID == %@", userRecordID.recordName)
            let query = CKQuery(recordType: "User", predicate: predicate)

            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { results, _ in
                if let user = results?.first,
                   let ref = user["UserHouseID"] as? CKRecord.Reference {
                    CKContainer.default().publicCloudDatabase.fetch(withRecordID: ref.recordID) { casaRecord, _ in
                        DispatchQueue.main.async {
                            self.NomeCasaUsuario = casaRecord?["Nome"] as? String ?? "Casa desconhecida"
                            self.usuarioJaVinculado = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Criar Casa

    func criarCasa(Nome: String) {
        pedirPermissaoDescoberta { granted in
            guard granted else { return }

            let casa = CKRecord(recordType: "Casa")
            casa["Nome"] = Nome as CKRecordValue
            casa["InviteCode"] = UUID().uuidString.prefix(6).uppercased() as CKRecordValue

            let db = CKContainer.default().publicCloudDatabase
            db.save(casa) { savedCasa, error in
                DispatchQueue.main.async {
                    if let savedCasa = savedCasa {
                        self.casaRecord = savedCasa
                        registrarUsuario(casa: savedCasa)
                    }
                }
            }
        }
    }

    // MARK: - Entrar com Código

    func entrarComCodigoConvite(codigo: String) {
        let predicate = NSPredicate(format: "InviteCode == %@", codigo)
        let query = CKQuery(recordType: "Casa", predicate: predicate)

        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { results, _ in
            if let casa = results?.first {
                self.casaRecord = casa
                registrarUsuario(casa: casa)
            } else {
                print("❌ Código de convite inválido")
            }
        }
    }

    // MARK: - Registrar Usuário

    func registrarUsuario(casa: CKRecord) {
        let container = CKContainer.default()

        container.fetchUserRecordID { userRecordID, _ in
            guard let userRecordID = userRecordID else { return }

            container.discoverUserIdentity(withUserRecordID: userRecordID) { identity, _ in
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
                        if let _ = savedUser {
                            print("✅ Usuário registrado: \(nome)")
                            self.usuarioJaVinculado = true
                            self.NomeCasaUsuario = casa["Nome"] as? String ?? "Casa"
                        }
                    }
                }
            }
        }
    }

    // MARK: - Permissão

    func pedirPermissaoDescoberta(completion: @escaping (Bool) -> Void) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { status, _ in
            DispatchQueue.main.async {
                completion(status == .granted)
            }
        }
    }
}
