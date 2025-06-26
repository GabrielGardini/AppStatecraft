import SwiftUI
import CloudKit

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2)
)

struct FinancesView: View {
    @State private var mostrarModalNovaFinanca = false
    @State private var mostrarModalInfo = false
    @StateObject var viewModel = HouseProfileViewModel()
    @StateObject var appState = AppState()
    @StateObject var financeViewModel: FinanceViewModel
    @State private var despesaSelecionada: FinanceModel? = nil

    @State private var teste = 0

    init() {
        let vm = HouseProfileViewModel()
        let appState = AppState()
        _viewModel = StateObject(wrappedValue: vm)
        _financeViewModel = StateObject(wrappedValue: FinanceViewModel(houseProfileViewModel: vm, appState: appState))
    }
    

    var body: some View {
        ZStack {
            fundoFinances
                .ignoresSafeArea()

            List(financeViewModel.despesas, id: \.id) { despesa in
                DespesaEspecifica(despesa: despesa, viewModel: viewModel)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 3)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 4)
                    .onTapGesture{
                        mostrarModalInfo = true
                        despesaSelecionada = despesa
                    }

            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .padding(.horizontal, 16)
            .navigationTitle("Despesas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarModalNovaFinanca = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarModalNovaFinanca) {
                ModalNovaFinancaView(financeViewModel: financeViewModel)
            }
            .sheet(item: $despesaSelecionada) { despesa in
                ModalInfoDespesasView(financeViewModel: financeViewModel, despesa: despesa, valorIndividual: DespesaEspecifica(despesa: despesa, viewModel: viewModel).valorIndividualConta)
                    .onDisappear {
                        despesaSelecionada = nil
                    }
            }
        }
        .onAppear {
            Task {
                await viewModel.verificarConta()
            }
        }
        .onReceive(viewModel.$houseModel) { novoModelo in
            if novoModelo != nil {
                Task {
                    await financeViewModel.buscarDespesasDaCasa()
                }
            }
        }
    }
}




struct DespesaEspecifica: View {
    var despesa: FinanceModel
    @ObservedObject var viewModel: HouseProfileViewModel

    var numeroMoradores: Int {
        viewModel.usuariosDaCasa.count
    }

    var valorIndividualConta: Double {
        return despesa.amount / Double(numeroMoradores)
    }
    
    var body: some View {
        HStack{
            Image(systemName: "checkmark.circle.fill")
            VStack(alignment: .leading){
                Text(despesa.title)
                    .font(.system(size: 17))
                Text("Vencimento: \(despesa.deadline.formatted(date: .numeric, time: .omitted))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

            }
            Spacer()
            VStack{
                Text("R$ \(valorIndividualConta, specifier: "%.2f")")
                    .font(.system(size: 14))
                Text("Total: R$ \(despesa.amount, specifier: "%.2f")")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}
}


func formatarData(_ data: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.string(from: data)
}
