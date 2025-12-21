//
//  AppDelegate.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 16/12/2025.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    // Force la position Portrait
    //      Force en Position Portrait Uniquement
    //      func application(
    //          _ application: UIApplication,
    //            supportedInterfaceOrientationsFor window: UIWindow?
    //        ) -> UIInterfaceOrientationMask {
    //           return .portrait
    //        }
    //      }
    
    //  Verrouille les iPhones en Portrait mais pas les iPads
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        
        guard let scene = window?.windowScene else {
            return .portrait
        }
        
        switch scene.traitCollection.userInterfaceIdiom {
        case .phone:
            return .portrait
            
        case .pad:
            return [.portrait, .landscapeLeft, .landscapeRight]
            
        default:
            return .portrait
        }
    }
}
