import SwiftUI

struct AppStartView: View {
    @StateObject private var appState = AppState()

    @StateObject private var viewModel = HouseProfileViewModel()
    @State private var verificando = true

    var body: some View {
        if verificando {
            ProgressView("Verificando...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    Task {
                        await viewModel.verificarConta()
                        await viewModel.verificarSeUsuarioJaTemCasa()
                        verificando = false
                    }
                }
        } else {
            if viewModel.usuarioJaVinculado {
                MainAppView(
                ).environmentObject(appState)
            } else {
                NavigationView{
                    LoginView(viewModel: viewModel)
                }
            }
        }
    }
}
