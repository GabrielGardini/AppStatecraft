import SwiftUI

struct CasaCriadaView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @State private var navegarParaApp = false

    var body: some View {
        VStack(spacing: 32) {

            Image("casalogin")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            VStack(spacing: 8) {
                Text("Pronto!")
                    .font(.title)
                    .bold()

                Text("Agora você pode convidar\nmais moradores através do\ncódigo de convite:")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundColor(.primary)
            }

            if let codigo = houseViewModel.houseModel?.inviteCode {
                HStack {
                    Text(codigo)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)

                    Button(action: {
                        UIPasteboard.general.string = codigo
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                .padding(.horizontal)
            }

            Button(action: {
                navegarParaApp = true
            }) {
                Text("Continuar")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            NavigationLink(
                destination: MainAppView()
                            .environmentObject(houseViewModel)
                            .environmentObject(appState),
                isActive: $navegarParaApp) {
                EmptyView()
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
