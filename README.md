# ⏱️ TIME-DATE

## 📌 Description

**TIME-DATE** est une application de calcul de temps et de dates inspirée des calculatrices **CASIO**. Elle permet de manipuler des heures et des dates de manière précise, cohérente et normalisée, en intégrant des règles strictes de saisie et de calcul.

L'application repose sur une conversion interne en secondes afin de garantir des calculs fiables et homogènes.

---

## ⚙️ Fonctionnalités principales

### 🔁 Modes de fonctionnement

L'application dispose de **2 modes distincts** :

* **CALC** :

  * Calculs arithmétiques sur les durées (hh:mm:ss)
  * Opérations supportées : `+`, `-`, `×`, `÷`
  * Support des valeurs décimales

* **DATE‑TIME** :

  * Manipulation et calculs sur des dates du calendrier grégorien
  * Calcul de l'écart entre deux dates
  * Ajout / retrait de quantités de temps

---

## ⏰ Gestion des heures

* Format de saisie : **hh:mm:ss**
* Normalisation automatique :

  * 60 secondes → +1 minute
  * 60 minutes → +1 heure
  * Dépassement de 23:59:59 → conversion en jours
* Affichage intelligent :

  * Les unités à zéro sont masquées (ex : `01:00:00` → `1h`)

---

## 📅 Gestion des dates

* Format de saisie : **jj/mm/aaaa**
* Calendrier : **grégorien uniquement**
* Calculs possibles :

  * Différence entre deux dates
  * Ajout ou soustraction de :

    * Années
    * Mois
    * Semaines
    * Jours

⚠️ Toute opération sortant du calendrier grégorien génère une **erreur**.

---

## 🧠 Règles de saisie et de calcul

* Le type de la **première saisie** (heure ou date) détermine :

  * Les touches actives
  * Les opérateurs autorisés
* Les saisies incompatibles sont automatiquement **neutralisées**
* Les calculs mixtes (date ↔ heure) sont interdits

---

## 🔄 Fonctionnement interne

* Toutes les valeurs sont converties en **secondes** pour le calcul
* Les résultats sont ensuite :

  * Reconvertis
  * Normalisés
  * Affichés sous une forme compacte

---

## 🚀 Objectifs du projet

* Reproduire le comportement logique des calculatrices CASIO
* Garantir des calculs temporels fiables
* Offrir une interface claire et sans ambiguïté

---

## 📄 Licence

Projet personnel – utilisation libre à des fins éducatives et expérimentales.

---

## ✨ Auteur

Développé par **Futur‑Développeur11**
