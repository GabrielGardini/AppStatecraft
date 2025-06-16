import SwiftUI

struct EntrarOuCriarCasaView: View {
    @ObservedObject var viewModel: HouseProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Entre com um código de convite")
                .font(.headline)

            NavigationLink("Entrar na casa") {
                EntrarCasaView(viewModel: viewModel)
            }
            .buttonStyle(.borderedProminent)

            Text("Ainda não possui uma casa?")

            NavigationLink("Criar Casa") {
                CriarCasaView(viewModel: viewModel)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
