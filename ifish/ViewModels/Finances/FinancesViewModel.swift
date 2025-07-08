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
    func criarDespesa(amount: Double, deadline: Date, paidBy: [String], title: String, notification: Bool, shouldRepeat: Bool) async {
        guard let houseModel = houseProfileViewModel.houseModel else {
            print("❌ Nenhuma casa vinculada.")
            return
        }

        let houseRef = CKRecord.Reference(recordID: houseModel.id, action: .none)
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let novaDespesa = FinanceModel(id: recordID, amount: amount, deadline: deadline, houseID: houseRef, paidBy: paidBy, title: title, notification: notification, shouldRepeat: shouldRepeat)

        do {
            let savedRecord = try await CKContainer.default().publicCloudDatabase.save(novaDespesa.toCKRecord())
            let model = FinanceModel(record: savedRecord)
            await MainActor.run {
                despesas.append(model)
            }
            if(notification == true){
                agendarNotificacaoSeNecessario(model, nomeUsuario: houseProfileViewModel.usuarioAtual?.name ?? "")
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
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [despesa.id.recordName])
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
            record["Notification"] = despesa.notification as CKRecordValue
            record["Repeat"] = despesa.shouldRepeat as CKRecordValue
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
    
    func agendarNotificacaoSeNecessario(_ despesa: FinanceModel, nomeUsuario: String) {
        guard !despesa.paidBy.contains(nomeUsuario) else { return }

        let content1 = UNMutableNotificationContent()
        content1.title = "Despesa vence amanhã"
        content1.body = "A despesa \"\(despesa.title)\" vence amanhã e ainda não foi paga."
        content1.sound = .default
        
        let content2 = UNMutableNotificationContent()
        content2.title = "Despesa vence hoje"
        content2.body = "A despesa \"\(despesa.title)\" vence hoje e ainda não foi paga."
        content2.sound = .default

        let diaAnterior = Calendar.current.date(byAdding: .day, value: -1, to: despesa.deadline)!
        var triggerDate1 = Calendar.current.dateComponents([.year, .month, .day], from: diaAnterior)
        triggerDate1.hour = 9
        triggerDate1.minute = 00
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: triggerDate1, repeats: false)


        var triggerDate2 = Calendar.current.dateComponents([.year, .month, .day], from: despesa.deadline)
        triggerDate2.hour = 09
        triggerDate2.minute = 00
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: triggerDate2, repeats: false)

        let id1 = "\(despesa.id.recordName)-1"
        let id2 = "\(despesa.id.recordName)-2"
        
        let request1 = UNNotificationRequest(identifier: id1, content: content1, trigger: trigger1)
        let request2 = UNNotificationRequest(identifier: id2, content: content2, trigger: trigger2)


        UNUserNotificationCenter.current().add(request1) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                print("🔔 Notificação agendada para \(despesa.title) no dia anterior")
            }
        }
        
        UNUserNotificationCenter.current().add(request2) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                print("🔔 Notificação agendada para \(despesa.title) no dia")
            }
        }
    }

}


