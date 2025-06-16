import SwiftUI

struct CasaCriadaView: View {
    @ObservedObject var viewModel: HouseProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.fill")
                .font(.largeTitle)
                .foregroundColor(.green)

            Text("Pronto!")
                .font(.title2)
                .bold()

            Text("Agora você pode convidar mais moradores através do código:")
                .multilineTextAlignment(.center)

            if let codigo = viewModel.casaRecord?["InviteCode"] as? String {
                HStack {
                    Text(codigo)
                        .font(.title3)
                        .bold()
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button(action: {
                        UIPasteboard.general.string = codigo
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }

            Button("Continuar") {
                // navegue para tela principal do app
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
