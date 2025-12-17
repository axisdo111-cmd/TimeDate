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

//  le programme est bien avancé, c'est une calculatrice basic avec une logique CASIO (en mode : CALC), en plus elle sert à faire des calculs horaires et de date (en mode : DATE-TIME). (en interne elle transforme les saisies en secondes et fait tous les calculs demandés), les saisie "hh:mm:ss" et les résultats sont visible à l'écran par l'utilisateur au format : "x Years y Months z Days (x, y, z étant des quantité de temps) - hh:mm:ss", les valeurs à zéro ne s'affiche pas si non pertinent (ex. 0 years 0 months 0 days 1 hour 2 minutes 6 seconds on affiche que : 01:02:06) le résultat horaire maximum ça doit être 23:59:59 (ex. si résultat 24 Hours on doit voir 1 days 00:00:00 ainsi de suite). Pour les dates on utilisera le calendrier Grégorien pour commencer.
//
//  J'ai 2 modes sur la calculatrice : 1-CALC pour tous les calculs basic et 2-DATE-TIME pour les calculs de date et horaire.
//
//  Si la première saisie est un horaire (la machine doit passer automatiquement en DATE-TIME et les boutons [Years][Months][Days]et[/] doivent être neutralisés pour éviter les erreurs.
//
//  Si la première saisie est une date on passe automatiquement en DATE-TIME et les boutons [Hours][Minutes][Seconds] et [:], [.] de même que les touches [multiplication] et [division] doivent être neutralisés pour éviter les erreurs.
//
//  La seconde saisie peut être fait sous 2 formats : 1+[hours] 23+[Minutes] ou 1:23:00,
//      Si on ne saisie que 1:23+[=] automatique la valeur doit être considérée comme : 1 minutes 23 seconds.
//      Si la seconde saisie est une décimale cela dépendra de l'opérateur tapé avant
//          si [+] ou [-] la décimale est en seconds (ex. 1:23:00 [+] 1 [=] 01:23:01)
//          si multiplication ou division la décimale n'est qu'une décimale.(ex. 01:23:00 [x] 2 [=] (la machine transforme 1:23:00 en seconds multiplie par 2 est affiche le résultat convertit au format h:mm:ss) sur l'écran on doit voir : (x Years y Months z Days - hh:mm:ss)
//
//  la première saisie visible au format saisie (ex. 1 Hours 23 Minutes 2 Secondes après appui sur l'opérateur la valeur première passe au-dessus dans une zone intermédiaire au format (hh:mm:ss) et libérer la zone de saisie prêt pour la seconde saisie, on doit voir la valeur tapée tant que l'on n'a pas fait [=].
//
//  Pour les dates, la première saisie affiche son jour en surbrillance dans sa zone dédiée, on clique sur l'opérateur disponible et la seconde saisie peut être : une date complète 29+[Days] 3+[Months] 1967+[Years] ou 29/3/1967 ou 1967+[Years] 29+[Days] 3+[Months] (le jour correspondant est en surbrillance dans sa zone dédiée), le résultat attendu :
//      pour Date1 [-] Date2 [=] l'écarte entre les 2 dates (au format : x Years y Months z Days) pour savoir si c'est une date il faudra obligatoirement x+[Years][Months][Days], sinon ce sera des quantités [Years], [Months], [Days], [Weeks] que l'on devra retirer pour connaître la date au format (jj/mm/aaaa) dans la limite du calendrier Grégorien (si erreur message : "au delà du Calendrier Grégorien")
//
//      pour [+] on ajoutera que des quantités (w+[Years] de mois (z+[Months] de semaines (y+[Weeks] ou de jours (x+[Days]) résultat attendu une date dans le futur (29/03/1967 ou 29 march 1967) et son jour en surbrillance dans sa zone dédiée.

