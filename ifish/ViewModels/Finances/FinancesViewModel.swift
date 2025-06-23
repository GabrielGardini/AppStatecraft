import Foundation
import CloudKit

@MainActor
class FinanceViewModel: ObservableObject {
    @Published var despesas: [FinanceModel] = []

    private let houseProfileViewModel: HouseProfileViewModel

    init(houseProfileViewModel: HouseProfileViewModel) {
        self.houseProfileViewModel = houseProfileViewModel
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
            let updatedRecord = try await CKContainer.default().publicCloudDatabase.save(despesa.toCKRecord())
            let updatedModel = FinanceModel(record: updatedRecord)

            await MainActor.run {
                var novasDespesas = despesas
                if let index = novasDespesas.firstIndex(where: { $0.id.recordName == despesa.id.recordName }) {
                    novasDespesas[index] = updatedModel
                    despesas = novasDespesas
                }
            }

            print("✏️ Despesa atualizada.")
        } catch {
            print("❌ Erro ao editar despesa: \(error)")
        }
    }

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
}
