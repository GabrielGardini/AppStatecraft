import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            FinanceView()
                .tabItem {
                    Label("Início", systemImage: "house")
                }

            FinanceView()
                .tabItem {
                    Label("Tarefas", systemImage: "checkmark.circle")
                }

            FinanceView()
                .tabItem {
                    Label("Config", systemImage: "gear")
                }
        }
    }
}
