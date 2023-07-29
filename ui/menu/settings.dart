

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key, required this.sp});
  final SharedPreferences sp;

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage>{
  // bool _autoCapture = false;
  // double _brailleCells = 6;
  // bool _brailleCellsExpanded = false;
  late double _vibrationIntensity;
  bool _vibrationExpanded = false;
  late double _fontSize;
  bool _fontExpanded = false;
  // bool _borderHighlight = false;
  // bool _keyboardsExpanded = false;
  String _defaultKeyboard = "Standard";



  @override
  void initState() {
    super.initState();
    _fontSize = widget.sp.containsKey("fontSize") ? widget.sp.getDouble("fontSize")! : 75;
    _vibrationIntensity =  widget.sp.containsKey("hapticFeedback") ?
                          widget.sp.getInt("hapticFeedback")!.toDouble() : 3;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: const Color.fromRGBO(39, 71, 110, 1),
          title: const Text('Settings', style: TextStyle(fontSize: 25),)),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ExpansionTile(
              maintainState: true,
                  title: menuText('Vibration Intensity'),
                  children: <Widget>[
                  //slider,
                  Slider(
                    activeColor: const Color.fromRGBO(39, 71, 110, 1),
                  value: _vibrationIntensity ,
                  min: 1,
                  max: 3,
                  divisions: 2,
                  label: feedbackLabel(_vibrationIntensity),
                  onChangeEnd: (value) {
                    setState(() {
                      FeedbackStrength(_vibrationIntensity.toInt());
                    });},
                  onChanged: (value) {
                  setState(() {
                  _vibrationIntensity = value;
                  widget.sp.setInt("hapticFeedback", _vibrationIntensity.toInt());
                  FeedbackStrength(_vibrationIntensity.toInt());
                  });},
                  )],
                  onExpansionChanged: (bool expanded) {
                  setState(() => _vibrationExpanded = expanded);
                  },
                ),
            const Divider(thickness: 2,),
            ExpansionTile(
              maintainState: true,
                  title: menuText('Note Font Size'),
                  children: <Widget>[
                  //slider,
                  Slider(activeColor: const Color.fromRGBO(39, 71, 110, 1),
                  value: _fontSize,
                  min: 20,
                  max: 200,
                  divisions: 18,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                  setState(() {
                  _fontSize = value;
                  widget.sp.setDouble("fontSize", value);
                  }); },)],
                  onExpansionChanged: (bool expanded) {
                  setState(() => _fontExpanded = expanded);
                  },
              ),
            const Divider(thickness: 2,),
           // menuText("Color Scheme"),
          ],
        ),

    );

  }

  SizedBox colorThemes(Color color) {
    return SizedBox(
      width: 10.0,
      height: 10.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
            color: color
        ),
      ),
    );
  }

  Text menuText(String text) {
    return Text(text,
      textAlign: TextAlign.center,
      semanticsLabel: text,
      style: const TextStyle(height: 2, fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(39, 71, 110, 1)),
    );
  }

  ListTile keyBoardOption(String keyboard) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 80.0, right: 100),
      leading: Radio<String>(
        value: keyboard,
        groupValue: _defaultKeyboard,
        onChanged: (value) {
          setState(() {
            _defaultKeyboard = value!;
          });
        },
      ),
      title: menuText(keyboard),
      onTap: () {},
    );
  }
  
  String feedbackLabel(double intensity) {
    late String label;
    if (intensity == 1.0) {
      label = "light";
    } else if (intensity == 2.0) {
      label = "medium";
    } else {
      label = "heavy";
    }
    return label;
  }
}

class FeedbackStrength {
  FeedbackStrength(int intensity) {
    switch (intensity) {
      case 1:
        HapticFeedback.lightImpact();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        break;
      case 3:
        HapticFeedback.heavyImpact();
        break;
    }

  }


}

