import SwiftUI

struct PerfilView: View {
    @StateObject var viewModel = HouseProfileViewModel()

    var body: some View {
        ZStack {
            Color(red: 249/255, green: 249/255, blue: 249/255) // #F9F9F9
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // 🏠 Ícone e título fixo "Minha casa"
                VStack {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 75, height: 60)
                        .foregroundColor(.green)

                    Text("Minha casa")
                        .font(.system(size: 24, weight: .semibold))
                      .font(Font.custom("SF Pro", size: 24))
                      .multilineTextAlignment(.center)
                      .foregroundColor(.black)
                      .frame(width: 190, height: 39, alignment: .top)
                                }
                HStack{
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#E1E1E1"))
                        .frame(width: 327, height: 106)
//                    Text(casaID)
                        .font(.custom("SF Pro", size: 24))

                        .foregroundColor(.black)
                        .frame(height: 39)
                        .multilineTextAlignment(.center)
                }

                // 🧑‍🤝‍🧑 Agora o título dinâmico com nome da casa
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.nomeCasaUsuario.isEmpty ? "Nome da casa não disponível" : viewModel.nomeCasaUsuario)
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 4)

                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 8) {
                            if viewModel.usuariosDaCasa.isEmpty {
                                Text("Nenhum usuário encontrado.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.usuariosDaCasa, id: \.id) { usuario in
                                    HStack {
                                        Image(systemName: "person.crop.circle")
                                            .foregroundColor(.blue)
                                        Text(usuario.name)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "#E1E1E1"))
                    )
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            Task {
                await viewModel.verificarSeUsuarioJaTemCasa()
            }
        }
    }
}
