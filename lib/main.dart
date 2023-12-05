// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:srt_simulato/classes_and_vars/process.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SRTSimulator());
}

class SRTSimulator extends StatefulWidget {
  const SRTSimulator({Key? key}) : super(key: key);

  @override
  State<SRTSimulator> createState() => _SRTSimulatorState();
}

const double narrowScreenWidthThreshold = 450;

const Color m3BaseColor = Color(0xff6750a4);
const List<Color> colorOptions = [
  m3BaseColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
  Colors.lime,
  Colors.red,
  Colors.purple,
  Colors.brown,
  Colors.cyan,
  Colors.indigo,
  Colors.amber,
];
const List<String> colorText = <String>[
  "M3 Baseline",
  "Blue",
  "Teal",
  "Green",
  "Yellow",
  "Orange",
  "Pink",
  "Lime"
];

class _SRTSimulatorState extends State<SRTSimulator> {
  bool useMaterial3 = true;
  bool useLightMode = true;
  int colorSelected = 0;
  int screenIndex = 0;

  late ThemeData themeData;

  @override
  initState() {
    super.initState();
    themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
  }

  ThemeData updateThemes(int colorIndex, bool useMaterial3, bool useLightMode) {
    return ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      useMaterial3: useMaterial3,
      brightness: useLightMode ? Brightness.light : Brightness.dark,
    );
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void handleBrightnessChange() {
    setState(() {
      useLightMode = !useLightMode;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelected = value;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SRT Simulator',
      themeMode: useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: themeData,
      home: HomeScreen(
        useLightMode: useLightMode,
        handleBrightnessChange: handleBrightnessChange,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool useLightMode;
  final VoidCallback handleBrightnessChange;

  const HomeScreen({
    Key? key,
    required this.useLightMode,
    required this.handleBrightnessChange,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Process newProcess = Process(
      arrival: 0,
      remainingBurst: 0,
      position: 0,
      pid: 0,
      isExecuting: false,
      processColor: Colors.black);

  Timer? timer;
  Timer? newtimer;

  //create a method that return Color from colorOptions list

  Color lastProcessColor = Colors.transparent;

  Color getColor() {
    int index = Random().nextInt(colorOptions.length - 1);
    lastProcessColor = colorOptions[index];
    return lastProcessColor;
  }

  //run the cpu cycle after every second until the list of active processes is empty using timer and also adjust the positions of the processes after every cycle.
  void runCycle() {
    newtimer = Timer.periodic(Duration(seconds: 1), (t) {
      try {
        setState(() {
          systemClock++;
          if (activeProcesses.isNotEmpty) {
            for (int i = 0; i < activeProcesses.length; i++) {
              if (activeProcesses[i].isExecuting) {
                activeProcesses[i].reduceBurst();
              }
            }
            adjustPositions();
          }
        });
      } catch (e) {
        print('An error occurred: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startCpuCycle();
  }

  void startCpuCycle() {
    runCycle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SRT Simulator'),
        //adding an action to toggle the theme
        actions: <Widget>[
          //adding an exclamation icon button that launches the about me page
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // https://github.com/HaseebKahn365/srt_simulato
              launchUrl(
                  Uri.parse('https://github.com/HaseebKahn365/srt_simulato'));
            },
          ),
          IconButton(
            icon:
                Icon(widget.useLightMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.handleBrightnessChange,
          ),
          //adding an outline action button with text for reset everything. for now it will do nothing
          Container(
            padding: EdgeInsets.only(right: 8),
            height: 30,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  resetAll();
                });
              },
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          //here now we will define the boxes for processor which will be in the top centre.
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 160,
              width: 270,
              //rounded outlined borders
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(12.0), // Border radius
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text("Processor"),
                  ),
                  //display the system clock
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text("System Clock: $systemClock"),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Active Process:"),
                            Container(
                                //this is the container for the active process
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: activeProcesses.isEmpty
                                      ? Colors.transparent
                                      : activeProcesses[0]
                                          .processColor
                                          .withOpacity(0.3),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    // Border color
                                    width: 1.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Border radius
                                ),
                                //here display only the active process

                                child: activeProcesses.isEmpty
                                    ? Container()
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              "PID: ${activeProcesses[0].pid}"),
                                          Text(
                                              "Burst: ${activeProcesses[0].remainingBurst}"),
                                        ],
                                      ))
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // the following box the list of active processes below the processor
          ActiveProcesses(),

//? this is the box for list of temporarily created processes
          Container(
            height: 120,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                // Border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(12.0), // Border radius
            ),
            child: Row(
              children: [
                //an outline icon buttonn with arrow up
                OutlinedButton(
                    onPressed: () {
                      setState(() {
                        feedToProcessor();
                        adjustPositions();
                        //clear the tempCreated list
                        tempCreated = [];
                      });
                    },
                    child: Icon(Icons.arrow_upward_rounded),
                    style: OutlinedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8),
                    )),
                //the list view with horizontal scroll direction
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      //displaying the list of temporary processes
                      itemCount: tempCreated.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: tempCreated[index]
                                    .processColor
                                    .withOpacity(0.3),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  // Border color
                                  width: 1.0, // Border width
                                ),
                                borderRadius: BorderRadius.circular(
                                    12.0), // Border radius
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("PID: ${tempCreated[index].pid}"),
                                  Text(
                                      "Burst: ${tempCreated[index].remainingBurst}"),
                                ],
                              )),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),

          //the square box alligned at the bottom left corner for the new process being created.

          //? this is the box for the new process being created
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 30),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height: 130,
                width: 130,

                //create a rounded border with a glow of the color of the newProcess
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(12.0), // Border radius
                  boxShadow: [
                    BoxShadow(
                      //display the color of the last process in the process
                      color: newProcess.processColor == Colors.black
                          ? Colors.transparent
                          : lastProcessColor.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    //check if the burst is 0 then don't display anything
                    newProcess.remainingBurst == 0
                        ? Container()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("PID: $processCounter"),
                              Text("Burst: ${newProcess.remainingBurst}"),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
      //create a custom floating action button for creating new processes. when i press and hold it, it should increase the remaining burst of the new process by 1 second. when i release it, it should add the process to the list of temporary processes.

      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onLongPressStart: (details) {
            // Start a timer that increments the remainingBurst time of the new process every second.

            timer = Timer.periodic(Duration(milliseconds: 180), (t) {
              setState(() {
                newProcess.remainingBurst++;
                print(newProcess.remainingBurst);
              });
            });
          },
          onLongPressEnd: (details) {
            // Cancel the timer when the long press ends.
            timer?.cancel();
            // Add the new process to the list of temporary processes.
            setState(() {
              newProcess.pid = processCounter;
              tempCreated.add(newProcess);
              processCounter++;
              newProcess = Process(
                arrival: 0,
                remainingBurst: 0,
                position: 0,
                pid: 0,
                //select a random color from the list colorOptions
                processColor: getColor(),
                isExecuting: false,
              );
            });
            print(tempCreated);
          },
          child: Container(
            height: 60,
            child: ElevatedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Create Process"),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//! below are the unused widgets

class newProcessBox extends StatelessWidget {
  const newProcessBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 30),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          height: 130,
          width: 130,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              // Border color
              width: 1.0, // Border width
            ),

            borderRadius: BorderRadius.circular(12.0), // Border radius
          ),
        ),
      ),
    );
  }
}

