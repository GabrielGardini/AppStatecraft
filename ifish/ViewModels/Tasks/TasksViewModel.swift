//
//  TasksViewModel.swift
//  ifish
//
//  Created by Lari on 16/06/25.
//

import Foundation
import CloudKit
import UserNotifications

class TasksViewModel: ObservableObject {
    @Published var tarefas: [TaskModel] = []
    @Published var nomesDeUsuarios: [CKRecord.ID: String] = [:]
    
    // MARK: - Criar nova tarefa
    func criarTarefa(task: TaskModel, houseModel: HouseModel) async {
        let houseRef = CKRecord.Reference(recordID: houseModel.id, action: .none)
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let novaTarefa = task

        do {
            let savedRecord = try await CKContainer.default().publicCloudDatabase.save(novaTarefa.toCKRecord())
            
            if let model = TaskModel(record: savedRecord) {
                await MainActor.run {
                    tarefas.append(model)
                    self.atualizarLembreteDaTarefa(model)
                }
                print("✅ Tarefa criada com sucesso.")
            } else {
                print("❌ Erro ao criar TaskModel a partir do CKRecord.")
            }
        } catch {
            print("❌ Erro ao salvar tarefa: \(error)")
        }
    }
    

    // MARK: - Apagar tarefa
    func apagarTarefa(_ tarefa: TaskModel) async {
        
        // apagar notificaçao associada
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lembrete-\(tarefa.id.recordName)"])
        
        do {
            try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: tarefa.id)
            await MainActor.run {
                tarefas.removeAll { $0.id.recordName == tarefa.id.recordName }
            }
            print("🗑️ Tarefa removida.")
        } catch {
            print("❌ Erro ao apagar tarefa: \(error)")
        }
    }

    // MARK: - Editar tarefa existente
    func editarTarefa(_ tarefa: TaskModel) async {
        let database = CKContainer.default().publicCloudDatabase

        do {
            let record = try await database.record(for: tarefa.id)
            tarefa.atualizarCamposEm(record)
            let updatedRecord = try await database.save(record)

            if let updatedModel = TaskModel(record: updatedRecord) {
                await MainActor.run {
                    if let index = tarefas.firstIndex(where: { $0.id == updatedModel.id }) {
                        tarefas[index] = updatedModel
                        self.atualizarLembreteDaTarefa(updatedModel)
                    }
                }
                print("✏️ Tarefa atualizada com sucesso.")
            }

        } catch {
            print("❌ Erro ao editar tarefa: \(error)")
        }
    }
    
    func atualizarLembreteDaTarefa(_ task: TaskModel) {
        let id = "lembrete-\(task.id)"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        guard let data = task.dataDoLembrete, data > Date() else {
            return
        }

        let conteudo = UNMutableNotificationContent()
        conteudo.title = task.titulo
        conteudo.body = "Lembrete da tarefa"
        conteudo.sound = .default

        let intervalo = data.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalo, repeats: false)

        let requisicao = UNNotificationRequest(identifier: id, content: conteudo, trigger: trigger)
        
        UNUserNotificationCenter.current().add(requisicao) { erro in
            if let erro = erro {
                print("❌ Erro ao agendar notificação: \(erro.localizedDescription)")
            } else {
                print("🔔 Notificação agendada para tarefa '\(task.titulo)' em \(data)")
            }
        }
    }
    
    func buscarTarefasDaCasa(houseModel: HouseModel) async {
        print("📥 Buscando tarefas para casa ID: \(houseModel.id.recordName)")
        
        let houseRef = CKRecord.Reference(recordID: houseModel.id, action: .none)
        let predicate = NSPredicate(format: "HouseID == %@", houseRef)
        let query = CKQuery(recordType: "Task", predicate: predicate)

        do {
            let records = try await fetchRecords(matching: query)
            let tarefas = records.compactMap { TaskModel(record: $0) }

            await MainActor.run {
                self.tarefas = tarefas
            }
            print("📦 \(tarefas.count) tarefas carregadas.")
        } catch {
            print("❌ Erro ao buscar tarefas: \(error)")
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
}
