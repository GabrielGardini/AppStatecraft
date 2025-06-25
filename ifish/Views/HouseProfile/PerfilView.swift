import SwiftUI

struct PerfilView: View {
    @StateObject var viewModel = HouseProfileViewModel()
    @State private var showCopyMessage = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width * 0.9
            let heightMultiplier = geometry.size.height / 844

            ZStack {
                Color(red: 249/255, green: 249/255, blue: 249/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20 * heightMultiplier) {
                        
                        // 🏠 Ícone e Título
                        VStack(spacing: 8 * heightMultiplier) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 60, height: 50)
                                .foregroundColor(Color.accentColor)

                            Text("Minha casa")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)
                        }

                        // 🏷️ Nome da casa + mascote
                        VStack(spacing: 0) { HStack {
                            Text(viewModel.nomeCasaUsuario.isEmpty ? "Nome da casa não disponível" : viewModel.nomeCasaUsuario)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .layoutPriority(1)

                            Spacer(minLength: 20)

                            Image("mascote")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        .padding()
                        .frame(width: width, height: 106 * heightMultiplier)
                        .background(Color(red: 0.88, green: 0.88, blue: 0.88))
                        .clipShape(
                            RoundedCorner(radius: 6, corners: [.topLeft, .topRight])
                        )
                        .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)

                        // 👥 Moradores
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Moradores")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 22)
                                    .padding(.top)
                                    .padding(.bottom, 8)

                                ScrollView {
                                    VStack(spacing: 8 * heightMultiplier) {
                                        if viewModel.usuariosDaCasa.isEmpty {
                                            Text("Nenhum usuário encontrado.")
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 22)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        } else {
                                            ForEach(viewModel.usuariosDaCasa, id: \.id) { usuario in
                                                HStack(spacing: 10) {
                                                    Image(systemName: "person.crop.circle")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.gray)

                                                    Text(usuario.name)
                                                        .foregroundColor(.black)
                                                }
                                                .padding(.horizontal, 22)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                    }
                                    .padding(.bottom)
                                }
                                .frame(height: 247 * heightMultiplier) // altura fixa que limita o scroll
                            }
                            .frame(width: width)
                            .background(Color.white)
                            .clipShape(
                                RoundedCorner(radius: 6, corners: [.bottomLeft, .bottomRight])
                            )
                            .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)

                        .frame(width: width)
                        }
                        // 🔗 Convidar membros
                        HStack {
                            Text("Convidar membros")
                                .foregroundColor(.black)

                            Spacer()
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

                }

                            Text(viewModel.houseModel?.inviteCode ?? "-----")
                                .font(.headline)
                                .foregroundColor(Color.accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.green.opacity(0.2)))

                            Button {
                                if let codigo = viewModel.houseModel?.inviteCode {
                                    UIPasteboard.general.string = codigo
                                    showCopyMessage = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showCopyMessage = false
                                    }
                                }
                            } label: {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(Color.accentColor)
                                    .padding(5)
                                    .background(Circle().fill(Color.green.opacity(0.1)))
                            }
                        }
                        .padding(.horizontal)
                        .frame(width: width, height: 51 * heightMultiplier)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)

                        // 🔔 Botão Notificação
                        Button(action: {}) {
                            Text("Notificação")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .frame(width: width, height: 52 * heightMultiplier)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)
                        }

                        // 🚪 Botão Sair
                        Button(action: {}) {
                            Text("Sair")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .frame(width: width, height: 34.2 * heightMultiplier)
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                                .foregroundColor(.red)
    
                        }
                    }
                    .frame(width: geometry.size.width)
                    .padding(.top, -16)

                }

                // ✅ Feedback de cópia
                if showCopyMessage {
                    Text("Código copiado!")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.black.opacity(0.7)))
                        .foregroundColor(.white)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showCopyMessage)
                }
            }
            .onAppear {
                Task {
                    await viewModel.verificarSeUsuarioJaTemCasa()
                }
            }
        }
    }
}


struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
    }
}

// Arredondar cantos
struct RoundedCorner: Shape {
    var radius: CGFloat = 6.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
