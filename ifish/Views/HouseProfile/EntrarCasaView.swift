import SwiftUI

struct EntrarCasaView: View {
    @ObservedObject var viewModel: HouseProfileViewModel
    @State private var navegarParaProxima = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Digite um código de convite")
                .font(.title2)

            TextField("Código", text: $viewModel.codigoConviteInput)
                .textFieldStyle(.roundedBorder)

            Button("Entrar na casa") {
                Task {
                    await viewModel.entrarComCodigoConvite()
                    navegarParaProxima = true
                }
            }
            .buttonStyle(.borderedProminent)

            NavigationLink(destination: CasaCriadaView(viewModel: viewModel), isActive: $navegarParaProxima) {
                EmptyView()
            }
        }
        .padding()
    }
}
