import SwiftUI

struct EntrarOuCriarCasaView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @State private var navegarParaMain = false
    @State private var mostrarErro = false

    var body: some View {
        VStack(spacing: 32) {
            Image("bichinhologin")
//                .resizable()
//                .frame(width: 100, height: 100)

            VStack(spacing: 16) {
                Text("Entre com um código de convite")
                    .font(.headline)

                // Campo de código com botão de limpar
                HStack {
                    TextField("Digite o código", text: $houseViewModel.codigoConviteInput)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    if !houseViewModel.codigoConviteInput.isEmpty {
                        Button(action: {
                            houseViewModel.codigoConviteInput = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Botão: Entrar na casa
                Button(action: {
                    Task {
                        let sucesso = await houseViewModel.entrarComCodigoConvite()
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
                NavigationLink(
                    destination:
                        MainAppView()
                            .environmentObject(appState)
                            .environmentObject(houseViewModel),
                    isActive: $navegarParaMain) {
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
                    CriarCasaView()
                        .environmentObject(appState)
                        .environmentObject(houseViewModel)
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
