// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// DISCLAIMER: The following code is vibe coded, meaning it is a mix of human written code and AI written code via the use of Gemini. As to why:
// it is hard to implement and learn dart in the flutter framework without assistance especially in such time constraints. But with the assistance of AI and using every available resources,
// we were able to show the vision of our group, the visuals of the sorter, the sounds and various metrics seen in this program/application.

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MasterPokedex extends StatefulWidget {
  final double? width;
  final double? height;
  final List<PokemonoksRecord> pokemonList;

  const MasterPokedex({
    Key? key,
    this.width,
    this.height,
    required this.pokemonList,
  }) : super(key: key);

  @override
  _MasterPokedexState createState() => _MasterPokedexState();
}

enum AppState { landing, selection, sorting }

class _MasterPokedexState extends State<MasterPokedex> {
  // Navigation State
  AppState currentState = AppState.landing;
  String currentSortMode = "HP";
  String previousSortMode = "Unsorted";

  // Data State
  late List<PokemonoksRecord> workingList;
  late List<PokemonoksRecord> originalList;

  // Animation/Control State
  bool isSorting = false;
  bool stopRequested = false;
  int? indexA;
  int? indexB;
  String statusMessage = "Ready";

  // Console Window State
  String consoleValA = "-";
  String consoleValB = "-";
  String consoleDecision = "Waiting...";
  Color consoleStatusColor = Colors.white;

  // Counters
  int swapsCount = 0;
  int comparesCount = 0;

  // Result Popup State
  bool showResultPopup = false;

  // Timer State
  Stopwatch stopwatch = Stopwatch();
  Timer? uiTimer;
  String timeString = "0.00s";

  // --- AUDIO SETUP ---
  final String mainAppBgmUrl =
      "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dsaprog-xm6rs9/assets/dkd8l4ixzggr/Pokmon-Center-Theme.mp3";
  final String sortingBgmUrl =
      "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dsaprog-xm6rs9/assets/dc3a7unnnf4q/Omsss.mp3";
  final String dingUrl =
      "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dsaprog-xm6rs9/assets/zxzbb3xslp0a/12_3_(1).mp3";

  final AudioPlayer mainBgmPlayer = AudioPlayer();
  final AudioPlayer sortingBgmPlayer = AudioPlayer();
  final AudioPlayer sfxPlayer = AudioPlayer();

  // All available sorting modes (Added the new one at the end)
  final List<String> allSortModes = [
    'HP (Low->High)',
    'Evolution',
    'Generation',
    'Type',
    'Alphabetical',
    'All-in-One (Multi)' // <--- NEW BUTTON
  ];

  @override
  void initState() {
    super.initState();
    List<PokemonoksRecord> sortedById = List.from(widget.pokemonList);
    sortedById.sort((a, b) => a.id.compareTo(b.id));

    originalList = List.from(sortedById);
    workingList = List.from(sortedById);

    mainBgmPlayer.setReleaseMode(ReleaseMode.loop);
    sortingBgmPlayer.setReleaseMode(ReleaseMode.loop);

    // No auto-play in initState due to browser policy
  }

  void _playMainBgm() async {
    try {
      if (mainAppBgmUrl.isNotEmpty) {
        await mainBgmPlayer.stop();
        await mainBgmPlayer.setVolume(1.0);
        await mainBgmPlayer.play(UrlSource(mainAppBgmUrl));
      }
    } catch (e) {
      print("Error playing main BGM: $e");
    }
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    mainBgmPlayer.dispose();
    sortingBgmPlayer.dispose();
    sfxPlayer.dispose();
    super.dispose();
  }

  //color helper
  Color _getModeColor(String mode) {
    if (mode.contains('HP')) return Colors.green[700]!;
    if (mode.contains('Evolution')) return Colors.purple[700]!;
    if (mode.contains('Generation')) return Colors.grey[800]!;
    if (mode.contains('Type')) return Colors.pink[400]!;
    if (mode.contains('Multi')) return Colors.orange[800]!;
    return Colors.black; // Alphabetical
  }

  void handleChainSort(String newMode) {
    if (isSorting) return;
    setState(() {
      previousSortMode = currentSortMode;
      currentSortMode = newMode;
      _resetSortState();
      startSimulation();
    });
  }

  void initSort(String mode) {
    setState(() {
      currentSortMode = mode;
      previousSortMode = "Unsorted";
      currentState = AppState.sorting;
      workingList = List.from(originalList);
      statusMessage = "Mode: $mode";
      _resetSortState();
    });
  }

