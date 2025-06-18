import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            FinancesView()
                .tabItem {
                    Label("Início", systemImage: "house")
                }

            FinancesView()
                .tabItem {
                    Label("Tarefas", systemImage: "checkmark.circle")
                }

            FinancesView()
                .tabItem {
                    Label("Config", systemImage: "gear")
                }
        }
    }
}
