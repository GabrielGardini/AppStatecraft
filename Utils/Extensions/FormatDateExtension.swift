//
//  DateFormatterExtension.swift
//  ifish
//
//  Created by Larissa on 23/06/25.
//

import Foundation

extension Date {
    func formatadoMesAno() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self).capitalized
    }
}
