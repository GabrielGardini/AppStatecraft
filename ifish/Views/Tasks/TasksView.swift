//
//  TasksView.swift
//  ifish
//
//  Created by Larissa on 16/06/25.
//

import SwiftUI
import CloudKit

struct TasksView: View {
    @State var mostrarCriarTask: Bool = false
    @ObservedObject var viewModel: TasksViewModel
    @State private var escolha = "Minhas tarefas"
    
    let casaID: CKRecord.ID
    let userID: CKRecord.ID
    
    private let filtros = ["Minhas tarefas", "Todas"]

    var tarefasFiltradas: [TaskModel] {
        if escolha == "Minhas tarefas" {
            return viewModel.tarefas.filter { $0.userID == userID }
        } else {
            return viewModel.tarefas
        }
    }
    
    var body: some View {
        VStack {
            Picker("", selection: $escolha) {
                ForEach(filtros, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(tarefasFiltradas) { tarefa in
                        TaskCard(task: tarefa)
                    }
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $mostrarCriarTask) {
            EditarTaskView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mostrarCriarTask = true;
                }) {
                    Text(Image(systemName: "plus"))
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        // IDs mock
        let mockUserID = CKRecord.ID(recordName: "mock-user-id")
        let mockHouseID = CKRecord.ID(recordName: "mock-house-id")

        // usuário mock
        let mockUser = UserModel(id: mockUserID, name: "Maria Lucia", houseID: mockHouseID)

        // task mock associando o user
        let mockTask = TaskModel(
            id: CKRecord.ID(recordName: "mock-task-id"),
            userID: mockUserID,
            casaID: mockHouseID,
            icone: "trash.fill",
            titulo: "Tirar o lixo",
            descricao: "",
            prazo: Date(),
            completo: false,
            user: mockUser
        )
        
        // task mock associando o user
        let mockTask2 = TaskModel(
            id: CKRecord.ID(recordName: "mock-task2-id"),
            userID: mockUserID,
            casaID: mockHouseID,
            icone: "leaf.fill",
            titulo: "Regar as plantas",
            descricao: "",
            prazo: Date(),
            completo: false,
            user: mockUser
        )
        
        let viewModel = TasksViewModel(tarefas: [mockTask, mockTask2])
        
        TasksView(viewModel: viewModel, casaID: mockHouseID, userID: mockUserID)
    }
}
