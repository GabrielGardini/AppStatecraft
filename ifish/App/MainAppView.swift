import SwiftUI
import CloudKit

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @StateObject private var messageViewModel = MessageViewModel()

    var body: some View {
        TabView {
            NavigationView {
                MuralView(messageViewModel: messageViewModel)
            }
            .tabItem {
                Label("Mural", systemImage: "house")
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
                Label("Finanças", systemImage: "checkmark.circle")
            }

            NavigationView {
                PerfilView()
            }
            .tabItem {
                Label("Config", systemImage: "gear")
            }
        }
        .environmentObject(houseViewModel)
        .environmentObject(appState)
        .onAppear {
            messageViewModel.houseProfileViewModel = houseViewModel
            messageViewModel.avisoPermicaoNotificacoes()
            messageViewModel.configurarSubscriptionDeAvisos()
        }
    }
}
