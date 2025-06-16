import SwiftUI

struct CriarCasaView: View {
    @ObservedObject var viewModel: HouseProfileViewModel
    @State private var navegarParaConfirmacao = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.largeTitle)
                .foregroundColor(.green)

            Text("Crie sua casa")
                .font(.title2)

            TextField("Nome da casa", text: $viewModel.casaNomeInput)
                .textFieldStyle(.roundedBorder)

            Button("Criar Casa") {
                Task {
                    await viewModel.criarCasa()
                    navegarParaConfirmacao = true
                }
            }
            .buttonStyle(.borderedProminent)

            NavigationLink(destination: CasaCriadaView(viewModel: viewModel), isActive: $navegarParaConfirmacao) {
                EmptyView()
            }
        }
        .padding()
    }
}
