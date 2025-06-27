//
//  CriarTaskView.swift
//  ifish
//
//  Created by Larissa on 23/06/25.
//

import SwiftUI
import CloudKit

struct CriarTaskModalView: View {
    @Environment(\.dismiss) var fecharCriarTaskModalView
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @EnvironmentObject var appState: AppState

    @StateObject var criarTaskViewModel: CriarTaskViewModel
    
    init(task: TaskModel) {
        _criarTaskViewModel = StateObject(wrappedValue: CriarTaskViewModel(task: task))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Título", text: $criarTaskViewModel.task.titulo)
                    // retangulo para navegar pra outra tela (modelos pre prontos >)
                }
                
                Section {
                    DatePicker("Prazo", selection: $criarTaskViewModel.task.prazo, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    Picker("Repetição", selection: $criarTaskViewModel.task.repeticao) {
                        ForEach(Repeticao.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                    Picker("Lembrete", selection: $criarTaskViewModel.task.lembrete) {
                        ForEach(Lembrete.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                }
                
                Section {
                    Picker("Responsável", selection: $criarTaskViewModel.task.user) {
                        ForEach(houseViewModel.usuariosDaCasa) { usuario in
                            Text(usuario.name).tag(Optional(usuario.name))
                        }
                    }
                }
                
                Section {
                    Label("Ícones", systemImage: "")
                        .labelStyle(.titleOnly)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 35))]) {
                        ForEach(IconesDisponiveis.todos, id: \.self) { icone in
                            Button(action: {
                                criarTaskViewModel.task.icone = icone
                            }) {
                                IconeEstilo(icone: icone, selecionado: criarTaskViewModel.task.icone == icone)
                            }
                            .padding(4)
                        }
                    }
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if criarTaskViewModel.task.descricao.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $criarTaskViewModel.task.descricao)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Nova tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharCriarTaskModalView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                    }
                }
            }
            .task {
                await houseViewModel.buscarUsuariosDaMinhaCasa()
            }
        }
        .navigationViewStyle(.stack)
    }
    
}

struct CriarTaskView_Previews: PreviewProvider {
    static var previews: some View {
        // IDs mock
        let mockUserID = CKRecord.ID(recordName: "mock-user-id")
        let mockHouseID = CKRecord.ID(recordName: "mock-house-id")

        // usuário mock
        let mockUser = UserModel(id: mockUserID, name: "Maria Lucia", houseID: mockHouseID)

        let mockTasks = [
            TaskModel(
            id: CKRecord.ID(recordName: "mock-task2-id"),
            userID: mockUserID,
            casaID: mockHouseID,
            icone: "leaf.fill",
            titulo: "Regar as plantas",
            descricao: "",
            prazo: Date(),
            repeticao: .semanalmente,
            lembrete: .quinzeMinutos,
            completo: false,
            user: mockUser
            )
        ]
        
        let viewModel = TasksViewModel()
        let appState = AppState()
        appState.userID = mockUserID
        appState.casaID = mockHouseID
        appState.usuario = mockUser
        
        return TasksView(viewModel: viewModel)
            .environmentObject(appState)
    }
}
