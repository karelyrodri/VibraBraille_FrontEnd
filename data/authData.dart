import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthClient {
  final _hostUrl = "http://ec2-3-142-74-196.us-east-2.compute.amazonaws.com:8000";

  Future<RegisterAccount?> registerUser(String username, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse("$_hostUrl/register/"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email' : email,
        'phone_number' : phone,
        'password' : password
      }),
    );
    // Status code for no text detected
    if (response.statusCode == 201) {
      return RegisterAccount.fromJson(jsonDecode(response.body), 201);
    } else if (response.statusCode == 400) {
      return RegisterAccount.fromJson(jsonDecode(response.body), 400);
    } else {
      throw Exception('Failed to register user.');
    }

  }

  Future<String?> verifyEmail(String email, String code) async {
    final response = await http.put(
      Uri.parse("$_hostUrl/verify/email/"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        "email": email,
        "verify_str": code
      }),
    );
    if (response.statusCode == 200) {
      return "Your email has been verified!";
    } else if ((response.statusCode == 400)) {
      return "Failed to verify your email. Please try again";
    } else {
      throw Exception('Failed to verify email.');
    }
  }

  Future<String?> freshVerifyCode(String email) async {
    final response = await http.put(
      Uri.parse("$_hostUrl/verify/refresh/"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
      "email": email,
    }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["verification_email"];
    } else if ((response.statusCode == 400)) {
      return "Request Failed";
    } else {
      throw Exception('Failed to retrieve verification code.');
    }
  }

  Future<Account?> loginUser(Map<String, String> loginCreds) async {
    final response = await http.post(
      Uri.parse("$_hostUrl/login/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loginCreds),
    );
    // Status code for no text detected
    if (response.statusCode == 200 || response.statusCode == 401) { //////////////////// 401 not verified
      return Account.fromJson(jsonDecode(response.body), response.statusCode);
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      return Account.fromJson(jsonDecode(response.body), response.statusCode);
    } else {
      throw Exception('Failed to Login.');
    }
  }

  Future<List<String>?> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse("$_hostUrl/login/refresh/"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        "refresh" : refreshToken
      }),
    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return [json["refresh"], json["access"]];
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      return ["Failed to refresh token"];
    } else {
      throw Exception('Failed to Login.');
    }
  }

}

class RegisterAccount  {
  final String username;
  final String email;
  final String emailVerifyCode;
  final String phoneVerifyCode;
  final int statusCode;
  final String errorMessage;

  const RegisterAccount({required this.username, required this.email,
                  required this.emailVerifyCode, required this.phoneVerifyCode,
                  required this.statusCode, required this.errorMessage});

  factory RegisterAccount.fromJson(Map<String, dynamic> json, int status) {
    return status != 201 ? RegisterAccount(
        username: "",
        email: "",
        emailVerifyCode: "",
        phoneVerifyCode: "",
        statusCode: status,
        errorMessage:  json.entries.toString()

    ) :
    RegisterAccount(
        username: json["username"],
        email: json["email"],
        emailVerifyCode: json["verification_strings"]["verify_email"],
        phoneVerifyCode: json["verification_strings"]["verify_phone"],
        statusCode: status,
        errorMessage: ""
    );
  }
}

class Account  {
  final String username;
  final String phone;
  final String email;
  final String refreshToken;
  final String accessToken;
  final int statusCode;
  final String errorMessage;


  const Account({required this.username, required this.email,
    required this.phone, required this.refreshToken, required this.accessToken,
    required this.statusCode, required this.errorMessage});

  factory Account.fromJson(Map<String, dynamic> json, int status) {

    return status == 401
        ? Account(
      statusCode: status,
        username: "",
        email: "",
        phone: "",
        refreshToken: "",
        accessToken: "",
      errorMessage:  json.entries.toString()
    )
    : Account(
        username: json["user"]["username"],
        email: json["user"]["email"],
        phone: json["user"]["phone_number"],
        refreshToken: json["refresh"],
        accessToken: json["access"],
        statusCode: status,
        errorMessage: ""
    );
  }
}

