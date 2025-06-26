//
//  ModalInfoDespesasView.swift
//  ifish
//
//  Created by Aluno 21 on 26/06/25.
//

import Foundation
import CloudKit
import SwiftUI

struct ModalInfoDespesasView: View {
    @State private var mostrarModalEditar = false
    @ObservedObject var financeViewModel: FinanceViewModel
    @Environment(\.dismiss) var fecharModalInfo
    var despesa: FinanceModel
    var valorIndividual: Double
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Text(despesa.title)
                    .font(.system(size: 24))
                Text("Prazo")
                    .font(.system(size: 20))
                Text(despesa.deadline.formatted(date: .numeric, time: .omitted))
                Spacer()
                Section{
                    HStack{
                        Text("Total")
                        Spacer()
                        Text("R$ \(despesa.amount, specifier: "%.2f")")
                    }
                    HStack{
                        Text("Total")
                        Spacer()
                        Text("R$ \(valorIndividual, specifier: "%.2f")")
                    }
                    //não tem ocorrencia no banco, nem descrição
                }
                Spacer()
                Section{
                    ForEach(despesa.paidBy, id: \.self){ pessoa in
                        Text(pessoa)
                    }
                }
                HStack{
                    Spacer()
                    Button("Pago"){
                        Task{
                           await financeViewModel.marcarComoPago(despesa: despesa, nomeUsuario: "Isabel")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        fecharModalInfo()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Editar") {
                        mostrarModalEditar = true
                    }
                }
            }

        }
        .sheet(isPresented: $mostrarModalEditar) {
            ModalEditarFincancaView(financeViewModel: financeViewModel, despesa: despesa)
        }
    }
}

