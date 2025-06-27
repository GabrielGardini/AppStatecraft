import SwiftUI
import CloudKit

struct MuralView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var messageViewModel: MessageViewModel
    @State private var mostrarModalNovoAviso = false

    var body: some View {
                ZStack {
            LinearGradient(
                colors: [Color("LaranjaFundoMural"), Color("BackgroundColor")],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.2)
            )
            .ignoresSafeArea()

            ScrollView {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)

                Spacer().frame(height: 10)

                ForEach(messageViewModel.mensagens, id: \.id) { aviso in
                    AvisoView(messageViewModel: messageViewModel, aviso: aviso)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    Spacer().frame(height: 10)
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("Mural")
            .sheet(isPresented: $mostrarModalNovoAviso) {
                NovoAvisoModalView()        .environmentObject(messageViewModel)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await messageViewModel.houseProfileViewModel?.verificarSeUsuarioJaTemCasa()
            await messageViewModel.buscarMensagens()
//            print(appState.casaID)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mostrarModalNovoAviso = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
            }
        }
        
    }
}

struct AvisoView: View {
    @ObservedObject var messageViewModel: MessageViewModel

    let aviso: MessageModel
    @State private var mostrarModalEditarAviso = false
    @State private var nomeDoUsuario: String = "Carregando..."

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Aviso")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("LaranjaMural"))

                Text("•")
                    .font(.headline)

                Text(nomeDoUsuario)
                    .font(.subheadline)
//                    .foregroundColor(.gray)

                Spacer()

                Button(action: {
                    mostrarModalEditarAviso = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
            .padding(.bottom, 4)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .bottom
            )

            Spacer().frame(height: 4)

            Text(aviso.title)
                .font(.headline)

            Spacer().frame(height: 4)

            Text(aviso.content)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .task {
            nomeDoUsuario = await messageViewModel.descobrirNomeDoUsuario(userID: aviso.userID)
        }
        .sheet(isPresented: $mostrarModalEditarAviso) {
            EditarAvisoModalView(aviso: aviso).environmentObject(messageViewModel)
        }
    }
}
