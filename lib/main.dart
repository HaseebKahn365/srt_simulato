// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

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
  const SRTSimulator({super.key});

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
        // make the new Product Sans font the default font
        fontFamily: 'Product Sans',
        colorSchemeSeed: colorOptions[colorSelected],
        useMaterial3: useMaterial3,
        brightness: useLightMode ? Brightness.light : Brightness.dark);
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
    //I want the boyinspace.jpg to be the background image
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SRT Simulator',
      themeMode: useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SRT Simulator'),
          //add an action to toggle the theme
          actions: <Widget>[
            IconButton(
              icon: Icon(useLightMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: handleBrightnessChange,
            ),
            //add an outline action button with text for reset everything. for now it will do nothing
            Container(
              height: 30,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            //creating boxes for processor, temp created processes and process creation box.

            //processor box contains a smaller box that will contain the running process
          ],
        ),
      ),

      //create a floating actioon button
    );
  }
}
