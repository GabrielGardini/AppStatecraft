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
    @State private var numberFormatter: NumberFormatter = {
        var numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    @ObservedObject var financeViewModel: FinanceViewModel
    @Environment(\.dismiss) var fecharModalEditar
    var despesa: FinanceModel
    
    @State private var nomeFinanca: String = ""
    @State private var valor: Double = 0.0
    @State private var dataVencimento: Date = Date()
    @State private var repetirMensalmente: Bool = true
    @State private var notificacoesFinanca: Bool = true
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("\(despesa.title)", text: $nomeFinanca)
                    TextField("teste", text: $nomeFinanca)
                    TextField("\(despesa.amount)", value: $valor, formatter: numberFormatter)
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
            }
            .navigationTitle("\(despesa.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharModalEditar()
                        print("\(despesa.title)")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task{
                            print("\(nomeFinanca)")
                            fecharModalEditar()}
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}


