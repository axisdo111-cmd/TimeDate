//
//  CalcError.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

enum CalcError: Error {
    case divisionByZero
    case invalidOperation
}

// Amélioration possible : ma logique client transformer les dates en secondes pour les calculs pour éviter les erreurs du genre (14 déc. 2025 x 2) si on tombe sur ce cas la référence sera le premier jour de l'année de la date saisie, soit 01/01/2025 on devra calculer les secondes écoulées entre le 01/12/2025 et le 14/12/2025 (on a un bouton [Différence inclusive] pour déterminer si 14/12/2025 00h00min01s ou 24h00min00s et autre calcul si nécessaire 
