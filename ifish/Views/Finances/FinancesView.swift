import SwiftUI
import CloudKit

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2)
)

struct FinancesView: View {
    @State private var selecao = "Pendentes"
    let opcoes = ["Pendentes", "Pagas por todos"]
    @State private var mostrarModalNovaFinanca = false
    @State private var mostrarModalInfo = false
    @StateObject var viewModel = HouseProfileViewModel()
    @StateObject var appState = AppState()
    @StateObject var financeViewModel: FinanceViewModel
    @State private var despesaSelecionada: FinanceModel? = nil
    @State var nomeUsuario: String = ""
    @State private var filtroDataDespesa = Date()
    
    init() {
        let vm = HouseProfileViewModel()
        let appState = AppState()
        _viewModel = StateObject(wrappedValue: vm)
        _financeViewModel = StateObject(wrappedValue: FinanceViewModel(houseProfileViewModel: vm, appState: appState))
    }
    
    func setNomeUsuario() async {
        guard let userRecordID = try? await CKContainer.default().userRecordID() else {
            print("❌ Não foi possível obter o userRecordID")
            return
        }
        
        let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)
        await nomeUsuario = financeViewModel.descobrirNomeDoUsuario(userID: userReference)
    }
    
    @ViewBuilder
    func itemLista(_ despesa: FinanceModel) -> some View {
        DespesaEspecifica(despesa: despesa, viewModel: viewModel, nomeUsuario: nomeUsuario)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 3)
            .listRowInsets(EdgeInsets())
            .padding(.vertical, 4)
            .onTapGesture {
                mostrarModalInfo = true
                despesaSelecionada = despesa
            }
    }
    
    
    var despesasFiltradas: [FinanceModel] {
        let totalPessoas = viewModel.usuariosDaCasa.count
        guard totalPessoas > 0 else { return [] }
        
        
        switch selecao {
        case "Pendentes":
            return financeViewModel.despesas.filter { $0.paidBy.count < totalPessoas}
        case "Pagas por todos":
            return financeViewModel.despesas.filter { $0.paidBy.count >= totalPessoas}
        default:
            return financeViewModel.despesas
        }
    }
    
    var despesasAtrasadas: [FinanceModel] {
        let hoje = Calendar.current.startOfDay(for: Date())
        return financeViewModel.despesas.filter {
            !$0.paidBy.contains(nomeUsuario) && $0.deadline < hoje
        }
    }
    
    var despesasPendentes: [FinanceModel]{
        let hoje = Calendar.current.startOfDay(for: Date())
        return financeViewModel.despesas.filter {
            !$0.paidBy.contains(nomeUsuario) && $0.deadline >= hoje
        }
    }
    
    var despesasPagasPorVoce: [FinanceModel]{
        return financeViewModel.despesas.filter {
            $0.paidBy.contains(nomeUsuario)
        }
    }
    
    var despesasPagasPorTodos: [FinanceModel] {
        return financeViewModel.despesas.filter {
            $0.paidBy.count >= viewModel.usuariosDaCasa.count
        }
    }
    

    
    var body: some View {
        ZStack {
            fundoFinances
                .ignoresSafeArea()
            VStack{
                Picker("",selection: $selecao){
                    ForEach(opcoes, id: \.self) { opcao in
                        Text(opcao)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                ScrollView{
                    LazyVStack (alignment: .leading, spacing: 16){
                        switch selecao {
                        case "Pendentes":
                            if despesasPendentes.isEmpty && despesasPagasPorVoce.isEmpty && despesasAtrasadas.isEmpty{
                                VStack(spacing: 8) {
                                    Text("Nenhuma despesa pendente 🎉!")
                                        .foregroundColor(.gray)

                                    Image("listavazia")
                                  
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                            }

                            if !despesasAtrasadas.isEmpty {
                                VStack(alignment: .leading, spacing: 0){
                                    Text("Atrasadas")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    ForEach(despesasAtrasadas.sorted(by: {$0.deadline < $1.deadline}), id: \.id) { despesa in
                                        itemLista(despesa).shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 4)

                                    }
                                }
                            }
                            
                            if !despesasPendentes.isEmpty {
                                VStack(alignment: .leading, spacing: 0){
                                    Text("Pendentes")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    ForEach(despesasPendentes.sorted(by: {$0.deadline < $1.deadline}), id: \.id) { despesa in
                                        itemLista(despesa).shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 4)
                                    }
                                }
                            }
                            
                            if !despesasPagasPorVoce.isEmpty {
                                VStack(alignment: .leading, spacing: 0){
                                    Text("Pagas por você")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    ForEach(despesasPagasPorVoce.sorted(by: {$0.deadline < $1.deadline}), id: \.id) { despesa in
                                        itemLista(despesa).shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 4)
                                    }
                                }
                            }
                            
                        case "Pagas por todos":
                            HStack {
                                Button(action: {
                                       filtroDataDespesa = Calendar.current.date(byAdding: .month, value: -1, to: filtroDataDespesa) ?? filtroDataDespesa
                                }) {
                                   Text("<")
                                       .font(.title2)
                                       .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()
                                
                                Button(action: {
                                    filtroDataDespesa = Date()
                                }) {
                                    Text(filtroDataDespesa.formatadoMesAno())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                                
                                Button(action: {
                                       filtroDataDespesa = Calendar.current.date(byAdding: .month, value: 1, to: filtroDataDespesa) ?? filtroDataDespesa
                                }) {
                                   Text(">")
                                       .font(.title2)
                                       .padding(.horizontal)
                               }
                                .buttonStyle(PlainButtonStyle())

                            }
                            let despesasFiltradas = despesasPagasPorTodos
                                .sorted(by: { $0.deadline < $1.deadline })
                                .filter { $0.deadline.mesEAno == filtroDataDespesa.mesEAno }

                            
                            if despesasFiltradas.isEmpty {
                                VStack(spacing: 8) {
                                    Text("Nenhuma despesa encontrada para este mês.")
                                        .foregroundColor(.gray)
                                    Image("listavazia")
                                   
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                            } else {
                                ForEach(despesasFiltradas, id: \.id) { despesa in
                                    itemLista(despesa)
                                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 4)
                                }
                            }
                            /*ForEach(despesasPagasPorTodos.sorted(by: {$0.deadline < $1.deadline}).filter {
                                $0.deadline.mesEAno == filtroDataDespesa.mesEAno
                            }, id: \.id) { despesa in
                                itemLista(despesa).shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 4)
                            }*/
                        default:
                            EmptyView()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                //.listStyle(PlainListStyle())
                .background(Color.clear)
                .padding(.horizontal, 24)
                .navigationTitle("Despesas")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            mostrarModalNovaFinanca = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        }
                        .accessibilityLabel("adicionar")
                    }
                }
                .sheet(isPresented: $mostrarModalNovaFinanca) {
                    ModalNovaFinancaView(financeViewModel: financeViewModel)
                }
                .sheet(item: $despesaSelecionada) { despesa in
                    ModalInfoDespesasView(financeViewModel: financeViewModel, despesa: despesa, valorIndividual: DespesaEspecifica(despesa: despesa, viewModel: viewModel, nomeUsuario: nomeUsuario).valorIndividualConta)
                        .onDisappear {
                            despesaSelecionada = nil
                        }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.verificarConta()
                await setNomeUsuario()
            }
        }
        .onReceive(viewModel.$houseModel) { novoModelo in
            if novoModelo != nil {
                Task {
                    await financeViewModel.buscarDespesasDaCasa()
                    let totalPessoas = viewModel.usuariosDaCasa.count
                                if totalPessoas > 0 {
                                    await criarDespesaMensal(financeViewModel: financeViewModel, totalPessoas: totalPessoas)
                    }
                }
            }
        }
    }
}




struct DespesaEspecifica: View {
    var despesa: FinanceModel
    @ObservedObject var viewModel: HouseProfileViewModel
    var nomeUsuario:String
    
    var numeroMoradores: Int {
        viewModel.usuariosDaCasa.count
    }
    
    var valorIndividualConta: Double {
        return despesa.amount / Double(numeroMoradores)
    }
    
    
    var nomeImagem: some View {
        if despesa.paidBy.contains(nomeUsuario) {
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        } else {
            return Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        }
    }
    
    var corTexto: Color{
        let hoje = Calendar.current.startOfDay(for: Date())
        if despesa.deadline < hoje && !despesa.paidBy.contains(nomeUsuario){
            return .red
        }
        else{
            return .black
        }
    }
    
    
    var body: some View {
        HStack{
            nomeImagem
            VStack(alignment: .leading){
                Text(despesa.title)
                    .font(.system(size: 17))
                    .foregroundColor(corTexto)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            despesa.paidBy.contains(nomeUsuario)
            ? "\(despesa.title). No valor de \((valorIndividualConta), specifier: "%.2f") reais já foi paga por você. Vencimento dia \(despesa.deadline.formatted(date: .numeric, time: .omitted)). Valor total: \(despesa.amount, specifier: "%.2f") reais"
            : "\(despesa.title). No valor de \((valorIndividualConta), specifier: "%.2f") reais ainda não foi paga por você. Vencimento dia \(despesa.deadline.formatted(date: .numeric, time: .omitted)).  Valor total: \(despesa.amount, specifier: "%.2f") reais"
        )

    }
}



func formatarData(_ data: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.string(from: data)
}

extension Date {
    var mesEAno: (Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: self)
        return (components.month ?? 0, components.year ?? 0)
    }
}

@MainActor
func criarDespesaMensal(financeViewModel: FinanceViewModel, totalPessoas: Int) async {
    let duasSemanasAtras = Calendar.current.date(byAdding: .day, value: -14, to: Date())!

    let despesasRepetidas = financeViewModel.despesas
        .filter { $0.shouldRepeat == true &&
                  $0.deadline <= duasSemanasAtras
        }

    for despesa in despesasRepetidas {
        if let novaData = Calendar.current.date(byAdding: .month, value: 1, to: despesa.deadline) {
            
            let jaExiste = financeViewModel.despesas.contains {
                $0.title == despesa.title &&
                Calendar.current.isDate($0.deadline, inSameDayAs: novaData)
            }

            if !jaExiste {
                await financeViewModel.criarDespesa(
                    amount: despesa.amount,
                    deadline: novaData,
                    paidBy: [],
                    title: despesa.title,
                    notification: despesa.notification,
                    shouldRepeat: despesa.shouldRepeat
                )
            }
        }
    }
}
