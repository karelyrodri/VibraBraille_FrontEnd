import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu/menu.dart';
import './braille.dart';
import 'menu/settings.dart';

// A screen that allows users to take a picture using a given camera.
class CameraPage extends StatefulWidget {
  final SharedPreferences sp;
  const CameraPage({super.key, required this.sp,});

  @override
  State<CameraPage> createState() => CameraInit();
}

class CameraInit extends State<CameraPage> {
  late final Future<List<CameraDescription>> cameras = availableCameras();

  @override
   initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SizedBox(
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<List<CameraDescription>>(
              future: cameras,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return Camera(camera: snapshot.data!.first, sp: widget.sp);
                }
                return const Center(child: CircularProgressIndicator());
              }))
    );
  }
}



class Camera extends StatefulWidget {

  const Camera({super.key, required this.camera,  required this.sp});
  final CameraDescription camera;
  final SharedPreferences sp;

  @override
  State<Camera> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    _controller.lockCaptureOrientation();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromRGBO(39, 71, 110, 1)),
      drawer: Menu(context, widget.sp).menuDrawer,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) { //&& sp.containsKey("username")
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  }
                  return const Center(child: CircularProgressIndicator());
                })),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 100,
        height: 120,
        child:
        FloatingActionButton(
          backgroundColor: const Color.fromRGBO(39, 71, 110, 1),
        enableFeedback: true,
        // Provide an onPressed callback.
        onPressed: () async {
          FeedbackStrength(widget.sp.getInt("hapticFeedback")!);
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayBrailleScreen(
                  imagePath: image.path, sp: widget.sp
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.

          }
        },
        child: const Icon(Icons.camera_alt, size: 60,),
      ),

    ));
  }
}

