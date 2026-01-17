# YAGBALLS TEAM PRESENTS
### Y- Yeah A-Amazing G-Great. 
### And we are always ballin, meaning? We are always having fun. That is Life! 
### Of course we also play ball 🏀 <img src="https://i.imgur.com/1D4IxrI.png" height="50"/>

# Group 1 Pokédex: Sorting Algorithm Visualizer

![Project Banner](https://i.imgur.com/YUMxZGe.png)

## 📖 About The Project

**Group 1 Pokédex** is an interactive sorting visualizer designed to visualize how sorting algorithms work "under the hood." Built with **Flutter** (via FlutterFlow) and backed by **Firebase**, this application simulates the **Bubble Sort** algorithm in real-time using a roster of 18 Pokémon cards.

Unlike standard sorting functions that finish instantly, this visualizer slows down the process to show every comparison, decision, and swap the computer makes, complete with retro game aesthetics and audio feedback.

---

## 🎮 Key Features

* **Visual Sorting Simulation:** Watch cards physically move and swap positions as the algorithm processes them.
* **Real-Time Comparator Console:** A dedicated window that displays the exact values being compared (e.g., "70 HP vs 45 HP") and the logic decision ("🔁 SWAP!" or "✅ Keep").
* **Dynamic Reference Guide:** An in-app sidebar that updates to show the specific rules for the current sorting mode (e.g., Type priority order).
* **Multi-Criteria Sorting:** Implements complex, SQL-style cascading logic (Sort by Evolution → then Generation → then HP → then Type → then Name).
* **Audio Integration:** Features background music (toggleable between Menu and Sorting modes) and sound effects for successful sorts.
* **Firebase Backend:** All Pokémon data (Images and Stats) is fetched dynamically from a Firestore database.

---

## 🚀 Sorting Modes & Complexity

This project focuses on the **Bubble Sort** algorithm. Below are the modes available for visualization:

| Sorting Mode | Description | Time Complexity (Big O) |
| :--- | :--- | :--- |
| **HP** | Sorts numeric Health Points from Lowest to Highest. | $O(n^2)$ |
| **Evolution** | Sorts by stage: Basic → Stage 1 → Stage 2. | $O(n^2)$ |
| **Generation** | Sorts by release generation (Gen 1 → Gen 6). | $O(n^2)$ |
| **Type** | Sorts based on a custom index (Normal=1 ... Fairy=18). | $O(n^2)$ |
| **Alphabetical** | Standard string comparison (A-Z). | $O(n^2)$ |
| **Multi (All-in-One)** | A complex cascading sort: **Evo > Gen > Type > Name**. | $O(n^2)$ |

> **Note:** While the computational Big O is the same for all modes, the visual "busyness" varies. Sorted groups (like Generations) result in large blocks moving together, while unique values (like HP) cause frequent individual swaps.

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Platform:** [FlutterFlow](https://flutterflow.io/) (Custom Widgets)
* **Language:** Dart
* **Backend:** Firebase (Firestore Database)
* **Audio:** `audioplayers` package (^5.0.0)

---

## 💾 Data Structure (Firebase)

The app retrieves data from a Firestore collection named `pokemonoks`. The schema includes:

```json
{
  "id": "Integer (1-18)",
  "name": "String",
  "imageUrl": "String (URL)",
  "hp": "Integer",
  "evolutionStage": "Integer (1=Basic, 2=Stage1, 3=Stage2)",
  "generation": "Integer",
  "typeOrderIndex": "Integer (1-18 for sorting priority)"
}
```
## 🔗 How to Access

You can explore the project directly in your browser without needing to install anything locally.

* **[See and use the actual App in action](https://preview.flutterflow.app/dsaprog-xm6rs9/ITXn80zss7xkEfGmITgy)**
    *(Note: Click "Start Adventure" to enable audio due to browser policies)*

* **[See the behind the scenes](https://app.flutterflow.io/project/dsaprog-xm6rs9?tab=uiBuilder&page=HomePage)**
    *(View the FlutterFlow project structure and design)*

---

## 📊 Project Insights

During development, we analyzed the behavior of the Bubble Sort algorithm on our dataset:

* **Most Active Card:** **Abra**. Despite starting at the very last position (#18), it belongs at the top alphabetically. This forces it to traverse the entire list, generating the highest number of comparisons.
* **The "Bulldozer":** **Greninja**. When sorting by Evolution (High to Low), Greninja starts at index #1 but is a Stage 3 Pokémon. It swaps with nearly every card until it reaches the end, visually "bulldozing" the list.
* **Processing Speed:** Without the artificial delay added for visualization, modern devices can sort this 18-item list in approximately ** seconds**.

---

## 👥 Credits

* **Development:** The Yagballs Team (Group 1)
* **Assets:** Pokémon sprites and audio themes are property of Nintendo/Game Freak. Used for educational purposes.
* **Background Art:** https://x.com/Neos_ex/status/1570925324199956482.

---

> *"Gotta Sort 'Em All!"*
---

*Disclaimer: This README.md file was generated with the assistance of AI (Google Gemini) to efficiently summarize our program's logic and architecture, allowing the team to focus on other tasks and lessen workload.*
