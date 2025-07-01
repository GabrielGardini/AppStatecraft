import SwiftUI
import CloudKit

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var houseViewModel: HouseProfileViewModel
    @StateObject private var messageViewModel = MessageViewModel()

    var body: some View {
        TabView {
            NavigationView{
                MuralView(messageViewModel: messageViewModel)
            }
            .tabItem {
                Label("Mural", systemImage: "house")
            }
            NavigationView{
                TasksView()
                    .environmentObject(appState)
                    .environmentObject(houseViewModel)
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
        }
    }
}
