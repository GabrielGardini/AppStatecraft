import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @State private var navegarParaProximaEtapa = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // ✅ Ícone central
            Image("imagemlogin")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)

          

            Text("Bem vindo ao Habby!")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .padding(10)


            // ✅ Botão de login
            Button(action: {
                houseViewModel.verificarConta()
                navegarParaProximaEtapa = true
            }) {
                Label("Entrar com iCloud", systemImage: "icloud")
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.0, green: 0.4, blue: 0.0)) // verde escuro
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            Spacer()

            NavigationLink(
                destination: EntrarOuCriarCasaView()
                    .environmentObject(appState)
                    .environmentObject(houseViewModel),
                isActive: $navegarParaProximaEtapa
            ) {
                EmptyView()
            }

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // fundo branco total
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
}
