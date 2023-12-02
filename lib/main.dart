// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:srt_simulato/classes_and_vars/process.dart';

/*SJF(shortest job first) preemptive (Shortest Remaining Time) app using flutter
Defining problem: 
The SRT simulator allows process Analysts to observe the process scheduling of the shortest remaining time in a better way.
Architecture of the application:
This application has only one stateful widget. The entire UI uses the setState() method to update the UI. The following are all the variables and classes used in the application. 
Process Class
Arrival
RemainingBurst
position
Pid
isExecuting
reduceBurst(): this method of the process reduces the burst by  1 second. 
Lists of objects:
List<process>TempCreated=[]; //this is the list of process objects that will contain all that process that are created using the create process floating action button but have not been yet added to the list of ActiveProcesses list.
List<process>ActiveProcesses=[];// this is the list of processes that are running on the processor.
Global variables and methods:
Int system_clock = 0; this is just a variable that is incremented after 1 second representing the time elapsed.
Int process_counter = 0; this is a process counter that is used for assigning unique pid to each new process created. This is incremented when a new process is added to the tempCreated list.
createProcess(): This is the global method that is used to add the process created by floating Action Button to the list of TempCreated. It also assigns the pid, arrival and RemainingBurst to the newly created process.
feedToProcessor(): this is the method that is used when the add button is clicked in the temporarily created list of processes section of the app. Following is what happens in this method: 
1.	Adds all the process objects from the tempCreated list to the ActiveProcessess list.
2.	Calls the adjustPositions() to modify the postions of every process in the list of active processes. 
adjustPositions(): this method is often used. It is used after every clock cycle and also used when the processes are being added to the list of active processes this is because the Shortest Remaining Time scheduling involves readjustment of the processes positions when the new processes arrive. 
Following is what happens in the adjustPositions() method:
1.	For each process where the RemainingBurst is 0, remove this process process from the list of active processes
2.	Sort all the processes in the list of the active processes in ascending order by adjusting the positions of each process by modifying its position data member.
3.	Turn false all the processes’ isExecuting
4.	Turn true the isExecuting of the process whose position is 0 in the active processes list.
RunCycle(): this method is called after every second. This method does the following:
1.	Check if the list of the processes is not empty.
2.	For each process in the active processes list where the isExecuting is true. Then call its reduceBurst(). 
Control flow of the app:
1.	User press and holds the create process FAB to create process. For each second 0.5 seconds that passes when FAB is held pressed, increase the RemainingBurst of the new process. After releasing the button, the process will be added to the list of temporary processes after which we will call the setState() method to update the list on the bottom right corner that contains the temporary processes. Here is how the members of the process are determined when the new process is being  created:
Arrival = current value of the global var system_clock.
RemainingBurst = the time for which the FAB is held pressed.
Position = 0; because it will will be determined by feedToProcessor();
Pid = current value of the process_counter
isExecuting = false;
2.	After creation of the processes the user can use the add button at the bottom left corner section to call feedToProcessor().
3.	The processes will be displayed using cards whose positions will be adjust after every second. 
4.	The process whose data member isExecuting value is true. That one will be displayed in the special area of the CPU Container.
5.	All the remaining processes in the active process list will appear in a Column wrapped in a container of certain height.
 */
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
  Colors.lime
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
      arrival: 0, remainingBurst: 0, position: 0, pid: 0, isExecuting: false);

  Timer? timer;

  //run the cpu cycle after every second until the list of active processes is empty using timer and also adjust the positions of the processes after every cycle.
  void runCycle() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        //check if the list of active processes is not empty
        if (activeProcesses.isNotEmpty) {
          //for each process in the active processes list where the isExecuting is true. Then call its reduceBurst().
          for (int i = 0; i < activeProcesses.length; i++) {
            if (activeProcesses[i].isExecuting) {
              activeProcesses[i].reduceBurst();
            }
          }
          //adjust the positions of the processes
          adjustPositions();
          //increment the system clock
          systemClock++;
        }
      });
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
        //add an action to toggle the theme
        actions: <Widget>[
          IconButton(
            icon:
                Icon(widget.useLightMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.handleBrightnessChange,
          ),
          //add an outline action button with text for reset everything. for now it will do nothing
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
                            )
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    // Border color
                    width: 1.0, // Border width
                  ),

                  borderRadius: BorderRadius.circular(12.0), // Border radius
                ),
                child:
                    //check if the burst is 0 then don't display anything
                    newProcess.remainingBurst == 0
                        ? Container()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("PID: ${newProcess.pid}"),
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
            timer = Timer.periodic(Duration(milliseconds: 300), (t) {
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
                  isExecuting: false);
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
  Widget build(BuildContext context) {
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
                    itemCount: activeProcesses.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
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
                              Text("PID: ${activeProcesses[index].pid}"),
                              Text(
                                  "Burst: ${activeProcesses[index].remainingBurst}"),
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
