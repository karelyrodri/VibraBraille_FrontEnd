import 'dart:async';

import 'package:rxdart/rxdart.dart';
import '../data/authData.dart';
import 'package:vibra_braille/ui/auth/register.dart';

class AuthBloc{
  final _client = AuthClient();
  final _registerController = StreamController<PersonData>();
  Sink<PersonData> get user => _registerController.sink;
  late Stream<RegisterAccount?> registerStream;
  
  final _verifyController = StreamController<List<String>>();
  Sink<List<String>> get verifyUser => _verifyController.sink;
  late Stream<String?> verifyStream;
  
  final _requestCodeController = StreamController<String>();
  Sink<String> get codeRequest =>_requestCodeController.sink;
  late Stream<String?> requestStream;

  final _loginCodeController = StreamController<Map<String, String>>();
  Sink<Map<String, String>> get loginUser =>_loginCodeController.sink;
  late Stream<Account?> loginStream;

  final _refreshTokensController = StreamController<String>();
  Sink<String> get token =>_refreshTokensController.sink;
  late Stream<List<String>?> tokenStream;

  AuthBloc() {

    registerStream = _registerController.stream.switchMap(
            (user) => _client.registerUser(
            user.username!, user.email!,
                user.phoneNumber!, user.password).asStream());
    
    verifyStream = _verifyController.stream.switchMap(
            (verifyUser) => _client.verifyEmail(verifyUser[0], verifyUser[1]).asStream());

    requestStream = _requestCodeController.stream.switchMap(
            (codeRequest) => _client.freshVerifyCode(codeRequest).asStream());
    
    loginStream = _loginCodeController.stream.switchMap(
            (loginUser) => _client.loginUser(loginUser).asStream());

    tokenStream = _refreshTokensController.stream.switchMap(
            (token) => _client.refreshToken(token).asStream());
  }

  void dispose() {
    _registerController.close();
    _verifyController.close();
    _requestCodeController.close();
    _loginCodeController.close();
    _refreshTokensController.close();
  }
}