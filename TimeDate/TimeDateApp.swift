//
//  TimeDateApp.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

@main
struct TimeDateApp: App {
    // Bloque la rotation paysage provisoirement
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    var body: some Scene {
        WindowGroup {
            CalculatorView()
        }
    }
}

