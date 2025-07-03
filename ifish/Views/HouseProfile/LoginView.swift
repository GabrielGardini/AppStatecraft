import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var houseViewModel: HouseProfileViewModel

    @State private var navegarParaProximaEtapa = false
    
    var body: some View {
        VStack {
            Image("bichinhologin")//                .frame(width: 100, height: 100)
            
            Text("Bem vindo ao Habby")
                .font(.title)
                .bold()
            
            Button(action: {
                houseViewModel.verificarConta()
                navegarParaProximaEtapa = true
            }) {
                Label("Entrar com iCloud", systemImage: "icloud")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            NavigationLink(
                destination: EntrarOuCriarCasaView()
                    .environmentObject(appState)
                    .environmentObject(houseViewModel),
                isActive: $navegarParaProximaEtapa) {
                EmptyView()
            }
        }.frame(maxWidth: .infinity,
                maxHeight: .infinity)
            .background(Color("BackgroundColor"))
            .navigationBarBackButtonHidden(true)
        
    }
    
}

