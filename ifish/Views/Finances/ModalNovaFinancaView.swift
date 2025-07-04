
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
    @State private var valorTexto: String = ""
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
                    TextField("Valor", text: $valorTexto)
                            .keyboardType(.decimalPad)
                            .onChange(of: valorTexto) { newValue in
                                let filtrado = newValue.filter { "0123456789.,".contains($0) }
                                if filtrado != newValue {
                                    valorTexto = filtrado
                                }

                                let convertido = filtrado.replacingOccurrences(of: ",", with: ".")
                                if let numero = Double(convertido) {
                                    valor = numero
                                }
                            }
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









