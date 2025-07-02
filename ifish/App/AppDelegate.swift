//
//  AppDelegate.swift
//  ifish
//
//  Created by Aluno 19 on 01/07/25.
//

import Foundation


import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("📲 Registrado para push com token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Falha ao registrar push: \(error)")
    }
}
