import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    // Instância única do HouseProfileViewModel
    @StateObject private var houseProfileViewModel = HouseProfileViewModel()
    @StateObject private var messageViewModel:MessageViewModel = MessageViewModel()
    
    var body: some View {
        TabView {
            NavigationView{
                MuralView(messageViewModel: messageViewModel)
            }
            .tabItem {
                Label("Início", systemImage: "house")
            }
            NavigationView{
                PerfilView()
            }
            .tabItem {
                Label("Tarefas", systemImage: "checkmark.circle")
            }
            // Configurações
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
        }
    }
}
