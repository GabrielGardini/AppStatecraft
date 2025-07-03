import SwiftUI

struct CriarCasaView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @State private var navegarParaConfirmacao = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image("casalogin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
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

                TextField("Nome da casa", text: $houseViewModel.casaNomeInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Spacer()
                            if !houseViewModel.casaNomeInput.isEmpty {
                                Button(action: {
                                    houseViewModel.casaNomeInput = ""
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
                        await houseViewModel.criarCasa()
                        navegarParaConfirmacao = true
                    }
                }) {
                    Text("Criar Casa")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(houseViewModel.casaNomeInput.isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(houseViewModel.casaNomeInput.isEmpty)

                Spacer()

                NavigationLink(
                    destination: CasaCriadaView()
                                .environmentObject(appState)
                                .environmentObject(houseViewModel),
                    isActive: $navegarParaConfirmacao) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}
