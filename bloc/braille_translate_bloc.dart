import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/brailleData.dart';
import '../data/notesData.dart';
import 'package:rxdart/rxdart.dart';

class BrailleBloc {
  final _client = BrailleClient();
  final _brailleController = StreamController<String>();
  Sink<String> get imagePath => _brailleController.sink;
  late Stream<Note?> translateStream;

  BrailleBloc(SharedPreferences sp) {
      translateStream = _brailleController.stream.switchMap(
          (imagePath) => _client.fetchTranslation(imagePath, sp.getString("accessToken")!).asStream());
  }

  void dispose() {
    _brailleController.close();

  }
}