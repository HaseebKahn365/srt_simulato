class Process {
  int arrival;
  int remainingBurst;
  int position;
  int pid;
  bool isExecuting;
  Process(
      {required this.arrival,
      required this.remainingBurst,
      required this.position,
      required this.pid,
      required this.isExecuting});
  void reduceBurst() {
    this.remainingBurst--;
  }
}

//Lists of objects:
// List<process>TempCreated=[]; //this is the list of process objects that will contain all that process that are created using the create process floating action button but have not been yet added to the list of ActiveProcesses list.
// List<process>ActiveProcesses=[];// this is the list of processes that are running on the processor.

//Global variables and methods:

List<Process> tempCreated = [];
List<Process> activeProcesses = [];

int systemClock = 0;
int processCounter = 0;

void createProcess() {
  tempCreated.add(Process(
      arrival: systemClock,
      remainingBurst: 0,
      position: 0,
      pid: processCounter,
      isExecuting: false));
  processCounter++;
}

void feedToProcessor() {
  activeProcesses.addAll(tempCreated);
  adjustPositions();
}

void adjustPositions() {
  activeProcesses.removeWhere((element) => element.remainingBurst == 0);
  activeProcesses.sort((a, b) => a.remainingBurst.compareTo(b.remainingBurst));
  for (int i = 0; i < activeProcesses.length; i++) {
    activeProcesses[i].position = i;
  }
  for (int i = 0; i < activeProcesses.length; i++) {
    activeProcesses[i].isExecuting = false;
  }
  activeProcesses[0].isExecuting = true;
}
