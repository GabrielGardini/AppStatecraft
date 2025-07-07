import SwiftUI
import CloudKit

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    @StateObject private var tasksViewModel = TasksViewModel()
    @StateObject private var messageViewModel = MessageViewModel()

    var body: some View {
        TabView {
            NavigationView {
                MuralView(messageViewModel: messageViewModel)
            }
            .tabItem {
                Label("Mural", systemImage: "rectangle.grid.2x2")
            }

            NavigationView {
                TasksView()
            }
            .tabItem {
                Label("Tarefas", systemImage: "checkmark.circle")
            }

            NavigationView {
                FinancesView()
            }
            .tabItem {
                Label("Despesas", systemImage: "dollarsign.circle")
            }

            NavigationView {
                PerfilView()
            }
            .tabItem {
                Label("Minha Casa", systemImage: "house.fill")
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
