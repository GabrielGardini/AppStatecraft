import SwiftUI

struct EntrarOuCriarCasaView: View {
    @ObservedObject var viewModel: HouseProfileViewModel
    @State private var navegarParaMain = false
    @State private var mostrarErro = false

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 100, height: 100)

            VStack(spacing: 16) {
                Text("Entre com um código de convite")
                    .font(.headline)

                // Campo de código com botão de limpar
                HStack {
                    TextField("Digite o código", text: $viewModel.codigoConviteInput)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    if !viewModel.codigoConviteInput.isEmpty {
                        Button(action: {
                            viewModel.codigoConviteInput = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Botão: Entrar na casa
                Button(action: {
                    Task {
                        let sucesso = await viewModel.entrarComCodigoConvite()
                        if sucesso {
                            navegarParaMain = true
                        } else {
                            mostrarErro = true
                        }
                    }
                }) {
                    Text("Entrar na casa")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // Navegação para a próxima tela se válido
                NavigationLink(destination: MainAppView(houseViewModel: viewModel), isActive: $navegarParaMain) {
                    EmptyView()
                }

                // Alerta de código inválido
                if mostrarErro {
                    Text("❌ Código inválido. Verifique e tente novamente.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            VStack(spacing: 8) {
                Text("Ainda não possui uma casa?")

                NavigationLink {
                    CriarCasaView(viewModel: viewModel)
                } label: {
                    Text("Criar Casa")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding()
    }
}
