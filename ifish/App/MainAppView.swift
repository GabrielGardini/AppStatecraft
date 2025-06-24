import SwiftUI

struct MainAppView: View {
    var body: some View {
        let mockViewModel = HouseProfileViewModel()
        TabView {
            FinancesView(viewModel: mockViewModel)
                .tabItem {
                    Label("Início", systemImage: "house")
                }

            FinancesView(viewModel: mockViewModel)
                .tabItem {
                    Label("Tarefas", systemImage: "checkmark.circle")
                }

            PerfilView(viewModel: mockViewModel)
                .tabItem {
                    Label("Config", systemImage: "gear")
                }
        }
    }
}
