import SwiftUI
import CloudKit

struct MuralView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var tasksViewModel: TasksViewModel
    @ObservedObject var messageViewModel: MessageViewModel
    @State private var mostrarModalNovoAviso = false
        
    @State private var filtroData = Date()     // a filtro de mes e ano atual
    
    var percentageDone: Double {
        let calendar = Calendar.current
        let filtroMes = calendar.component(.month, from: filtroData)
        let filtroAno = calendar.component(.year, from: filtroData)

        let tarefasDoMes = tasksViewModel.tarefas.filter { tarefa in
            let tarefaMes = calendar.component(.month, from: tarefa.prazo)
            let tarefaAno = calendar.component(.year, from: tarefa.prazo)
            return tarefaMes == filtroMes && tarefaAno == filtroAno
        }

        guard !tarefasDoMes.isEmpty else { return -1 } // se nao tem nada, ele fica neutro

        let tarefasCompletas = tarefasDoMes.filter { $0.completo }
        return Double(tarefasCompletas.count) / Double(tarefasDoMes.count)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("LaranjaFundoMural"), Color("BackgroundColor")],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.2)
            )
                .ignoresSafeArea()
            
            ScrollView {
                ProgressoTarefasCard(percentageDone: percentageDone)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer().frame(height: 10)
                if messageViewModel.mensagens.filter { Calendar.current.startOfDay(for: $0.timestamp) >= Calendar.current.startOfDay(for: Date()) }.isEmpty  {
                        VStack{
                            
                            Text("Clique em \"+\" e crie um aviso")
                                .foregroundColor(.gray)
                                .padding(.vertical)
                            Image("listavazia")
                        }
                        
                    }
                ForEach(
                    messageViewModel.mensagens
                        .filter { Calendar.current.startOfDay(for: $0.timestamp) >= Calendar.current.startOfDay(for: Date()) }
                        .sorted(by: { $0.timestamp < $1.timestamp }),
                    id: \.id
                ) { aviso in
                    
                    AvisoView(messageViewModel: messageViewModel, aviso: aviso)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
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
                        .foregroundColor(.black)
                }
                .accessibilityLabel("Adicionar")
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
            
            Text(formatarData(aviso.timestamp))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer().frame(height: 4)
            
            Text(aviso.content)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("aviso de \(nomeDoUsuario): \(aviso.title). Dia \(formatarData(aviso.timestamp)). descrição: \(aviso.content)")
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
    func formatarData(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
struct ProgressoTarefasCard: View {
    var percentageDone: Double  // Ex: 0.75 = 75%
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.5)
            )
                .cornerRadius(12)
                .shadow(radius: 4)
            
            HStack(spacing: 20) {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 10)
                        
                        Circle()
                            .trim(from: 0, to: percentageDone >= 0.0 ? percentageDone : 0.0)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .shadow(color: .white.opacity(0.6), radius: 4, x: 0, y: 2)
                        
                    }
                    .frame(width: 60, height: 60)
                    
                    Text(
                        percentageDone >= 0.0 ? "Tarefas \(Int(percentageDone * 100))% feitas" :
                                                "Não há tarefas no mês")
                        .font(.caption)
                        .foregroundColor(.white)
                        .bold()
                }
                
                Spacer()
                
                GeometryReader { geo in
                    Image(bichinhoImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                    
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .frame(height: 130)
    }
    
    var bichinhoImageName: String {
        switch percentageDone {
        case 0..<0.2:
            return "bichinhomuitotriste"
        case 0.2..<0.4:
            return "bichinhotriste"
        case 0.4..<0.6:
            return "bichinhoneutro"
        case 0.6..<0.8:
            return "bichinhojoia"
        case 0.8...1:
            return "bichinhonirvana"
        default:
            return "bichinhoneutro"
        }
    }
    
    var gradientColors: [Color] {
        switch percentageDone {
        case 0..<0.2:
            return [Color(hex: "703F11"), Color(hex: "8F4018")]
        case 0.2..<0.4:
            return [Color(hex: "DE9B5C"), Color(hex: "F09C15")]
        case 0.4..<0.6:
            return [Color(hex: "A4A36D"), Color(hex: "D8BF35")]
        case 0.6..<0.8:
            return [Color(hex: "628B63"), Color(hex: "BADEAB")]
        case 0.8...1:
            return [Color(hex: "4E7DC3"), Color(hex: "7D7DAF")]
        default:
            return [Color(hex: "A4A36D"), Color(hex: "D8BF35")]
        }
    }
}
