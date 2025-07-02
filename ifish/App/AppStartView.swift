import SwiftUI

struct AppStartView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel
    
    @State private var verificando = true

    var body: some View {
        if verificando {
            ProgressView("Verificando...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    Task {
                        await houseViewModel.inicializarAppState(appState)
                        await houseViewModel.buscarUsuariosDaMinhaCasa()
                        
                        verificando = false
                    }
                }
        } else {
            if houseViewModel.usuarioJaVinculado {
                MainAppView()
                    .environmentObject(appState)
                    .environmentObject(houseViewModel)
            } else {
                NavigationView {
                    LoginView()
                        .environmentObject(appState)
                        .environmentObject(houseViewModel)
                }
            }
        }
    }
}
