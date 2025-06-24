import SwiftUI
import CloudKit

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2)
)

struct FinancesView: View {
    @State private var mostrarModalNovaFinanca = false
    @ObservedObject var viewModel = HouseProfileViewModel()
    @StateObject var financeViewModel: FinanceViewModel

    @State private var teste = 0

    init(viewModel: HouseProfileViewModel) {
        self._financeViewModel = StateObject(wrappedValue: FinanceViewModel(houseProfileViewModel: viewModel))
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                fundoFinances
                    .ignoresSafeArea()
                VStack {
                                    List(financeViewModel.despesas, id: \.id) { despesa in
                                        VStack(alignment: .leading) {
                                            Text(despesa.title)
                                                .font(.headline)
                                            Text("Valor: \(despesa.amount, specifier: "%.2f")")
                                            Text("Vencimento: \(despesa.deadline.formatted(date: .abbreviated, time: .omitted))")
                                        }
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(10)
                                    }
                                    .background(Color.clear) // Evita fundo branco da List
                                    .listStyle(PlainListStyle()) // Evita visual padrão de iOS
                                }
                                .padding(.top)
                .onAppear {
                    Task {
                        await financeViewModel.buscarDespesasDaCasa()
                    }
                }

            }
            .navigationTitle("Despesas")
            .toolbar { //botão de add
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarModalNovaFinanca = true
                    }) {
                        Image(systemName: "plus")
                    
                        /*Task {
                            /*await financeViewModel.criarDespesa(
                                amount: 100,
                                deadline: Date(),
                                paidBy: ["Gabriel"],
                                title: "Compras do mês"*/
                            )
                        }*/
                
            }
        }
    }
            .sheet(isPresented: $mostrarModalNovaFinanca) {
                ModalNovaFinancaView(financeViewModel: financeViewModel,
                                     onSave: {
                    Task {
                        await financeViewModel.buscarDespesasDaCasa()
                    }
                })
}
}
}
}


struct FinancesView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock simples de HouseProfileViewModel
        let mockViewModel = HouseProfileViewModel()
        FinancesView(viewModel: mockViewModel)
    }
}