class ActiveProcesses extends StatelessWidget {
  const ActiveProcesses({
    super.key,
  });

  @override
  //list containing processes whose isExecuting is is false

  Widget build(BuildContext context) {
    var nonExecutingProcesses = activeProcesses
        .where((element) => element.isExecuting == false)
        .toList()
        .cast<Process>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //a vertical box for the list of active processes
        height: 250,
        width: 270,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            // Border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(12.0), // Border radius
        ),

        child: Column(children: [
          //title ready queue processes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Ready Queue"),
                //create a list view with vertical scroll direction of cards to represent processes.
                //for now just create 10 cards with height 20
                Container(
                  height: 200,
                  width: 220,
                  child: ListView.builder(
                    //displaying the list of activeProcesses
                    itemCount: nonExecutingProcesses.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            color: nonExecutingProcesses[index]
                                .processColor
                                .withOpacity(0.3),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius:
                                BorderRadius.circular(12.0), // Border radius
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("PID: ${nonExecutingProcesses[index].pid}"),
                              Text(
                                  "Burst: ${nonExecutingProcesses[index].remainingBurst}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          //a list of cards for the active processes
        ]),
      ),
    );
  }
}

class Processor extends StatelessWidget {
  const Processor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: 270,
      //rounded outlined borders
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(12.0), // Border radius
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text("Processor"),
          ),
          //display the system clock
          Align(
            alignment: Alignment.topCenter,
            child: Text("System Clock: $systemClock"),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Active Process:"),
                    Container(
                      //this is the container for the active process
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius:
                            BorderRadius.circular(12.0), // Border radius
                      ),
                    )
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
