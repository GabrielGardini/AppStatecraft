import SwiftUI
import CloudKit

struct EditarAvisoModalView: View {
    @Environment(\.dismiss) var fecharModalEditarAviso
    @EnvironmentObject var messageViewModel: MessageViewModel
    @State private var mostrarConfirmacaoApagar = false

    @State private var nomeAviso: String = ""
    @State private var descricaoAviso: String = ""
    @State private var dataAviso: Date = Date()
    @State private var notificacoesAviso: Bool = true

    @State private var mostrarConfirmacaoExclusao = false

    var aviso: MessageModel

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Título", text: $nomeAviso)
                }

                Section {
                    DatePicker("Data", selection: $dataAviso, displayedComponents: [.date, .hourAndMinute])
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if descricaoAviso.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $descricaoAviso)
                            .frame(minHeight: 100)
                            .padding(4)
                    }
                }

                Section {
                    Toggle("Notificações", isOn: $notificacoesAviso)
                }
                
                HStack{
                    Spacer()
                    Button("Apagar aviso") {
                        mostrarConfirmacaoApagar = true
                    }
                    .foregroundColor(.red)
                    .confirmationDialog("Tem certeza que deseja apagar esse aviso?", isPresented: $mostrarConfirmacaoApagar, titleVisibility: .visible) {
                        Button("Apagar aviso", role: .destructive) {
                            Task {
                                await messageViewModel.deletarMensagem(aviso)
                                fecharModalEditarAviso()
                            }                        }
                        Button("Cancelar", role: .cancel) { }
                        .foregroundColor(.accentColor)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Editar Aviso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharModalEditarAviso()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task {
                            await salvarEdicao()
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            nomeAviso = aviso.title
            descricaoAviso = aviso.content
            dataAviso = aviso.timestamp
        }
    }

    private func salvarEdicao() async {
        aviso.title = nomeAviso
        aviso.content = descricaoAviso
        aviso.timestamp = dataAviso

        await messageViewModel.editarMensagem(aviso)
        fecharModalEditarAviso()
    }
}
