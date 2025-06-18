import SwiftUI

struct CriarCasaView: View {
    @ObservedObject var viewModel: HouseProfileViewModel
    @State private var navegarParaConfirmacao = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(Color.accentColor)

                VStack(spacing: 8) {
                    Text("Crie sua casa")
                        .font(.title)
                        .bold()

                    Text("Escolha um nome\npara sua casa")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                TextField("Nome da casa", text: $viewModel.casaNomeInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Spacer()
                            if !viewModel.casaNomeInput.isEmpty {
                                Button(action: {
                                    viewModel.casaNomeInput = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 8)
                            }
                        }
                    )

                Button(action: {
                    Task {
                        await viewModel.criarCasa()
                        navegarParaConfirmacao = true
                    }
                }) {
                    Text("Criar Casa")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.casaNomeInput.isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.casaNomeInput.isEmpty)

                Spacer()

                NavigationLink(destination: CasaCriadaView(viewModel: viewModel), isActive: $navegarParaConfirmacao) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}
