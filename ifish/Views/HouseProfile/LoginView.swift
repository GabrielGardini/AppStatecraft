import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: HouseProfileViewModel
    @State private var navegarParaProximaEtapa = false

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 100, height: 100)

            Text("Nome do App")
                .font(.title)
                .bold()

            Button(action: {
                viewModel.verificarConta()
                navegarParaProximaEtapa = true
            }) {
                Label("Entrar com iCloud", systemImage: "icloud")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex:"#134700"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            NavigationLink(destination: EntrarOuCriarCasaView(viewModel: viewModel), isActive: $navegarParaProximaEtapa) {
                EmptyView()
            }
        }
        .padding()
    }
}
