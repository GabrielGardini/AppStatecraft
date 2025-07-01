import SwiftUI
import CloudKit

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
            messageViewModel.houseProfileViewModel = houseViewModel
            messageViewModel.avisoPermicaoNotificacoes()
            messageViewModel.configurarSubscriptionDeAvisos()
        }
    }
}
