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
    @Binding var mostrarModalInfo: Bool
    @State private var mostrarModalEditar = false
    @ObservedObject var financeViewModel: FinanceViewModel
    @Environment(\.dismiss) var fecharModalInfo
    var despesa: FinanceModel
    var valorIndividual: Double
    @State var pagos: [String]
    @State var jaPagou = false
    @State var nomeUsuario: String = ""

    init(financeViewModel: FinanceViewModel, despesa: FinanceModel, valorIndividual: Double, mostrarModalInfo: Binding<Bool>) {
        self._mostrarModalInfo = mostrarModalInfo
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
                    .font(.title)
                    .fontWeight(.semibold)
                    //.padding(.top)                    //.padding(.vertical, 5)
                    .padding(.bottom, 12)
                Text("Prazo")
                    .font(.callout)
                    .foregroundColor(.secondary)
                //Text(despesa.deadline.formatted(date: .numeric, time: .omitted))
                Text(despesa.deadline.formatted(.dateTime.day().month(.wide).year()))
                    .font(.body)
                    .padding(.bottom)

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
                }
                .task{
                   await usuarioPagou()
                    await setNomeUsuario()
                }
                Spacer()

                Section {
                    ForEach(financeViewModel.houseProfileViewModel.usuariosDaCasa, id: \.self) { pessoa in
                        InfoPessoasPagaram(pessoa: pessoa.name, pagos: pagos)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(
                                despesa.paidBy.contains(pessoa.name)
                                ? "\(pessoa.name) já pagou"
                                : "\(pessoa.name) não pagou"
                            )
                    }
                }

                Spacer()
                HStack{
                    Spacer()
                    if(jaPagou == false){
                        Button {
                            Task{
                                despesa.paidBy.append(nomeUsuario)
                                await financeViewModel.editarDespesa(despesa)
                                pagos = despesa.paidBy
                                jaPagou = true
                                let id1 = "\(despesa.id.recordName)-1"
                                let id2 = "\(despesa.id.recordName)-2"
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id1, id2])
                                fecharModalInfo()
                            } }label: {
                                Text("Marcar como pago")
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("AccentColor"))
                                    .cornerRadius(10)
                            }
                        
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                    } else {
                        Button{
                            Task{
                                jaPagou = false
                                despesa.paidBy.removeAll { $0 == nomeUsuario }
                                await financeViewModel.editarDespesa(despesa)
                                pagos = despesa.paidBy
                                financeViewModel.agendarNotificacaoSeNecessario(despesa, nomeUsuario: nomeUsuario)
                                fecharModalInfo()
                            }
                        } label:{
                            Text("Desmarcar como pago")
                                .foregroundColor(.white)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .cornerRadius(10)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    Spacer()
                }
            }
            .padding(24)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
            ModalEditarFincancaView(financeViewModel: financeViewModel, despesa: despesa, mostrarModalInfo: $mostrarModalInfo)
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

