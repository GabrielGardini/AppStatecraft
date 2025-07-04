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
    @EnvironmentObject var viewModel: TasksViewModel
    
    @State private var mostrarCriarTaskModalView: Bool = false
    @State private var mostrarDetalheTaskModalView: Bool = false
    
    @State private var tarefaSelecionada: TaskModel? = nil
    
    @State private var novaTask = TaskModel.vazia(
        casaID: nil,
        userID: nil
    )

    @State private var escolha = "Minhas tarefas"
    private let filtroPicker = ["Minhas tarefas", "Todas"]
    @State private var filtroData = Date()     // a tela inicia com o filtro no mes e ano atual
    
    private func resetarNovaTask() {
        novaTask = TaskModel.vazia(
            casaID: appState.casaID,
            userID: appState.userID
        )
    }


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
                        
                        // se nao há tarefas ou todas estao concluidas
                        if tarefasFiltradas.isEmpty || (tarefasFiltradas.filter {!$0.completo}).isEmpty {
                            VStack(spacing: 10) {
                                Text("Não há nenhuma tarefa pendente! 🎉")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image("listavazia")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 300)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        TaskSectionView(
                            titulo: "Atrasadas",
                            tarefas: tarefasFiltradas
                                        .filter {
                                            ($0.prazo < Date()) &&
                                            !Calendar.current.isDateInToday($0.prazo) &&
                                            !$0.completo
                                        }
                                        .sorted { $0.prazo < $1.prazo },
                            tarefaSelecionada: $tarefaSelecionada
                        )
                        .environmentObject(houseViewModel)

                        TaskSectionView(
                            titulo: "Hoje",
                            tarefas: tarefasFiltradas
                                        .filter {
                                            Calendar.current.isDateInToday($0.prazo) &&
                                            !$0.completo
                                            }
                                        .sorted { $0.prazo < $1.prazo },
                            tarefaSelecionada: $tarefaSelecionada
                        )
                        .environmentObject(houseViewModel)


                        TaskSectionView(
                            titulo: "Amanhã",
                            tarefas: tarefasFiltradas
                                        .filter {
                                            Calendar.current.isDateInTomorrow($0.prazo) && !$0.completo
                                            }
                                        .sorted { $0.prazo < $1.prazo },
                            tarefaSelecionada: $tarefaSelecionada
                        )
                        .environmentObject(houseViewModel)

                        TaskSectionView(
                            titulo: "Próximas",
                            tarefas: tarefasFiltradas
                                        .filter {
                                            !$0.completo &&
                                            $0.prazo > Date() &&
                                            !Calendar.current.isDateInToday($0.prazo) &&
                                            !Calendar.current.isDateInTomorrow($0.prazo)
                                            }
                                        .sorted { $0.prazo < $1.prazo },
                            tarefaSelecionada: $tarefaSelecionada
                        )
                        .environmentObject(houseViewModel)

                        TaskSectionView(
                            titulo: "Concluídas",
                            tarefas: tarefasFiltradas
                                        .filter { $0.completo }
                                        .sorted { $0.prazo > $1.prazo },
                            tarefaSelecionada: $tarefaSelecionada
                        )
                        .environmentObject(houseViewModel)

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
                        .foregroundColor(.black)
                }
                .sheet(isPresented: $mostrarCriarTaskModalView, onDismiss: {
                    resetarNovaTask()
                }) {
                    CriarTaskModalView(task: novaTask)
                        .environmentObject(appState)
                        .environmentObject(houseViewModel)
                        .environmentObject(viewModel)
                }
                .sheet(item: $tarefaSelecionada) { tarefa in
                    DetalheTaskModalView(tarefa: tarefa)
                        .environmentObject(appState)
                        .environmentObject(houseViewModel)
                        .environmentObject(viewModel)
                }

            }
        }
        .onAppear {
            Task {
                if let casaID = appState.casaID, let userID = appState.userID {
                    novaTask = TaskModel.vazia(
                        casaID: casaID,
                        userID: userID
                    )
                }
            }
        }


    }
}

struct TaskSectionView: View {
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    var titulo: String
    var tarefas: [TaskModel]
        
    @Binding var tarefaSelecionada: TaskModel?
    
    var isAtrasada: Bool {
        titulo == "Atrasadas"
    }

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
                        task:
                            tarefa,
                        iconeAlterado:
                            isConcluida ? "checkmark" : nil,
                        corFundoIcone:
                            isConcluida ? Color.green.opacity(0.5) :
                            isAtrasada ? Color.red : nil,
                        nomeUsuario:
                            houseViewModel.nomeAbreviado(
                                nomeCompleto: houseViewModel.nomeDoUsuario(id: tarefa.userID)
                            )
                        )
                    .onTapGesture {
                        tarefaSelecionada = tarefa
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
        
        return TasksView()
            .environmentObject(appState)
    }
}
