//
//  ModalEditarFinancaView.swift
//  ifish
//
//  Created by Aluno 21 on 26/06/25.
//

import Foundation
import SwiftUI
import CloudKit

struct ModalEditarFincancaView: View {
    @Binding var mostrarModalInfo: Bool
    @State private var mostrarConfirmacaoApagar = false
    @State private var mostrarConfirmacaoCancelar = false
    @State private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()


    @ObservedObject var financeViewModel: FinanceViewModel
    @Environment(\.dismiss) var fecharModalEditar
    var despesa: FinanceModel
    var despesaInicial: FinanceModel
    
    @State private var nomeFinanca: String = ""
    @State private var valor: Double = 0.0
    @State private var dataVencimento: Date = Date()
    @State private var repetirMensalmente: Bool = true
    @State private var notificacoesFinanca: Bool = true
    @State private var valorTexto: String = ""

    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    

    init(financeViewModel: FinanceViewModel, despesa: FinanceModel, mostrarModalInfo: Binding<Bool>) {
        self._mostrarModalInfo = mostrarModalInfo
        self.financeViewModel = financeViewModel
        self.despesa = despesa
        _nomeFinanca = State(initialValue: despesa.title)
        _valor = State(initialValue: despesa.amount)
        _dataVencimento = State(initialValue: despesa.deadline)
        _repetirMensalmente = State(initialValue: despesa.shouldRepeat)
        _notificacoesFinanca = State(initialValue: despesa.notification)
        self.despesaInicial = despesa
        _valorTexto = State(initialValue: formatter.string(from: NSNumber(value: despesa.amount)) ?? "")
    }

    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    Section {
                        TextField("Título", text: $nomeFinanca)
                        //TextField("Valor", value: $valor, formatter: numberFormatter)
                        TextField("Valor total", text: $valorTexto)
                                .keyboardType(.decimalPad)
                                .onChange(of: valorTexto) { newValue in
                                    // Filtra: só números, ponto ou vírgula
                                    let filtrado = newValue.filter { "0123456789.,".contains($0) }
                                    if filtrado != newValue {
                                        valorTexto = filtrado
                                    }

                                    // Tenta converter para Double
                                    let convertido = filtrado.replacingOccurrences(of: ",", with: ".")
                                    if let numero = Double(convertido) {
                                        valor = numero
                                    }
                                }
                    }

                    Section {
                        DatePicker("Vencimento", selection: $dataVencimento, displayedComponents: [.date]) //ver como mostrar a data da despesa
                    }

                    Section {
                        Toggle("Repetir mensalmente", isOn: $repetirMensalmente) //same
                    }
                    
                    Section{
                        Toggle("Notificação", isOn: $notificacoesFinanca)//same
                    }
                    
                    HStack{
                        Spacer()
                        Button("Apagar despesa") {
                            mostrarConfirmacaoApagar = true
                        }
                        .foregroundColor(.red)
                        .confirmationDialog("Tem certeza que deseja apagar?", isPresented: $mostrarConfirmacaoApagar, titleVisibility: .visible) {
                            Button("Apagar despesa", role: .destructive) {
                                Task {
                                    await financeViewModel.apagarDespesa(despesa)
                                    mostrarModalInfo = false
                                    fecharModalEditar()
                                }
                            }
                            Button("Cancelar", role: .cancel) { }
                            .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                }
                
            }
            .navigationTitle("\(despesa.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        if(nomeFinanca == despesaInicial.title &&
                           valor == despesaInicial.amount &&
                           dataVencimento == despesaInicial.deadline){
                            fecharModalEditar()
                        }
                        else{
                            mostrarConfirmacaoCancelar = true
                        }
                    }
                    .confirmationDialog("Tem certeza de que deseja descartar as alterações?", isPresented: $mostrarConfirmacaoCancelar, titleVisibility: .visible){
                        Button("Ignorar alterações", role: .destructive){
                            Task {
                                fecharModalEditar()
                            }
                        }
                        Button("Continuar Editando", role: .cancel){}
                        .foregroundColor(.accentColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task{
                            despesa.title = nomeFinanca
                            despesa.amount = valor
                            despesa.deadline = dataVencimento
                            despesa.shouldRepeat = repetirMensalmente
                            despesa.notification = notificacoesFinanca
                            
                            await financeViewModel.editarDespesa(despesa)
                            fecharModalEditar()}
                    } .disabled(nomeFinanca == despesaInicial.title &&
                                valor == despesaInicial.amount &&
                                dataVencimento == despesaInicial.deadline)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear{
            nomeFinanca = despesa.title
            valor = despesa.amount
            dataVencimento = despesa.deadline
        }
    }
}

