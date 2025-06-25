import SwiftUI
import CloudKit

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2)
)

struct FinancesView: View {
    @State private var mostrarModalNovaFinanca = false
    @StateObject var viewModel = HouseProfileViewModel()
    @StateObject var financeViewModel: FinanceViewModel

    @State private var teste = 0

    init() {
        let vm = HouseProfileViewModel()
        _viewModel = StateObject(wrappedValue: vm)
        _financeViewModel = StateObject(wrappedValue: FinanceViewModel(houseProfileViewModel: vm))
    }

    var body: some View {
        NavigationView {
            ZStack {
                fundoFinances
                    .ignoresSafeArea()
                VStack {
                                    List(financeViewModel.despesas, id: \.id) { despesa in
                                        DespesaEspecifica(despesa: despesa, viewModel: viewModel)
                                    }
                                    .background(Color.clear)
                                    .listStyle(PlainListStyle())
                                    .cornerRadius(10)
                                    .padding(24)
                                }
                                .padding(.top)
                .onAppear {
                    Task {
                        //await financeViewModel.buscarDespesasDaCasa()
                        await viewModel.verificarConta()
                        if viewModel.houseModel != nil {
                                    await financeViewModel.buscarDespesasDaCasa()
                                } else {
                                    print("⚠️ Nenhuma casa encontrada após verificarConta.")
                                }
                    }
                    print(viewModel.houseModel?.nome)
                }

            }
            .navigationTitle("Despesas")
            .toolbar { //botão de add
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
            VStack(alignment: .leading){
                Text(despesa.title)
                    .font(.headline)
                Text("Vencimento: \(formatarData(despesa.deadline))")
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
