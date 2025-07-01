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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @EnvironmentObject var viewModel: TasksViewModel

    @ObservedObject var task: TaskModel
    @State private var erroTituloVazio = false
    @State private var erroIconeVazio = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Título", text: $task.titulo)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(erroTituloVazio ? Color.red : Color.clear, lineWidth: 1)
                        )
                    // retangulo para navegar pra outra tela (modelos pre prontos >)
                }
                
                Section {
                    DatePicker("Prazo", selection: $task.prazo, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    Picker("Repetição", selection: $task.repeticao) {
                        ForEach(Repeticao.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                    Picker("Lembrete", selection: $task.lembrete) {
                        ForEach(Lembrete.allCases) { opcao in
                            Text(opcao.rawValue.capitalized)
                                .tag(opcao)
                        }
                    }
                }
                
                Section {
                    let _ = {
                        for usuario in houseViewModel.usuariosDaCasa {
                            print("USUARIO DA CASA ID: \(usuario.icloudToken.recordName)")
                        }
                    }()
                    
                    Picker("Responsável", selection: $task.userID) {
                        ForEach(houseViewModel.usuariosDaCasa) { usuario in
                            Text(usuario.name)
                                .tag(usuario.icloudToken)
                        }
                    }
                }
                
                Section {
                    Label("Ícones", systemImage: "")
                        .labelStyle(.titleOnly)
                        .foregroundColor(erroIconeVazio ? .red : .gray)
                    
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 35))]) {
                            ForEach(IconesDisponiveis.todos, id: \.self) { icone in
                                Button(action: {
                                    task.icone = icone
                                    print("\(task.icone)")
                                }) {
                                    IconeEstilo(icone: icone, selecionado: task.icone == icone)
                                }
                                .padding(4)
                            }
                        }
                    }
                    .frame(height: 130)
                }


                Section {
                    ZStack(alignment: .topLeading) {
                        if task.descricao.isEmpty {
                            Text("Descrição")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }

                        TextEditor(text: $task.descricao)
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
                        Task {
                            let tituloValido = !task.titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            let iconeValido = !task.icone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                            erroTituloVazio = !tituloValido
                            erroIconeVazio = !iconeValido

                            if !tituloValido || !iconeValido {
                                return
                            }
                            
                            if let houseModel = houseViewModel.houseModel {
                                await viewModel.criarTarefa(task: task, houseModel: houseModel)
                            } else {
                                print("❌ Nenhuma casa vinculada.")
                            }
                            fecharCriarTaskModalView()
                        }
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
        let mockICloudToken1 = CKRecord.ID(recordName: "_mock-icloud-token-1")
        
        // usuários mock
        let mockUser = UserModel(
            id: mockUserID,
            name: "Maria Lucia",
            houseID: mockHouseID,
            icloudToken: mockICloudToken1
        )
        
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
            completo: false
            )
        ]
        
        let appState = AppState()
        appState.userID = mockUserID
        appState.casaID = mockHouseID
        
        return TasksView()
            .environmentObject(appState)
    }
}
