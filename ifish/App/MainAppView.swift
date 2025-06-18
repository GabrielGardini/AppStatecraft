import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            FinanceView()
                .tabItem {
                    Label("Início", systemImage: "house")
                }

            TasksView()
                .tabItem {
                    Label("Tarefas", systemImage: "checkmark.circle")
                }

            PerfilView()
                .tabItem {
                    Label("Config", systemImage: "gear")
                }
        }
    }
}
