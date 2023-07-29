import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/braille_translate_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../data/notesData.dart';
import 'menu/settings.dart';

class DisplayBrailleScreen extends StatefulWidget {
  final String imagePath;
  final SharedPreferences sp;
  const DisplayBrailleScreen({super.key, required this.imagePath, required this.sp});

  @override
  State<DisplayBrailleScreen> createState() => _DisplayBrailleScreenState();
}


class _DisplayBrailleScreenState extends State<DisplayBrailleScreen> {
  late int noteId;
  String title = "";
  late Widget result;


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    result = _buildResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( actions: [popUp(context)], backgroundColor: const Color.fromRGBO(39, 71, 110, 1)),
      body:
    Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *.08),
      child: result

    ),//,

    );
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }


  TextButton popUp(BuildContext context) {
    return TextButton(
      onPressed: () =>
          showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  content: const Text('Save to notes?',
                      semanticsLabel: "Would you like to save to notes?",
                  style: TextStyle(fontSize: 25),),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => {Navigator.pop(context),
                        Navigator.pop(context),}, // pop context
                      child: const Text(
                         'Save', semanticsLabel: "Save to notes ",
                      style: TextStyle(fontSize: 18),),
                    ),
                    TextButton(
                      onPressed: () => {
                        deleteNote(),
                        Navigator.of(context).pop(),
                        // Navigator.pop(context),
                        },
                      child: const Text("Don't Save", semanticsLabel: "Don't Save",
                          style: TextStyle(fontSize: 18)),
                    ),
                    TextButton(
                      onPressed: () => {
                        Navigator.of(context).pop(),
                      },
                      child: const Text("Cancel", semanticsLabel: "Cancel",style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
          ),
      child: const Text('Done', semanticsLabel: "Done",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
    );
  }


  Widget _buildResult() {
    final bloc = BrailleBloc(widget.sp);
    bloc.imagePath.add(widget.imagePath);
    return StreamBuilder<Note?>(
      stream: bloc.translateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data == null) {
          return Center(child: AlertDialog( scrollable: true,
              title: const Text('No text detected', semanticsLabel: "No text detected in image",
                style: TextStyle(fontSize: 30),),
              content: const Text('There was no text detected! \nPlease try again',
                semanticsLabel: "There was no text detected! Please try again",
                style: TextStyle(fontSize: 25),),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>  { Navigator.of(context).pop()
                  },
                  child: const Text('Try again', semanticsLabel: "Try again", style: TextStyle(fontSize: 25),),
                )]
          ));
        } else {
          noteId = snapshot.data!.noteId;
          return ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: BrailleTranslation(snapshot.data!.binary, widget.sp)
                .getBrailleTranslation(),
          );
        }
      },
    );

  }

    deleteNote() {
      final bloc = NoteBloc(widget.sp);
      bloc.noteId.add(noteId);
      bloc.noteDeleteStream;
      WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
          context: context,
          builder: (BuildContext context) {
        return StreamBuilder<String?>(
            stream: bloc.noteDeleteStream,
            builder: (context, snapshot) {

              return const Center(child: CircularProgressIndicator());
            });
          },
      );});
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
  }
}
class BrailleTranslation {
  List<BrailleCell> brailleCellList = <BrailleCell>[];
  List<Container> brailleTranslation = <Container>[];
  late SharedPreferences sp;

  BrailleTranslation(String binaryBraille, SharedPreferences preferences) {
    sp = preferences;
    buildTranslation(binaryBraille);
  }

  buildTranslation(String binaryBraille) {
    //slice every 6 positions,
    int numOfCells = binaryBraille.length ~/ 6;
    int start = 0;
    int end = 6;
    for (int cellNum = 0; cellNum < numOfCells; cellNum++) {
      String binaryCell;
      bool isFirstCell = cellNum == 0 ? true : false;
      bool isLastCell;
      if (cellNum == numOfCells - 1) {
        isLastCell = true;
        binaryCell = binaryBraille.substring(start);
      } else {
        isLastCell = false;
        binaryCell = binaryBraille.substring(start, end);
      }
      brailleCellList.add(BrailleCell(isFirstCell, isLastCell, binaryCell, sp));
      start += 6;
      end += 6;
    }
    int len = brailleCellList.length;
    for (int i = 0; i < len; i++) {
      BrailleCell curCell = brailleCellList[i];
      if (i < len - 1) curCell.setNextCell(brailleCellList[i + 1]);
      brailleTranslation.add(
          Container(width: 160,
              margin: const EdgeInsets.only(left: 25, right: 25),
              alignment: Alignment.center,
              child: curCell.getBrailleCell())
      );
      //set next node and add to  braille cell translation
    }
  }

  List<Container> getBrailleTranslation() {
    return brailleTranslation;
  }

}

class BrailleCell {
  bool enabled = false;
  late bool isSpace;
  late bool _lastCell;
  late BrailleCell next;
  List<bool> read = <bool>[false, false, false, false, false, false];
  late GridView _brailleCell;
  late SharedPreferences sp;
  int count = 1;


  BrailleCell(bool isFirstCell, bool isLastCell, String binaryBraille, SharedPreferences preferences) {
    sp = preferences;
    enabled = isFirstCell;
    _lastCell = isLastCell;
    isSpace = !binaryBraille.contains("1");
    _brailleCell = buildBrailleCell(binaryBraille);

  }

  GridView buildBrailleCell(String binaryBraille) {
    List<FloatingActionButton> brailleCells = <FloatingActionButton>[];
    List<int> positions = [0, 3, 1, 4, 2, 5]; //110000
    for (int i = 0; i < binaryBraille.length; i++) {
      if (binaryBraille[positions[i]] == "0") {
        read[positions[i]] = true;
        brailleCells.add(
            const FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.white38,
              enableFeedback: false,
              mini: true,
              onPressed: null,
            ));
      } else if (binaryBraille[positions[i]] == "1"){
        brailleCells.add(
            FloatingActionButton(
                heroTag: null,
              backgroundColor: const Color.fromRGBO(34, 96, 178, 1),
              enableFeedback: enabled,
              mini: true,
              onPressed: () {
                if (enabled) {
                  FeedbackStrength(sp.getInt("hapticFeedback")!);
                    read[positions[i]] = true;
                    if (isAllRead()) {
                      if (!_lastCell) {
                        //call next set of cells and set state
                        next.enabled = true;
                        if (next.isSpace) { // if there is a space assume more chars
                          next.next.enabled = true;
                        }
                      }
                    }
                  }
              }
            ));
      }
    }
    return GridView.count(
        padding: const EdgeInsets.only(left: 3, right: 3),
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
        crossAxisCount: 2,
        children: brailleCells,
    );
  }

  bool isAllRead() {
    return !read.contains(false);
  }

  setNextCell(BrailleCell nextCell) {
    next = nextCell;
  }

  GridView getBrailleCell() {
    return _brailleCell;
  }

}

