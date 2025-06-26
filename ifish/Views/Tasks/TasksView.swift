//
//  TasksView.swift
//  ifish
//
//  Created by Larissa on 16/06/25.
//

import SwiftUI
import CloudKit

let fundoTasks = LinearGradient(
    colors: [Color("TasksMainColor"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2)
)

struct TasksView: View {
    @ObservedObject var viewModel: TasksViewModel
    @State private var escolha = "Minhas tarefas"
    
    let casaID: CKRecord.ID
    let userID: CKRecord.ID
    
    @State private var mostrarCriarTaskModalView: Bool = false
    @State private var mostrarInfoTaskModalView: Bool = false
    
    private let filtroPicker = ["Minhas tarefas", "Todas"]
    @State private var filtroData = Date()     // a tela inicia com o filtro no mes e ano atual
    
    var tarefasFiltradas: [TaskModel] {
        let calendar = Calendar.current
        let filtroMes = calendar.component(.month, from: filtroData)
        let filtroAno = calendar.component(.year, from: filtroData)
        
        return viewModel.tarefas.filter { tarefa in
            let tarefaMes = calendar.component(.month, from: tarefa.prazo)
            let tarefaAno = calendar.component(.year, from: tarefa.prazo)
            
            let filtroMesAno = {
                                tarefaMes == filtroMes &&
                                tarefaAno == filtroAno
                                }

            if escolha == "Minhas tarefas" {
                return tarefa.userID == userID && filtroMesAno()
            } else {
                return filtroMesAno()
            }
        }
    }
    
    var body: some View {
        ZStack {
            fundoTasks
                .ignoresSafeArea()
            
            VStack {
                
                // filtro do mes e ano:   < jun 2025 >
                HStack {
                    Button(action: {
                           filtroData = Calendar.current.date(byAdding: .month, value: -1, to: filtroData) ?? filtroData
                    }) {
                       Text("<")
                           .font(.title2)
                           .padding(.horizontal)
                   }
                    
                    Text(filtroData.formatadoMesAno())
                    
                    Button(action: {
                           filtroData = Calendar.current.date(byAdding: .month, value: 1, to: filtroData) ?? filtroData
                    }) {
                       Text(">")
                           .font(.title2)
                           .padding(.horizontal)
                   }
                }
                
                // picker com filtro minhas tarefas, todas tarefas
                Picker("", selection: $escolha) {
                    ForEach(filtroPicker, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                
                // lista das tarefas filtradas
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(tarefasFiltradas) { tarefa in
                            TaskCard(task: tarefa)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mostrarCriarTaskModalView = true;
                }) {
                    Text(Image(systemName: "plus"))
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $mostrarCriarTaskModalView) {
                    CriarTaskModalView();
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
            repeticao: .semanalmente,
            lembrete: .quinzeMinutos,
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
            repeticao: .semanalmente,
            lembrete: .quinzeMinutos,
            completo: false,
            user: mockUser
        )
        
        let viewModel = TasksViewModel(tarefas: [mockTask, mockTask2])
        
        TasksView(viewModel: viewModel, casaID: mockHouseID, userID: mockUserID)
    }
}
