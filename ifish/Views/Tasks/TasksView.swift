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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    
    @StateObject var viewModel = TasksViewModel()
    
    @State private var mostrarCriarTaskModalView: Bool = false
    @State private var mostrarDetalheTaskModalView: Bool = false
    @State private var tarefaSelecionada: TaskModel? = nil
    
    @State private var escolha = "Minhas tarefas"
    private let filtroPicker = ["Minhas tarefas", "Todas"]
    @State private var filtroData = Date()     // a tela inicia com o filtro no mes e ano atual
    
    var tarefasFiltradas: [TaskModel] {
        guard let userID = appState.userID else { return [] }
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
            fundoTasks.ignoresSafeArea()
            
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
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                    
                    // O filtro volta a ser o mes atual
                    Button(action: {
                        filtroData = Date()
                    }) {
                        Text(filtroData.formatadoMesAno())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                           filtroData = Calendar.current.date(byAdding: .month, value: 1, to: filtroData) ?? filtroData
                    }) {
                       Text(">")
                           .font(.title2)
                           .padding(.horizontal)
                   }
                    .buttonStyle(PlainButtonStyle())

                }
                .padding(.bottom, 10)
                
                // picker com filtro minhas tarefas, todas tarefas
                Picker("", selection: $escolha) {
                    ForEach(filtroPicker, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 10)

                
                // lista das tarefas filtradas
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        
                        TaskSectionView(
                            titulo: "Hoje",
                            tarefas: tarefasFiltradas.filter {
                                Calendar.current.isDateInToday($0.prazo) && !$0.completo
                            },
                            aoSelecionar: { tarefa in
                                tarefaSelecionada = tarefa
                                mostrarDetalheTaskModalView = true
                            }
                        )

                        TaskSectionView(
                            titulo: "Amanhã",
                            tarefas: tarefasFiltradas.filter {
                                Calendar.current.isDateInTomorrow($0.prazo) && !$0.completo
                            },
                            aoSelecionar: { tarefa in
                                tarefaSelecionada = tarefa
                                mostrarDetalheTaskModalView = true
                            }
                        )

                        TaskSectionView(
                            titulo: "Outros",
                            tarefas: tarefasFiltradas.filter {
                                !$0.completo &&
                                !Calendar.current.isDateInToday($0.prazo) &&
                                !Calendar.current.isDateInTomorrow($0.prazo)
                            },
                            aoSelecionar: { tarefa in
                                tarefaSelecionada = tarefa
                                mostrarDetalheTaskModalView = true
                            }
                        )

                        TaskSectionView(
                            titulo: "Concluídas",
                            tarefas: tarefasFiltradas.filter { $0.completo },
                            aoSelecionar: { tarefa in
                                tarefaSelecionada = tarefa
                                mostrarDetalheTaskModalView = true
                            }
                        )
                    }
                    .padding(.horizontal, 5)
                }

                
                Spacer()
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Tarefas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mostrarCriarTaskModalView = true;
                }) {
                    Text(Image(systemName: "plus"))
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $mostrarCriarTaskModalView) {
                    CriarTaskModalView(task: TaskModel.vazia(
                        casaID: appState.casaID,
                        userID: appState.userID,
                        user: appState.usuario
                    ))
                    .environmentObject(appState)
                    .environmentObject(houseViewModel)
                }
                .sheet(isPresented: $mostrarDetalheTaskModalView) {
                    if let tarefa = tarefaSelecionada {
                        DetalheTaskModalView(tarefa: tarefa)
                    }
                }
            }
        }
    }
}

struct TaskSectionView: View {
    var titulo: String
    var tarefas: [TaskModel]
    
    var aoSelecionar: (TaskModel) -> Void
    
    var isConcluida: Bool {
        titulo == "Concluídas"
    }

    var body: some View {
        if !tarefas.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text(titulo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ForEach(tarefas) { tarefa in
                    TaskCard(
                        task: tarefa,
                        iconeAlterado: isConcluida ? "checkmark" : nil,
                        corFundoIcone: isConcluida ? Color.green.opacity(0.5) : nil
                    )
                    .onTapGesture {
                        aoSelecionar(tarefa)
                    }
                    .padding(.bottom, 4)
                }
            }
        }
    }
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        // IDs mock
        let mockUserID = CKRecord.ID(recordName: "mock-user-id")
        let mockUser2ID = CKRecord.ID(recordName: "mock-user2-id")
        let mockHouseID = CKRecord.ID(recordName: "mock-house-id")

        // usuários mock
        let mockUser = UserModel(id: mockUserID, name: "Maria Lucia", houseID: mockHouseID)
        let mockUser2 = UserModel(id: mockUser2ID, name: "Geronimo", houseID: mockHouseID)

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
                completo: false,
                user: mockUser
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
                completo: false,
                user: mockUser
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
                completo: false,
                user: mockUser2
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
