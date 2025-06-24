import SwiftUI
import CloudKit

struct MuralView: View {
    @ObservedObject var messageViewModel: MessageViewModel

    @State private var novoTitulo: String = ""
    @State private var novoConteudo: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List(messageViewModel.mensagens.reversed(), id: \.id) { mensagem in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(mensagem.title)
                                .font(.headline)
                            Text(mensagem.content)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("🕓 \(mensagem.timestamp.formatted(.dateTime))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: {
                            Task {
                                await messageViewModel.deletarMensagem(mensagem)
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.large)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 4)
                }

                Divider()

                VStack(spacing: 12) {
                    TextField("Título do aviso", text: $novoTitulo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Conteúdo do aviso", text: $novoConteudo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Criar aviso no mural") {
                        Task {
                            do {
                                let userRecordID = try await CKContainer.default().userRecordID()
                                let userRef = CKRecord.Reference(recordID: userRecordID, action: .none)

                                await messageViewModel.criarMensagem(
                                    content: novoConteudo,
                                    title: novoTitulo,
                                    userID: userRef
                                )

                                novoTitulo = ""
                                novoConteudo = ""

                                await messageViewModel.buscarMensagens()
                            } catch {
                                print("❌ Erro ao obter o userID: \(error)")
                            }
                        }
                    }
                    .disabled(novoTitulo.isEmpty || novoConteudo.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Mural da Casa")
        }
        .onAppear {
            Task {
                await messageViewModel.houseProfileViewModel.verificarSeUsuarioJaTemCasa()
//                await messageViewModel.buscarMensagens()
            }
        }
    }
}