  void _resetSortState() {
    swapsCount = 0;
    comparesCount = 0;
    timeString = "0.00s";
    showResultPopup = false;
    stopRequested = false;
    indexA = null;
    indexB = null;
    consoleValA = "-";
    consoleValB = "-";
    consoleDecision = "Ready";
    consoleStatusColor = Colors.white;
  }

  void handleStop() {
    sortingBgmPlayer.pause();
    setState(() {
      stopRequested = true;
      statusMessage = "Stopped";
      isSorting = false;
      stopwatch.stop();
      uiTimer?.cancel();
    });
  }

  void handleReset() {
    sortingBgmPlayer.stop();
    mainBgmPlayer.resume();
    setState(() {
      stopRequested = true;
      isSorting = false;
      showResultPopup = false;
      stopwatch.stop();
      stopwatch.reset();
      uiTimer?.cancel();
      workingList = List.from(originalList);
      statusMessage = "Reset to Unsorted";
      previousSortMode = "Unsorted";
      _resetSortState();
    });
  }

  Future<void> startSimulation() async {
    bool isResuming = statusMessage == "Stopped";
    mainBgmPlayer.pause();

    if (!isResuming) {
      sortingBgmPlayer.stop();
      sortingBgmPlayer.play(UrlSource(sortingBgmUrl));
    } else {
      sortingBgmPlayer.resume();
    }

    setState(() {
      isSorting = true;
      stopRequested = false;
      showResultPopup = false;
      if (!isResuming) {
        swapsCount = 0;
        comparesCount = 0;
        stopwatch.reset();
      }
      stopwatch.start();
    });

    uiTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      setState(() {
        timeString =
            "${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s";
      });
    });

    int n = workingList.length;

    for (int i = 0; i < n - 1; i++) {
      if (stopRequested) break;

      for (int j = 0; j < n - i - 1; j++) {
        if (stopRequested) break;

        // 1. HIGHLIGHT & UPDATE CONSOLE
        setState(() {
          indexA = j;
          indexB = j + 1;
          comparesCount++;
          statusMessage = "Comparing...";

          // Console Display Logic
          switch (currentSortMode) {
            case 'HP (Low->High)':
              consoleValA = "${workingList[j].hp}";
              consoleValB = "${workingList[j + 1].hp}";
              break;
            case 'Evolution':
              consoleValA = "Stg ${workingList[j].evolutionStage}";
              consoleValB = "Stg ${workingList[j + 1].evolutionStage}";
              break;
            case 'Generation':
              consoleValA = "Gen ${workingList[j].generation}";
              consoleValB = "Gen ${workingList[j + 1].generation}";
              break;
            case 'Type':
              consoleValA = "Idx ${workingList[j].typeOrderIndex}";
              consoleValB = "Idx ${workingList[j + 1].typeOrderIndex}";
              break;
            case 'All-in-One (Multi)':
              consoleValA = workingList[j].name.substring(0, 3);
              consoleValB = workingList[j + 1].name.substring(0, 3);
              break;
            default: // Alphabetical
              consoleValA = workingList[j].name.substring(0, 1);
              consoleValB = workingList[j + 1].name.substring(0, 1);
          }

          consoleDecision = "Thinking...";
          consoleStatusColor = Colors.yellow;
        });

        await Future.delayed(Duration(milliseconds: 300));

        // LOGIC DECISION
        bool swapNeeded = false;
        switch (currentSortMode) {
          case 'HP (Low->High)':
            if (workingList[j].hp > workingList[j + 1].hp) swapNeeded = true;
            break;
          case 'Evolution':
            if (workingList[j].evolutionStage >
                workingList[j + 1].evolutionStage) swapNeeded = true;
            break;
          case 'Generation':
            if (workingList[j].generation > workingList[j + 1].generation)
              swapNeeded = true;
            break;
          case 'Type':
            if (workingList[j].typeOrderIndex >
                workingList[j + 1].typeOrderIndex) swapNeeded = true;
            break;

          // MULTI-SORT LOGIC (Evo -> Gen -> Type -> Name)
          case 'All-in-One (Multi)':
            var A = workingList[j];
            var B = workingList[j + 1];

            // Level 1: Evolution
            if (A.evolutionStage != B.evolutionStage) {
              swapNeeded = A.evolutionStage > B.evolutionStage;
            }
            // Level 2: Generation
            else if (A.generation != B.generation) {
              swapNeeded = A.generation > B.generation;
            }

            // Level 3. HP (Lowest to Highest)
            else if (A.hp != B.hp) {
              swapNeeded = A.hp > B.hp;
            }
            // Level 4: Type
            else if (A.typeOrderIndex != B.typeOrderIndex) {
              swapNeeded = A.typeOrderIndex > B.typeOrderIndex;
            }
            // Level 5: Alphabetical (Tie-breaker)
            else {
              swapNeeded = A.name.compareTo(B.name) > 0;
            }
            break;

          default:
            if (workingList[j].name.compareTo(workingList[j + 1].name) > 0)
              swapNeeded = true;
        }

        // EXECUTE SWAP
        setState(() {
          if (swapNeeded) {
            consoleDecision = "🔁 SWAP!";
            consoleStatusColor = Colors.redAccent;
            statusMessage = "Swapping!";
            swapsCount++;
            var temp = workingList[j];
            workingList[j] = workingList[j + 1];
            workingList[j + 1] = temp;
          } else {
            consoleDecision = "✅ Keep";
            consoleStatusColor = Colors.greenAccent;
            statusMessage = "Order Correct";
          }
        });

        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    stopwatch.stop();
    uiTimer?.cancel();
    sortingBgmPlayer.stop();

    if (!stopRequested) {
      sfxPlayer.play(UrlSource(dingUrl));
      setState(() {
        isSorting = false;
        indexA = null;
        indexB = null;
        consoleValA = "-";
        consoleValB = "-";
        consoleDecision = "Done!";
        consoleStatusColor = Colors.cyanAccent;
        statusMessage = "Sorting Complete!";
        timeString =
            "${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s";
        showResultPopup = true;
      });
    }
  }

  //  REFERENCE WINDOW
  Widget _buildReferenceWindow() {
    List<String> rules = [];
    String title = "Sort Order";

    if (currentSortMode.contains("HP")) {
      rules = ["Low Value", "⬇", "High Value"];
    } else if (currentSortMode.contains("Alphabetical")) {
      rules = ["A", "⬇", "Z"];
    } else if (currentSortMode.contains("Generation")) {
      rules = ["Gen 1", "Gen 2", "Gen 3", "Gen 4", "Gen 5", "Gen 6+"];
    } else if (currentSortMode.contains("Evolution")) {
      rules = ["Basic", "⬇", "Stage 1", "⬇", "Stage 2"];
    } else if (currentSortMode.contains("Multi")) {
      // NEW MULTI RULES
      rules = [
        "1. EVOLUTION",
        "  (Basic→Stg2)",
        "⬇",
        "2. GENERATION",
        "  (Gen1→Gen8)",
        "⬇",
        "3. HP",
        "  (Low→High)",
        "⬇",
        "4. TYPE",
        "  (Normal→Fairy)",
        "⬇",
        "5. NAME",
        "  (A→Z)"
      ];
    } else if (currentSortMode.contains("Type")) {
      rules = [
        "1. Normal",
        "2. Fire",
        "3. Water",
        "4. Electric",
        "5. Grass",
        "6. Ice",
        "7. Fighting",
        "8. Poison",
        "9. Ground",
        "10. Flying",
        "11. Psychic",
        "12. Bug",
        "13. Rock",
        "14. Ghost",
        "15. Dragon",
        "16. Dark",
        "17. Steel",
        "18. Fairy"
      ];
    }

    return Container(
      width: 150,
      height: 260,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Divider(color: Colors.grey[600], height: 15),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: rules.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    rules[index],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Roboto'),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  CONSOLE WINDOW
  Widget _buildConsoleWindow() {
    return Container(
      width: 170,
      height: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.greenAccent.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("COMPARATOR",
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold)),
          Divider(color: Colors.greenAccent.withOpacity(0.3), height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(consoleValA,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text("VS", style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text(consoleValB,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: consoleStatusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: consoleStatusColor.withOpacity(0.6)),
            ),
            child: Text(
              consoleDecision.toUpperCase(),
              style: TextStyle(
                  color: consoleStatusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          )
        ],
      ),
    );
  }

  // NEW ANALYSIS POPUP
  void showAnalysisDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          width: 800,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.greenAccent, size: 28),
                  SizedBox(width: 10),
                  Text("ANALYSIS & OBSERVATION",
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ],
              ),
              Divider(color: Colors.greenAccent.withOpacity(0.5), height: 30),

              // THE TRANSPARENT GREEN TEXT BOX
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), // Transparent Green
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    "We saw that every sorting choice followed the exact same pattern of \"passes,\" well of course we used bubble sort where it checks and compares each and one, one by one.\n\n"
                    "Our analysis showed that simple sorts like Generation or Evolution looked fast and organized because the cards moved in big chunks; there were only a few groups to sort.\n\n"
                    "As we’ve observed, in the categories of sorts, Generation and Evolution Stage are the ones who look fast and organized when getting sorted since there’s only a few groups to sort. On the other hand, HP, Type or the Alphabetical ones looked a lot ‘messier’ to say since almost every card has a unique value, making the algorithm do a lot more small and individual swaps.\n\n"
                    "As for the All-in-One or in the program called ‘Multi’, it is the most interesting one afterall it is inspired by the 'Order By’ of SQL. It incorporated all the other behaviors of the other categories of sort by creating a structured tiered list. It separated cards with the provided hierarchy Evo -> Gen -> HP -> Type -> Name, where everything is properly sorted. A standard sort only checks one rule like ‘is A bigger than B?’. This mode checks up to five rules for every single comparison, making the sort result look more organized than the simple sorts, even though the computer was doing the same amount in the background; simply saying that it was more efficient.",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        height: 1.6, // Better line spacing for reading
                        fontFamily: 'Roboto'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("Close"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //  LANDING PAGE
  Widget buildLanding() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://i.imgur.com/mTMFOgN.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        )),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "GROUP 1\nPOKÉDEX",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellowAccent[700],
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  height: 1.1,
                  shadows: [
                    Shadow(offset: Offset(-3, -3), color: Colors.blue[900]!),
                    Shadow(offset: Offset(3, -3), color: Colors.blue[900]!),
                    Shadow(offset: Offset(-3, 3), color: Colors.blue[900]!),
                    Shadow(offset: Offset(3, 3), color: Colors.blue[900]!),
                    Shadow(
                        offset: Offset(6, 6),
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.6)),
                  ],
                ),
              ),
              SizedBox(height: 80),
              InkWell(
                onTap: () {
                  if (mainBgmPlayer.state != PlayerState.playing) {
                    _playMainBgm();
                  }
                  setState(() => currentState = AppState.selection);
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A5F0A), Color(0xFF2E8B57)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.amberAccent, width: 4),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: Offset(0, 10)),
                      BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Text(
                    "START ADVENTURE",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              offset: Offset(2, 2),
                              blurRadius: 2)
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelection() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        image: DecorationImage(
          image: NetworkImage("https://i.imgur.com/2cMCqKG.png"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Text("Select Sorting Logic",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          SizedBox(height: 30),
          ...allSortModes.map((m) => modeButton(m)).toList(),
          SizedBox(height: 30),

          // NEW BUTTON ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BUTTON 1: HOME
                InkWell(
                  onTap: () => setState(() => currentState = AppState.landing),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 160, // Fixed width to fit row
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0A5F0A), Color(0xFF2E8B57)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.amberAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("HOME",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2)
                                ])),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 20), // Spacing between buttons

                // ANALYSIS
                InkWell(
                  onTap: showAnalysisDialog, // Calls the popup
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 160,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[900]!,
                          Colors.blue[600]!
                        ], // Blue to distinguish
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.science, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("ANALYSIS",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2)
                                ])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget modeButton(String mode) {
    Color btnColor = _getModeColor(mode);
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8), // slightly tighter spacing
      child: ElevatedButton(
        onPressed: () => initSort(mode),
        style: ElevatedButton.styleFrom(
          fixedSize: Size(300, 55), // slightly wider for the long text
          backgroundColor: btnColor.withOpacity(0.6),
          side: BorderSide(color: btnColor, width: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          shadowColor: btnColor.withOpacity(0.5),
          elevation: 5,
        ),
        child: Text(mode,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16, // slightly smaller font to fit text
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
      ),
    );
  }

  Widget sideButton(String mode, bool isLeft) {
    Color btnColor = _getModeColor(mode);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: isSorting ? null : () => handleChainSort(mode),
        child: Container(
          width: 170,
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: isSorting
                ? Colors.grey.withOpacity(0.8)
                : btnColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: isSorting ? Colors.grey : Colors.white.withOpacity(0.6),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4)),
              if (!isSorting)
                BoxShadow(
                    color: btnColor.withOpacity(0.7),
                    blurRadius: 10,
                    spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  mode
                      .replaceAll(" (Low->High)", "")
                      .replaceAll("All-in-One ", ""), // Shorten text
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  SIMULATION PAGE
  Widget buildSimulation() {
    double cardWidth = 110;
    double cardHeight = 160;
    int columns = 6;
    List<String> available =
        allSortModes.where((m) => m != currentSortMode).toList();

    // Split available buttons dynamically
    int mid = (available.length / 2).ceil();
    List<String> leftModes = available.sublist(0, mid);
    List<String> rightModes = available.sublist(mid);

    return LayoutBuilder(builder: (context, constraints) {
      double screenW = constraints.maxWidth;
      double gridTotalW = (columns * cardWidth) + ((columns - 1) * 10);
      double startX = (screenW - gridTotalW) / 2;
      if (startX < 0) startX = 10;

      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://i.imgur.com/2cMCqKG.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black87,
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        uiTimer?.cancel();
                        sortingBgmPlayer.stop();
                        mainBgmPlayer.resume();
                        setState(() => currentState = AppState.selection);
                      }),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(statusMessage,
                          style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Swaps: $swapsCount",
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text("Compares: $comparesCount",
                          style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text("Time: $timeString",
                          style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  )
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  // GRID
                  ...originalList.map((record) {
                    int currentIdx =
                        workingList.indexWhere((r) => r.id == record.id);
                    if (currentIdx == -1) return SizedBox();
                    int col = currentIdx % columns;
                    int row = currentIdx ~/ columns;
                    double leftPos = startX + (col * (cardWidth + 10));
                    double topPos = (row * (cardHeight + 20)) + 30.0;
                    Color border = Colors.grey[800]!;
                    double borderWidth = 1;
                    if (currentIdx == indexA || currentIdx == indexB) {
                      border = Colors.yellow;
                      borderWidth = 4;
                    }
                    if (currentIdx == indexA && statusMessage == "Swapping!") {
                      border = Colors.redAccent;
                    }
                    return AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      left: leftPos,
                      top: topPos,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: border, width: borderWidth),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.black45,
                                offset: Offset(2, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  record.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      Center(child: Icon(Icons.broken_image)),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.75),
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text(record.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // LEFT BUTTONS
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            leftModes.map((m) => sideButton(m, true)).toList(),
                      ),
                    ),
                  ),

                  // RIGHT BUTTONS
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: rightModes
                            .map((m) => sideButton(m, false))
                            .toList(),
                      ),
                    ),
                  ),

                  // LEFT REFERENCE WINDOW
                  Positioned(
                    top: 20,
                    left: 16,
                    child: _buildReferenceWindow(),
                  ),

                  // RIGHT CONSOLE WINDOW
                  Positioned(
                    top: 20,
                    right: 16,
                    child: _buildConsoleWindow(),
                  ),

                  // CONTROLS
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: "btnReset",
                          onPressed: handleReset,
                          label: Text("RESET"),
                          icon: Icon(Icons.refresh),
                          backgroundColor: Colors.blue[700],
                        ),
                        SizedBox(width: 20),
                        isSorting
                            ? FloatingActionButton.extended(
                                heroTag: "btnStop",
                                onPressed: handleStop,
                                label: Text("STOP"),
                                icon: Icon(Icons.pause),
                                backgroundColor: Colors.red,
                              )
                            : FloatingActionButton.extended(
                                heroTag: "btnStart",
                                onPressed: startSimulation,
                                label: Text(
                                    stopRequested && statusMessage == "Stopped"
                                        ? "RESUME"
                                        : "START SORT"),
                                icon: Icon(Icons.play_arrow),
                                backgroundColor: Colors.green,
                              ),
                      ],
                    ),
                  ),

                  // RESULT POPUP
                  if (showResultPopup)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.8),
                        child: Center(
                          child: Container(
                            width: 320,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E1E1E).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 15,
                                    spreadRadius: 5),
                                BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.greenAccent
                                                .withOpacity(0.4),
                                            blurRadius: 20)
                                      ]),
                                  child: Icon(Icons.check_circle,
                                      color: Colors.greenAccent, size: 60),
                                ),
                                SizedBox(height: 15),
                                Text("Sort Complete!",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1)),
                                Divider(height: 30, color: Colors.grey[800]),
                                _resultRow("Sorted by:", currentSortMode,
                                    Colors.cyanAccent),
                                SizedBox(height: 10),
                                _resultRow("Sorted from:", previousSortMode,
                                    Colors.purpleAccent),
                                SizedBox(height: 10),
                                _resultRow("Total Swaps:", "$swapsCount",
                                    Colors.orangeAccent),
                                SizedBox(height: 10),
                                _resultRow("Compares:", "$comparesCount",
                                    Colors.pinkAccent),
                                SizedBox(height: 10),
                                _resultRow("Sorted in:", timeString,
                                    Colors.yellowAccent),
                                SizedBox(height: 25),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showResultPopup = false;
                                    });
                                    mainBgmPlayer.resume();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    elevation: 5,
                                    shadowColor: Colors.greenAccent,
                                  ),
                                  child: Text("Okay",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _resultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentState == AppState.landing) return buildLanding();
    if (currentState == AppState.selection) return buildSelection();
    return buildSimulation();
  }
}
