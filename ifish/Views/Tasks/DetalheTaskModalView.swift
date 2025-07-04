//
//  DetalheTaskModalVIew.swift
//  ifish
//
//  Created by Larissa on 26/06/25.
//

import SwiftUI
import CloudKit

struct DetalheTaskModalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @EnvironmentObject var tasksViewModel: TasksViewModel
    
    @State private var mostrarEditarTaskModalView = false
    @ObservedObject var tarefa: TaskModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text(tarefa.titulo)
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.top)
                        
                Text("Prazo")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Text(tarefa.prazo.formatted(date: .abbreviated, time: .shortened))
                    .font(.body)
                    .padding(.bottom)
                            
                HStack {
                    Text("Ocorrência")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(tarefa.repeticao.rawValue.capitalized)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                HStack {
                    Text("Responsável")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(houseViewModel.nomeDoUsuario(id: tarefa.userID))
                        .foregroundColor(.gray)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Responsável: \(houseViewModel.nomeDoUsuario(id: tarefa.userID))")

                .padding(.bottom)

                
                TextEditor(text: .constant(tarefa.descricao.isEmpty ? "Descrição..." : tarefa.descricao))
                    .disabled(true)
                    .foregroundColor(tarefa.descricao.isEmpty ? .gray : .primary)
                    .frame(height: 100)
                    .padding(4)
                    .cornerRadius(8)

                Spacer()

                Button {
                    Task {
                        tarefa.completo.toggle()
                        await tasksViewModel.editarTarefa(tarefa)

                        if tarefa.completo, let nova = tarefa.criarProximaTarefaRecorrente(),
                           let house = houseViewModel.houseModel {
                            await tasksViewModel.criarTarefa(task: nova, houseModel: house)
                        }

                        dismiss()
                    }
                } label: {
                    Text("Feito")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (tarefa.userID != appState.userID || tarefa.completo)
                                ? .gray
                                : Color("TasksMainColor")
                        )
                        .cornerRadius(10)
                }
                .disabled(tarefa.userID != appState.userID)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Voltar") {
                        dismiss()
                    }
                    .foregroundColor(Color("TasksMainColor"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Editar") {
                        mostrarEditarTaskModalView = true
                    }
                    .foregroundColor(Color("TasksMainColor"))
                    
                    .sheet(isPresented: $mostrarEditarTaskModalView) {
                        if let tarefa = tarefa {
                            EditarTaskModalView(
                                task: tarefa,
                                onApagar: {
                                    // Fecha o DetalheTaskModalView ao apagar
                                    dismiss()
                                }
                            )
                            .environmentObject(appState)
                            .environmentObject(houseViewModel)
                            .environmentObject(tasksViewModel)
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct DetalheTaskModalView_Preview: PreviewProvider {
        static var previews: some View {
            // IDs mock
            let mockUserID = CKRecord.ID(recordName: "mock-user-id")
            let mockUser2ID = CKRecord.ID(recordName: "mock-user2-id")
            let mockHouseID = CKRecord.ID(recordName: "mock-house-id")
            let mockICloudToken1 = CKRecord.ID(recordName: "_mock-icloud-token-1")
            let mockICloudToken2 = CKRecord.ID(recordName: "_mock-icloud-token-2")
            
            // usuários mock
            let mockUser = UserModel(
                id: mockUserID,
                name: "Maria Lucia",
                houseID: mockHouseID,
                icloudToken: mockICloudToken1
            )
            let mockUser2 = UserModel(
                id: mockUser2ID,
                name: "Geronimo",
                houseID: mockHouseID,
                icloudToken: mockICloudToken2
            )
            
            let mockTasks = [
                TaskModel(
                    id: CKRecord.ID(recordName: "mock-task-id"),
                    userID: mockUserID,
                    casaID: mockHouseID,
                    icone: "trash.fill",
                    titulo: "Tirar o lixo",
                    descricao: "",
                    prazo: Date(),
                    repeticao: .semanalmente,
                    lembrete: .quinzeMinutos,
                    completo: false
                ),
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
                ),
                TaskModel(
                    id: CKRecord.ID(recordName: "mock-task3-id"),
                    userID: mockUser2ID,
                    casaID: mockHouseID,
                    icone: "car.fill",
                    titulo: "Lavar Garagem",
                    descricao: "",
                    prazo: Date(),
                    repeticao: .nunca,
                    lembrete: .nenhum,
                    completo: false
                ),
                TaskModel(
                    id: CKRecord.ID(recordName: "mock-task4-id"),
                    userID: mockUserID,
                    casaID: mockHouseID,
                    icone: "car.fill",
                    titulo: "Lavar Garagem",
                    descricao: "",
                    prazo: Date(),
                    repeticao: .nunca,
                    lembrete: .nenhum,
                    completo: true
                )
            ]
            
            let houseViewModel = HouseProfileViewModel()

            let viewModel = TasksViewModel()
            let appState = AppState()
            appState.userID = mockUserID
            appState.casaID = mockHouseID
            
            return DetalheTaskModalView(tarefa: mockTasks.first ?? TaskModel.vazia(casaID: appState.casaID, userID: appState.userID))
            
        }
}
