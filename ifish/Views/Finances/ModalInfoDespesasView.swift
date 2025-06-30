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
    @State var pagos: [String]

    init(financeViewModel: FinanceViewModel, despesa: FinanceModel, valorIndividual: Double) {
        self.despesa = despesa
        self.valorIndividual = valorIndividual
        self.financeViewModel = financeViewModel
        _pagos = State(initialValue: despesa.paidBy)
    }
    
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
                        Text("Valor individual")
                        Spacer()
                        Text("R$ \(valorIndividual, specifier: "%.2f")")
                    }
                    //não tem ocorrencia no banco, nem descrição
                }
                Spacer()
                Section{
                    ForEach(pagos, id: \.self){ pessoa in
                        Text(pessoa)
                    }
                }
                HStack{
                    Spacer()
                    Button("Pago"){
                        Task{
                            guard let userRecordID = try? await CKContainer.default().userRecordID() else {
                                print("❌ Não foi possível obter o userRecordID")
                                return
                            }

                            let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)

                            await despesa.paidBy.append(financeViewModel.descobrirNomeDoUsuario(userID: userReference))
                            await financeViewModel.editarDespesa(despesa)
                           //await financeViewModel.marcarComoPago(despesa: despesa, nomeUsuario: "Isabel")
                            pagos = despesa.paidBy
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

