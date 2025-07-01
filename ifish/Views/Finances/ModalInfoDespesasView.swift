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
    @State var jaPagou = false
    @State var nomeUsuario: String = ""

    init(financeViewModel: FinanceViewModel, despesa: FinanceModel, valorIndividual: Double) {
        self.despesa = despesa
        self.valorIndividual = valorIndividual
        self.financeViewModel = financeViewModel
        _pagos = State(initialValue: despesa.paidBy)
    }
    
    func usuarioPagou() async{
        guard let userRecordID = try? await CKContainer.default().userRecordID() else {
            print("❌ Não foi possível obter o userRecordID")
            return
        }

        let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)

        if(despesa.paidBy.contains(await financeViewModel.descobrirNomeDoUsuario(userID: userReference))){
            self.jaPagou = true
        } else {
            self.jaPagou = false
        }
    }
    
    func setNomeUsuario() async {
        guard let userRecordID = try? await CKContainer.default().userRecordID() else {
            print("❌ Não foi possível obter o userRecordID")
            return
        }

        let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)
        await nomeUsuario = financeViewModel.descobrirNomeDoUsuario(userID: userReference)
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Text(despesa.title)
                    .font(.system(size: 24))
                    .padding(.vertical, 5)
                Text("Prazo")
                    .font(.system(size: 20))
                    .bold()
                Text(despesa.deadline.formatted(date: .numeric, time: .omitted))
                Spacer()
                Section{
                    HStack{
                        Text("Valor individual")
                        Spacer()
                        Text("R$ \(valorIndividual, specifier: "%.2f")")
                            .foregroundColor(.gray)
                    }
                    Divider()
                        .frame(height: 0.5)
                        .foregroundColor(.gray)
                    HStack{
                        Text("Total")
                        Spacer()
                        Text("R$ \(despesa.amount, specifier: "%.2f")")
                            .foregroundColor(.gray)
                    }
                    //não tem ocorrencia no banco, nem descrição
                }
                .task{
                   await usuarioPagou()
                    await setNomeUsuario()
                    
                }
                Spacer()
                Section{
                        ForEach(financeViewModel.houseProfileViewModel.usuariosDaCasa, id: \.self) { pessoa in
                            InfoPessoasPagaram(pessoa: pessoa.name, pagos: pagos)
                        }
                }
                Spacer()
                HStack{
                    Spacer()
                    if(jaPagou == false){
                        Button("Marcar como pago"){
                            Task{
                                despesa.paidBy.append(nomeUsuario)
                                await financeViewModel.editarDespesa(despesa)
                                pagos = despesa.paidBy
                                jaPagou = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Desmarcar como pago"){
                            Task{
                                jaPagou = false
                                despesa.paidBy.removeAll { $0 == nomeUsuario }
                                await financeViewModel.editarDespesa(despesa)
                                pagos = despesa.paidBy
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
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

struct InfoPessoasPagaram: View {
    var pessoa: String
    var pagos: [String]

    var pago: Bool {
        pagos.contains(pessoa)
    }

    var body: some View {
            HStack {
                Text(pessoa)
                Spacer()
                if pago {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                }
            }
            .padding(3)
    }
}

