import SwiftUI
import CloudKit

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
    repeticao: .nunca,
    lembrete: .nenhum,
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
    repeticao: .nunca,
    lembrete: .nenhum,
    completo: false,
    user: mockUser
)

let viewModel = TasksViewModel(tarefas: [mockTask, mockTask2])


struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    // Instância única do HouseProfileViewModel
    @StateObject private var houseProfileViewModel = HouseProfileViewModel()
    @StateObject private var messageViewModel:MessageViewModel
    
    init() {
            let houseVM = HouseProfileViewModel()
            _houseProfileViewModel = StateObject(wrappedValue: houseVM)
            _messageViewModel = StateObject(wrappedValue: MessageViewModel(houseProfileViewModel: houseVM))
        }
    
    var body: some View {
        TabView {
            NavigationView{
                MuralView(messageViewModel: messageViewModel)
            }
            .tabItem {
                Label("Mural", systemImage: "house")
            }
            NavigationView{
                TasksView(viewModel: viewModel, casaID: mockHouseID, userID: mockUserID)
            }
            .tabItem {
                Label("Tarefas", systemImage: "checkmark.circle")
            }
            // Configurações
            NavigationView{
                FinancesView()
            }
            .tabItem{
                Label("Finanças", systemImage: "checkmark.circle")
            }
            NavigationView{
                PerfilView()
            }
            .tabItem {
                Label("Config", systemImage: "gear")
            }
        }
        .environmentObject(appState)
        .onAppear {
            messageViewModel.houseProfileViewModel = houseProfileViewModel
            messageViewModel.avisoPermicaoNotificacoes()
            messageViewModel.configurarSubscriptionDeAvisos()
        }
    }
}
