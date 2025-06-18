import SwiftUI

struct AppStartView: View {
    @StateObject private var viewModel = HouseProfileViewModel()
    @State private var navegarParaMain = false
    @State private var navegarParaLogin = false

    var body: some View {
        NavigationView {
            VStack {
                ProgressView("Verificando...")
                    .onAppear {
                        Task {
                            await viewModel.verificarConta()
                            await viewModel.verificarSeUsuarioJaTemCasa()

                            // Espera a verificação de vínculo ser feita
                            if viewModel.usuarioJaVinculado {
                                navegarParaMain = true
                            } else {
                                navegarParaLogin = true
                            }
                        }
                    }

                // Redirecionamentos automáticos
                NavigationLink(destination: MainAppView(), isActive: $navegarParaMain) {
                    EmptyView()
                }
                NavigationLink(destination: LoginView(viewModel: viewModel), isActive: $navegarParaLogin) {
                    EmptyView()
                }
            }
        }
    }
}
