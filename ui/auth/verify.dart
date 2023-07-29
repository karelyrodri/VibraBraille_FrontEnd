import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/bloc/auth_bloc.dart';
import 'package:vibra_braille/ui/auth/login.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  final String password;
  final SharedPreferences sp;
  const VerifyPage({super.key, required this.email,  required this.password, required this.sp});

  @override
  State<VerifyPage> createState() => _VerifyState();
}

class _VerifyState extends State<VerifyPage> {
  late String _code;
  final codeController = TextEditingController();
  String _codeText = "Enter verification code";

  @override
  void initState() {
    super.initState();
    resendCode();
  }

//DELETE AND EDIT NOTE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: const Color.fromRGBO(39, 71, 110, 1)),
        body: SizedBox(
           height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView( child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(20)),
            const Text(" Please verify your email", semanticsLabel: "Please verify your email",
              style: TextStyle(fontSize: 30),),
            const Padding(padding: EdgeInsets.all(15)),
                  const Text("Verification code sent to: ", semanticsLabel: "Verification sent to your email",
                    style: TextStyle(fontSize: 28),),
                  Text(widget.email,
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            const Padding(padding: EdgeInsets.all(30)),
            pin(), const Padding(padding: EdgeInsets.only(bottom: 5)),
            Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Padding(padding: EdgeInsets.only(left: 50, bottom: 50)),
                  Text(_codeText, semanticsLabel: _codeText,style: const TextStyle(fontSize: 18),)]),
            SizedBox( width: 175, height: 45,
                child: ElevatedButton(
                  style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(const Color.fromRGBO(39, 71, 110, 1)) ),
              onPressed: _handleSubmitted,
              child: const Text("Submit", semanticsLabel: "Submit",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            )),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [const Text("Didn't receive a code?",semanticsLabel: "Didn't receive a code?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  GestureDetector(
                      onTap: () {
                        resendCode(); },
                      child: const Text(" Resend now", semanticsLabel: "Resend code",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Colors.blue, fontSize: 18), )
                  ),
                ])
          ],
        )))
    );

  }

  sendEmail(String code) async {
    final response = await http.post(
      Uri.parse("https://hourmailer.p.rapidapi.com/send"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "X-RapidAPI-Key": "eda3580202mshbe7c55a8b4e82e7p1b574cjsn37e6bb85c3c1",
        "X-RapidAPI-Host": "hourmailer.p.rapidapi.com"
      },
      body: jsonEncode(<String, String>{
        "toAddress": widget.email,
        "title": "VibraBraille'",
        "message": "Welcome to VibraBraille! Verification code: $code"
      }),
    );
    if (response.statusCode == 200) {
      showInSnackBar("Verification code sent!");
    } else {
      showInSnackBar("Verification code sent!");
    }


  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value, semanticsLabel: value),
    ));
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Pinput pin() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
      hapticFeedbackType: HapticFeedbackType.vibrate,
      length: 5,
      controller: codeController,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      onSubmitted: (value) => {
        _handleSubmitted()
      },
      onChanged: (value) => {
        setState(() => {
          _codeText = "Enter verification code"
        })
      },
      showCursor: true,
    );
  }


  resendCode() {
    final bloc = AuthBloc();
    bloc.codeRequest.add(widget.email);
    String message = "";
    WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
        context: context,
        builder: (BuildContext context) {
    return StreamBuilder<String?>(
        stream: bloc.requestStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data != null ) {
            if (snapshot.data!.contains("Failed")) {
              message = "Failed to request a new code, try again";
            } else {
              message = 'Code resent!';
                _code = snapshot.data!;
                _codeText = "Enter verification code";
              sendEmail(_code);
            }
            return const Center(child: CircularProgressIndicator());
          } else {
            message = "";
            return const Center(child: CircularProgressIndicator());
          }
        });
        },
    );
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
    if (message != "") showInSnackBar(message);

  }

  verified(String code) {
    final bloc = AuthBloc();
    bloc.verifyUser.add([widget.email,code]);
    String message = "";
    bool isVerified = false;

    WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<String?>(
        stream: bloc.verifyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data != null) {
            if (snapshot.data!.contains("Failed")) {
              message = "Failed to verify your email. Please try again";
            } else {
              message = snapshot.data!;
              isVerified = true;
            }
            return const Center(child: CircularProgressIndicator());
          } else {
            return const AlertDialog( content:
            Text('Failed to verify your email at this time',
                semanticsLabel: "Failed to verify your email at this time",
                style: TextStyle(fontSize: 30)));
          }
        });
        },
    );
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      if (message != "") showInSnackBar(message);
      Login({"email": widget.email, "password": widget.password}, context, widget.sp);
    });


  }

  void _handleSubmitted() {

    if (codeController.value.text != _code) {
      setState(() => {
        _codeText = "Entered code does not match sent verification code"
      });
    } else {
      verified(_code);

    }
  }

}


