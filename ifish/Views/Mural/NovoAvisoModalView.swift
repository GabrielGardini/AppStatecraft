import SwiftUI
import CloudKit

struct NovoAvisoModalView: View {
    @Environment(\.dismiss) var fecharModalNovoAviso
    @EnvironmentObject var messageViewModel: MessageViewModel
    @State private var nomeAviso: String = ""
    @State private var descricaoAviso: String = ""
    @State private var dataAviso: Date = Date()
    @State private var notificacoesAviso: Bool = true
    @State private var mostrarConfirmacaoCancelar: Bool = false

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
            }
            .navigationTitle("Novo Aviso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        if(nomeAviso == "" &&
                           descricaoAviso == ""){
                            fecharModalNovoAviso()
                        }
                        else{
                            mostrarConfirmacaoCancelar = true
                        }
                    }
                    .confirmationDialog("Tem certeza de que deseja descartar as alterações?", isPresented: $mostrarConfirmacaoCancelar, titleVisibility: .visible){
                        Button("Ignorar alterações", role: .destructive){
                            Task {
                                fecharModalNovoAviso()
                            }
                        }
                        Button("Continuar Editando", role: .cancel){}
                        .foregroundColor(.accentColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        Task {
                            guard let userRecordID = try? await CKContainer.default().userRecordID() else {
                                print("❌ Não foi possível obter o userRecordID")
                                return
                            }

                            let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)

                            await messageViewModel.criarMensagem(
                                content: descricaoAviso,
                                title: nomeAviso,
                                dataAviso:dataAviso,
                                userID: userReference,
                                notificationMural: notificacoesAviso
                            )

                            fecharModalNovoAviso()
                        }
                    } .disabled(nomeAviso == "")
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
