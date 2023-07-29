import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'notesData.dart';

class BrailleClient {
  final _host = 'http://ec2-3-142-74-196.us-east-2.compute.amazonaws.com:8000/notes/translate/';
  Future<Note?> fetchTranslation(String imagePath, String bearer) async {
    final request = http.MultipartRequest('POST', Uri.parse(_host));
    request.headers.addAll(<String, String>{
    'Authorization': "Bearer $bearer",
      'Content-Type': "multipart/form-data",
    });
    request.files.add(http.MultipartFile(
        'img',
        File(imagePath).readAsBytes().asStream(),
        File(imagePath).lengthSync(),
        contentType: MediaType('image', 'jpg'),
        filename: "note.jpg"
    ));

    final streamResponse = await request.send();


    if (streamResponse.statusCode == 201 && streamResponse.contentLength! > 15) {
      http.Response response = await http.Response.fromStream(streamResponse);
      Map<String, dynamic>  noteJson = jsonDecode(response.body);
      return Note.fromJson(noteJson, noteJson["id"]);
    } else
      if (streamResponse.statusCode == 500) {
      return null; // if null pop up alert no text detected
    } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to retrieve translation.');
      }

  }



}
