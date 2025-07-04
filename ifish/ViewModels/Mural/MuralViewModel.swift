import Foundation
import CloudKit
import UserNotifications
import UIKit

@MainActor
class MessageViewModel: ObservableObject {
    @Published var mensagens: [MessageModel] = []
    @Published var nomesDeUsuarios: [CKRecord.ID: String] = [:]
    @Published var houseProfileViewModel: HouseProfileViewModel?

    init(houseProfileViewModel: HouseProfileViewModel? = nil) {
        self.houseProfileViewModel = houseProfileViewModel
    }

    func configurarSubscriptionDeAvisos() {
        let predicate = NSPredicate(value: true) // Para receber notificações de todos os novos avisos
        let subscription = CKQuerySubscription(
            recordType: "Message",
            predicate: predicate,
            subscriptionID: "novaMensagemSubscription",
            options: .firesOnRecordCreation
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.titleLocalizationKey = "%1$@" // Placeholder para o campo Title
        notificationInfo.titleLocalizationArgs = ["Title"]

        notificationInfo.alertLocalizationKey = "%1$@" // Placeholder para o campo Content
        notificationInfo.alertLocalizationArgs = ["Content"]

        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"

        subscription.notificationInfo = notificationInfo

        CKContainer.default().publicCloudDatabase.save(subscription) { (_, error) in
            if let error = error {
                print("❌ Erro ao criar subscription: \(error)")
            } else {
                print("✅ Subscription de avisos criada com sucesso.")
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
    
    // Criar nova mensagem
    func criarMensagem(content: String, title: String, dataAviso: Date, userID: CKRecord.Reference, notificationMural: Bool) async {
        guard let house = houseProfileViewModel?.houseModel else {
            print("❌ Nenhuma casa vinculada.")
            return
        }

        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let novaMensagem = MessageModel(
            id: recordID,
            content: content,
            houseID: CKRecord.Reference(recordID: house.id, action: .none),
            timestamp:dataAviso,
            title: title,
            userID: userID,
            notificationMural: notificationMural
        )

        do {
            let savedRecord = try await CKContainer.default().publicCloudDatabase.save(novaMensagem.toCKRecord())
            let model = MessageModel(record: savedRecord)

            await MainActor.run {
                mensagens.append(model)
            }
            if novaMensagem.notificationMural{
                agendarNotificacaoLocal(id: recordID.recordName, titulo: title, corpo: content, data: dataAviso)
            }

            print("✅ Mensagem criada com sucesso.")
        } catch {
            print("❌ Erro ao criar mensagem: \(error)")
        }
    }


    // Buscar mensagens da casa vinculada
    func buscarMensagens() async {
        guard let house = houseProfileViewModel?.houseModel else {
            print("❌ Nenhuma casa vinculada.")
            return
        }

        let predicate = NSPredicate(format: "HouseID == %@", CKRecord.Reference(recordID: house.id, action: .none))
        let query = CKQuery(recordType: "Message", predicate: predicate)

        do {
            let records = try await fetchRecords(matching: query)
            let mensagens = records.map { MessageModel(record: $0) }
            for msg in mensagens {
                print("Título: \(msg.title), Conteúdo: \(msg.content), Usuário: \(msg.userID.recordID.recordName), Data: \(msg.timestamp)")
            }
            await MainActor.run {
                self.mensagens = []
                self.mensagens = mensagens
            }
            //self.mensagens = mensagens
            print("📬 \(mensagens.count) mensagens carregadas.")
        } catch {
            print("❌ Erro ao buscar mensagens: \(error)")
        }
    }

    // Deletar mensagem
    func deletarMensagem(_ mensagem: MessageModel) async {
        do {
            try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: mensagem.id)
            mensagens.removeAll { $0.id == mensagem.id }
            print("🗑️ Mensagem removida.")
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [mensagem.id.recordName])

        } catch {
            print("❌ Erro ao deletar mensagem: \(error)")
        }
    }

    // Atualizar mensagem existente
    func editarMensagem(_ mensagem: MessageModel) async {
        do {
            let record = try await CKContainer.default().publicCloudDatabase.record(for: mensagem.id)

            // Atualiza os campos
            record["Title"] = mensagem.title as CKRecordValue
            record["Content"] = mensagem.content as CKRecordValue
            record["Timestamp"] = mensagem.timestamp as CKRecordValue
            record["Notification"] = mensagem.notificationMural ? 1:0

            let updatedRecord = try await CKContainer.default().publicCloudDatabase.save(record)
            let updatedModel = MessageModel(record: updatedRecord)

            if let index = mensagens.firstIndex(where: { $0.id.recordName == mensagem.id.recordName }) {
                mensagens[index] = updatedModel
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [mensagem.id.recordName])
            if mensagem.notificationMural {
                agendarNotificacaoLocal(id: mensagem.id.recordName, titulo: mensagem.title, corpo: mensagem.content, data: mensagem.timestamp)
            }


            print("✏️ Mensagem atualizada.")
        } catch {
            print("❌ Erro ao editar mensagem: \(error)")
        }
    }
    
    func avisoPermicaoNotificacoes(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func agendarNotificacaoLocal(id: String, titulo: String, corpo: String, data: Date) {
        let conteudo = UNMutableNotificationContent()
        conteudo.title = titulo
        conteudo.body = corpo
        conteudo.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: data)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let requisicao = UNNotificationRequest(identifier: id, content: conteudo, trigger: trigger)

        UNUserNotificationCenter.current().add(requisicao) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação: \(error)")
            } else {
                print("🔔 Notificação agendada para \(data)")
            }
        }
    }



    // Utilitário de busca
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
