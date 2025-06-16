import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = HouseProfileViewModel()
    @State private var navegarParaProximaEtapa = false

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "bird.fill") // substitua pela sua imagem
                .resizable()
                .frame(width: 100, height: 100)

            Text("Nome do App")
                .font(.title)

            Button(action: {
                print("1")
                viewModel.verificarConta()
                print("2")
                navegarParaProximaEtapa = true
            }) {
                Label("Entrar com iCloud", systemImage: "icloud")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
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
