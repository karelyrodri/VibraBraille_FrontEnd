
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/bloc/notes_bloc.dart';
import '../../data/notesData.dart';
import '../braille.dart';
import '../menu/settings.dart';

class NoteDetailsPage extends StatefulWidget {
  final Note note;
  final SharedPreferences sp;
  const NoteDetailsPage({super.key, required this.note, required this.sp});

  @override
  State<NoteDetailsPage> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  late double fontSize;
  late String title;
  late Widget actionButtons;



  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _titleController = TextEditingController(text: widget.note.title);
    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    actionButtons = fontSizeButtons();
    title = widget.note.title;
    fontSize = widget.sp.containsKey("fontSize") ? widget.sp.getDouble("fontSize")! : 75;
  }


  _handleTabChange() {
      setState(() =>{
        actionButtons = _tabController.index == 2 ?
        const SizedBox() : fontSizeButtons()
      });
  }


  @override
  Widget build(BuildContext context) {
    Note note = widget.note;
    _tabController.addListener(_handleTabChange);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: actionButtons,
      appBar: AppBar (toolbarHeight: 35, centerTitle: true, backgroundColor: const Color.fromRGBO(39, 71, 110, 1),
            title: GestureDetector(
                onTap: () {
                    changeTitle(note.noteId);
                  },
                child: Text(title, semanticsLabel: title,
                  style: const TextStyle(fontSize: 30), textAlign: TextAlign.center,),
            ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(child: Text("Text" , semanticsLabel: "View note as text",
                style: TextStyle(fontSize: 22)),
            ),
            Tab(child: Text("Braille Text", semanticsLabel: "View note as braille text",
                style: TextStyle(fontSize: 21)),
            ),
            Tab( child: Text("Braille", semanticsLabel: "View note as braille vibration",
                style: TextStyle(fontSize: 22)),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: text(note),
          ),
          Center(
            child: brailleText(note),
          ),
          Center(
            child: braille(note),
          ),
        ],
      ),

    );
  }

  SizedBox text(Note note) {
    return
    SizedBox(
      height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView( child:
        Text(note.ascii, semanticsLabel: note.ascii,
        style: TextStyle(fontSize: fontSize))),
        );
  }
   SizedBox brailleText(Note note) {
    List<String> unicode = note.braille.split(",");
    String braille = "";
    final Pattern unicodePattern = RegExp(r'\\u([0-9A-Fa-f]{4})');
    for (int i = 0; i < unicode.length; i++) {
      String str = "\\u${unicode[i]}";
      final String unicodeStr = str.replaceAllMapped(unicodePattern, (Match unicodeMatch) {
        final int hexCode = int.parse(unicodeMatch.group(1)!, radix: 16);
        return String.fromCharCode(hexCode);
      });
      braille += unicodeStr;

    }
     return  SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView( child:
            Text(braille, semanticsLabel: note.ascii,
                style: TextStyle(fontSize: fontSize * 1.1))),
        );

  }

  Container braille(Note note) {
    return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *.05),
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: BrailleTranslation(note.binary, widget.sp).getBrailleTranslation(),
        )
    );
  }

  changeTitle(int id) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('Edit Title',
                semanticsLabel: "Edit title name"),
            content: TextField(controller: _titleController,
                onChanged: (value) => {
                  title = value,
                }
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => {
                  SetTitle(context, title, id, widget.sp),
                  setState(() => {})
                },
                child: const Text(
                  'Save', semanticsLabel: "Save title ",),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                child: const Text('Cancel', semanticsLabel: "Cancel",),
              ),
            ],
          ),
    );
  }


  Row fontSizeButtons() {
    return
       Row ( crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
           backgroundColor: const Color.fromRGBO(39, 71, 110, 1),
            onPressed: () => {
            FeedbackStrength(widget.sp.getInt("hapticFeedback")!),
              setState (() {
                 if (fontSize > 20) fontSize -= 5;
              })
            },
            child: const Icon(Icons.remove, size: 50)),
            const Padding(padding: EdgeInsets.only(right: 20)),
        FloatingActionButton(
          backgroundColor: const Color.fromRGBO(39, 71, 110, 1),
            onPressed: () => {
            FeedbackStrength(widget.sp.getInt("hapticFeedback")!),
              setState (() {
                if (fontSize < 200) fontSize += 5;
              })
            },
            child: const Icon(Icons.add, size: 50)),
        const Padding(padding: EdgeInsets.only(right: 10)),
      ],
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

}

class SetTitle {
  SetTitle(BuildContext context, String newTitle, int id , SharedPreferences sp) {
    final bloc = NoteBloc(sp);
    bloc.noteChange.add([id.toString(), newTitle]);
    WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<Note?>(
            stream: bloc.noteEditStream,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return const Text("Title changed", semanticsLabel: "title changed",
                  style: TextStyle(fontSize: 30),);
              }
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