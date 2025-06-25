import SwiftUI
import CloudKit

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2)
)

struct FinancesView: View {
    @ObservedObject var viewModel: HouseProfileViewModel
    @StateObject private var financeViewModel: FinanceViewModel

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
                    Picker("teste", selection: $teste) {
                        Text("Pendentes").tag(0)
                        Text("Paga por todos").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
            }
            .navigationTitle("Despesas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await financeViewModel.criarDespesa(
                                amount: 100,
                                deadline: Date(),
                                paidBy: ["Gabriel"],
                                title: "Compras do mês"
                            )
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
