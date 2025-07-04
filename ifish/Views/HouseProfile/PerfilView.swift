import SwiftUI

struct PerfilView: View {
    @StateObject var viewModel = HouseProfileViewModel()
    @State private var showCopyMessage = false
    @State private var showExitAlert = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width * 0.9
            let heightMultiplier = geometry.size.height / 844

            ZStack {
                LinearGradient(
                    colors: [Color("AccentColor"), Color("BackgroundColor")],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.2)
                )
                .opacity(0.5)
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20 * heightMultiplier) {

                        // Bloco com nome da casa e mascote
                        VStack(spacing: 0) {
                            HStack {
                                Text(viewModel.nomeCasaUsuario.isEmpty ? "Nome da casa não disponível" : viewModel.nomeCasaUsuario)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .truncationMode(.tail)

                                Spacer()

                                Image("bichinhocortado")
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, -2)
                            .background(Color("AccentColor"))
                            .clipShape(RoundedCorner(radius: 6, corners: [.topLeft, .topRight]))
                            .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("Moradores")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)

                                VStack(spacing: 16.5) {
                                    if viewModel.usuariosDaCasa.isEmpty {
                                        Text("Nenhum usuário encontrado.")
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 24)
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
                                            .padding(.horizontal, 24)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                            .frame(width: width)
                            .background(Color.white)
                            .clipShape(RoundedCorner(radius: 6, corners: [.bottomLeft, .bottomRight]))
                            .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)
                        }
                        .padding(.top)
                        .padding(.horizontal, 24)

                        // Seção: Convidar membros
                        HStack {
                            Text("Convidar membros")
                                .foregroundColor(.black)

                            Spacer()

                            Text(viewModel.houseModel?.inviteCode ?? "-----")
                                .font(.system(size: 17))
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
                        .padding(.vertical, 14)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                        .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)

                        // Botão: Notificações
                        Button(action: {}) {
                            Text("Notificação")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .padding(.horizontal)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 24)
                        .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)

                        // Botão: Sair
                        Button("Sair", role: .destructive) {
                            showExitAlert = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                        .shadow(color: .black.opacity(0.07), radius: 3.5, x: 0, y: 4)
                        .alert("Sair da casa?", isPresented: $showExitAlert) {
                            Button("Cancelar", role: .cancel) {}
                            Button("Sair", role: .destructive) {
                                Task {
                                    await viewModel.sairDaCasa()
                                }
                            }
                        } message: {
                            Text("Tem certeza que deseja abandonar a casa? Você terá que ser convidado novamente para voltar à casa.")
                        }
                    }
                    .padding(.top)
                }

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
            .navigationTitle("Minha Casa")
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
