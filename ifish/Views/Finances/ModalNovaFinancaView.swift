
import Foundation
import SwiftUI

struct ModalNovaFinancaView: View {
    @ObservedObject var financeViewModel: FinanceViewModel
    @Environment(\.dismiss) var fecharModalNovaFinanca
    @State private var nomeFinanca: String = ""
    @State private var valor: Double = 0.0
    @State private var dataVencimento: Date = Date()
    @State private var repetirMensalmente: Bool = true
    @State private var notificacoesFinanca: Bool = true
    var onSave: (() -> Void)? = nil


    
    @State private var numberFormatter: NumberFormatter = {
        var numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Título", text: $nomeFinanca)
                    TextField("Valor", value: $valor, formatter: numberFormatter)
                }

                Section {
                    DatePicker("Vencimento", selection: $dataVencimento, displayedComponents: [.date])
                }

                Section {
                    Toggle("Repetir mensalmente", isOn: $repetirMensalmente)
                }
                
                Section{
                    Toggle("Notificação", isOn: $notificacoesFinanca)
                }
            }
            .navigationTitle("Nova Despesa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharModalNovaFinanca()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        Task{
                            await financeViewModel.criarDespesa(amount: valor, deadline: dataVencimento, paidBy: [], title: nomeFinanca, notification: notificacoesFinanca, shouldRepeat: repetirMensalmente)
                            fecharModalNovaFinanca()}
                    } .disabled(nomeFinanca == "" || valor == 0.0)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}









