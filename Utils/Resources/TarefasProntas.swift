//
//  TarefasProntas.swift
//  ifish
//
//  Created by Aluno 15 on 02/07/25.
//

import Foundation


struct TarefaPronta: Identifiable {
    let id = UUID()
    let titulo: String
    let icone: String
}


struct TarefasProntasMock {
    static let lista: [TarefaPronta] = [
        .init(titulo: "Tirar o lixo da cozinha", icone: "trash.fill"),
        .init(titulo: "Lavar o banheiro", icone: "drop.fill"),
        .init(titulo: "Varrer o quarto", icone: "bed.double.fill"),
        .init(titulo: "Passar roupa", icone: "tshirt.fill"),
        .init(titulo: "Cortar grama", icone: "leaf.fill"),
        .init(titulo: "Colocar lixo na rua", icone: "trash.fill"),
        .init(titulo: "Lavar roupa", icone: "tshirt.fill"),
        .init(titulo: "Limpar espelho do banheiro", icone: "drop.fill"),
        .init(titulo: "Fazer compras", icone: "cart.fill"),
        .init(titulo: "Organizar armário", icone: "archivebox.fill"),
        .init(titulo: "Anotar compromissos", icone: "calendar"),
        .init(titulo: "Consertar a torneira", icone: "wrench.fill"),
        .init(titulo: "Desligar as luzes", icone: "lightbulb.fill"),
        .init(titulo: "Fazer o jantar", icone: "fork.knife"),
        .init(titulo: "Dar comida para o pet", icone: "flame.fill"),
        .init(titulo: "Dobrar as roupas", icone: "tshirt.fill"),
        .init(titulo: "Estudar", icone: "pencil.tip"),
        .init(titulo: "Trocar roupa de cama", icone: "bed.double.fill"),
        .init(titulo: "Revisar tarefas da casa", icone: "doc.fill"),
        .init(titulo: "Conferir lista de compras", icone: "bag.fill"),
        .init(titulo: "Avisar todos sobre evento", icone: "person.2.fill"),
        .init(titulo: "Verificar caixa de ferramentas", icone: "hammer.fill"),
        .init(titulo: "Afiar tesouras", icone: "scissors"),
        .init(titulo: "Verificar horário do lixo", icone: "clock.fill"),
        .init(titulo: "Apagar aviso antigo", icone: "exclamationmark.triangle.fill")
    ]
}
