import Foundation
import CloudKit
import SwiftUI

@MainActor
class FinanceViewModel: ObservableObject {
    @Published var despesas: [FinanceModel] = []
    

    private let houseProfileViewModel: HouseProfileViewModel
    private let appState: AppState
    
    init(houseProfileViewModel: HouseProfileViewModel, appState: AppState) {
        self.houseProfileViewModel = houseProfileViewModel
        self.appState = appState
    }

    // MARK: - Criar nova despesa
    func criarDespesa(amount: Double, deadline: Date, paidBy: [String], title: String) async {
        guard let houseModel = houseProfileViewModel.houseModel else {
            print("❌ Nenhuma casa vinculada.")
            return
        }

        let houseRef = CKRecord.Reference(recordID: houseModel.id, action: .none)
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let novaDespesa = FinanceModel(id: recordID, amount: amount, deadline: deadline, houseID: houseRef, paidBy: paidBy, title: title)

        do {
            let savedRecord = try await CKContainer.default().publicCloudDatabase.save(novaDespesa.toCKRecord())
            let model = FinanceModel(record: savedRecord)
            await MainActor.run {
                despesas.append(model)
            }
            print("✅ Despesa criada com sucesso.")
        } catch {
            print("❌ Erro ao criar despesa: \(error)")
        }
    }

    // MARK: - Listar todas as despesas da casa vinculada
    func buscarDespesasDaCasa() async {
        guard let houseModel = houseProfileViewModel.houseModel else {
            print("❌ Nenhuma casa vinculada.")
            return
        }

        let houseRef = CKRecord.Reference(recordID: houseModel.id, action: .none)
        let predicate = NSPredicate(format: "HouseId == %@", houseRef)
        let query = CKQuery(recordType: "Expanse", predicate: predicate)

        do {
            let records = try await fetchRecords(matching: query)
            let despesas = records.map { FinanceModel(record: $0) }

            await MainActor.run {
                self.despesas = despesas
            }
            print("📦 \(despesas.count) despesas carregadas.")
        } catch {
            print("❌ Erro ao buscar despesas: \(error)")
        }
    }

    // MARK: - Apagar despesa
    func apagarDespesa(_ despesa: FinanceModel) async {
        do {
            try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: despesa.id)
            await MainActor.run {
                var novasDespesas = despesas
                novasDespesas.removeAll { $0.id.recordName == despesa.id.recordName }
                despesas = novasDespesas
            }
            print("🗑️ Despesa removida.")
        } catch {
            print("❌ Erro ao apagar despesa: \(error)")
        }
    }

    // MARK: - Editar despesa existente
    func editarDespesa(_ despesa: FinanceModel) async {
        do {
            let record = try await CKContainer.default().publicCloudDatabase.record(for: despesa.id)
            record["Title"] = despesa.title as CKRecordValue
            record["Amount"] = despesa.amount as CKRecordValue
            record["DeadLine"] = despesa.deadline as CKRecordValue
            let updatedRecord = try await CKContainer.default().publicCloudDatabase.save(record)
            let updatedModel = FinanceModel(record: updatedRecord)

            if let index = despesas.firstIndex(where: { $0.id.recordName == despesa.id.recordName }) {
                    despesas[index] = updatedModel
                }

            print("✏️ Despesa atualizada.")
        } catch {
            print("❌ Erro ao editar despesa: \(error)")
        }
    }
    
    
   /* func editarMensagem(_ mensagem: MessageModel) async {
        do {
          let record = try await CKContainer.default().publicCloudDatabase.record(for: mensagem.id)      // Atualiza os campos
          record["Title"] = mensagem.title as CKRecordValue
          record["Content"] = mensagem.content as CKRecordValue
          record["Timestamp"] = mensagem.timestamp as CKRecordValue      let updatedRecord = try await CKContainer.default().publicCloudDatabase.save(record)
          let updatedModel = MessageModel(record: updatedRecord)      if let index = mensagens.firstIndex(where: { $0.id.recordName == mensagem.id.recordName }) {
            mensagens[index] = updatedModel
          }      print(":lápis_com_borracha: Mensagem atualizada.")
        } catch {
          print(":x_vermelho: Erro ao editar mensagem: \(error)")
        }
      }*/
    
    
    
    

    // MARK: - Utilitário de busca
    private func fetchRecords(matching query: CKQuery) async throws -> [CKRecord] {
        try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: records ?? [])
                }
            }
        }
    }
    
    func marcarComoPago(despesa: FinanceModel, nomeUsuario: String) async {
        print("\(nomeUsuario) pagou")
        /*guard let index = despesas.firstIndex(where: { $0.id == despesa.id }) else {
            print("❌ Despesa não encontrada")
            return
        }

        var despesaAtualizada = despesas[index]

        if despesaAtualizada.paidBy.contains(nomeUsuario) {
            print("ℹ️ Usuário já marcou como pago")
            return
        }

        despesaAtualizada.paidBy.append(nomeUsuario)

        // Atualiza no array (isso sim pode fazer com segurança no MainActor)
        despesas[index] = despesaAtualizada

        // Agora salva
        await editarDespesa(despesaAtualizada)*/
    }


}
