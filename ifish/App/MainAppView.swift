import SwiftUI
import CloudKit

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @StateObject private var tasksViewModel = TasksViewModel()
    @StateObject private var messageViewModel = MessageViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                MuralView(selectedTab: $selectedTab, messageViewModel: messageViewModel)
            }
            .tag(0)
            .tabItem {
                Label("Mural", systemImage: "rectangle.grid.2x2")
            }

            NavigationView {
                TasksView()
            }
            .tag(1)
            .tabItem {
                Label("Tarefas", systemImage: "checkmark.circle")
            }

            NavigationView {
                FinancesView()
            }
            .tag(2)
            .tabItem {
                Label("Despesas", systemImage: "dollarsign.circle")
            }

            NavigationView {
                PerfilView()
            }
            .tag(3)
            .tabItem {
                Label("Minha Casa", systemImage: "person.2.fill")
            }
        }
        .environmentObject(appState)
        .environmentObject(houseViewModel)
        .environmentObject(tasksViewModel)

        .onAppear {
            messageViewModel.houseProfileViewModel = houseViewModel
            messageViewModel.avisoPermicaoNotificacoes()
            messageViewModel.configurarSubscriptionDeAvisos()
            
            Task {
                guard let house = houseViewModel.houseModel else { return }
                await tasksViewModel.buscarTarefasDaCasa(houseModel: house)
            }
            
        }
    }
}
