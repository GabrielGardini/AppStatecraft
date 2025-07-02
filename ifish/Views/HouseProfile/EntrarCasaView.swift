import SwiftUI

struct EntrarCasaView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @State private var navegarParaProxima = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Digite um código de convite")
                .font(.title2)

            TextField("Código", text: $houseViewModel.codigoConviteInput)
                .textFieldStyle(.roundedBorder)

            Button("Entrar na casa") {
                Task {
                    await houseViewModel.entrarComCodigoConvite()
                    navegarParaProxima = true
                }
            }
            .buttonStyle(.borderedProminent)

            NavigationLink(
                destination: CasaCriadaView()
                            .environmentObject(appState)
                            .environmentObject(houseViewModel),
                isActive: $navegarParaProxima) {
                EmptyView()
            }
        }
        .padding()
    }
}
