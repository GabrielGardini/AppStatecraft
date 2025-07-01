import Foundation
import CloudKit
import SwiftUI

@MainActor
class FinanceViewModel: ObservableObject {
    @Published var despesas: [FinanceModel] = []
    @Published var nomesDeUsuarios: [CKRecord.ID: String] = [:]
    @Published var nomesUsuariosCasa: [String] = []
    

    public let houseProfileViewModel: HouseProfileViewModel
    private let appState: AppState
    
    init(houseProfileViewModel: HouseProfileViewModel, appState: AppState) {
        self.houseProfileViewModel = houseProfileViewModel
        self.appState = appState
        atualizarNomesUsuariosCasa()
    }

    func atualizarNomesUsuariosCasa() {
        nomesUsuariosCasa = houseProfileViewModel.usuariosDaCasa.map { $0.name }
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
            record["PaidBy"] = despesa.paidBy as CKRecordValue
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
    
    
    func descobrirNomeDoUsuario(userID: CKRecord.Reference) async -> String {
        if let nome = nomesDeUsuarios[userID.recordID] {
            return nome
        }

        do {
            let identity = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CKUserIdentity, Error>) in
                CKContainer.default().discoverUserIdentity(withUserRecordID: userID.recordID) { identity, error in
                    if let identity = identity {
                        continuation.resume(returning: identity)
                    } else {
                        continuation.resume(throwing: error ?? NSError(domain: "ErroDesconhecido", code: -1))
                    }
                }
            }

            let nomeCompleto = [identity.nameComponents?.givenName, identity.nameComponents?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")

            let nomeFinal = nomeCompleto.isEmpty ? "Usuário sem nome" : nomeCompleto

            self.nomesDeUsuarios[userID.recordID] = nomeFinal

            return nomeFinal
        } catch {
            print("❌ Erro ao descobrir nome do usuário: \(error)")
            return "Usuário desconhecido"
        }
    }

}

