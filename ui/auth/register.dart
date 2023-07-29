
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/bloc/auth_bloc.dart';
import 'package:vibra_braille/data/authData.dart';
import 'package:vibra_braille/ui/auth/privacy.dart';
import 'package:vibra_braille/ui/auth/verify.dart';
import 'login.dart';

class RegisterPage extends StatelessWidget {
  final SharedPreferences sp;
  const RegisterPage({super.key, required this.sp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: const Color.fromRGBO(39, 71, 110, 1),
        automaticallyImplyLeading: false,
        title: const Text("Register", semanticsLabel: "Register",
        style: TextStyle(fontSize: 28),),
      ),
      body: Register(sp: sp),
      bottomSheet: PrivacyPolicy(context).getPolicyText(),
    );
  }
}

class Register extends StatefulWidget {
  final SharedPreferences sp;
  const Register({super.key, required this.sp});

  @override
  RegisterState createState() => RegisterState();
}

class PersonData {
  String? username = '';
  String? phoneNumber = '';
  String? email = '';
  String password = '';
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    Key? key,
    this.restorationId,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  }) : super(key: key);

  final String? restorationId;
  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> with RestorationMixin {
  final RestorableBool _obscureText = RestorableBool(true);


  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_obscureText, 'obscure_text');
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      restorationId: 'password_text_field',
      obscureText: _obscureText.value,
      maxLength: 8,
      onSaved:  widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText.value = !_obscureText.value;
            });
          },
          hoverColor: Colors.transparent,
          icon: Icon(
            _obscureText.value ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText.value
                ? "Password is showing"
                : "Password is hidden",
          ),
        ),
      ),
    );
  }
}

class RegisterState extends State<Register> with RestorationMixin {
  late PersonData person;
  late FocusNode _phoneNumber, _email, _password, _retypePassword;
  late RegisterAccount accountData;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    isRegistered = false;
    person = PersonData();
    _phoneNumber = FocusNode();
    _email = FocusNode();
    _password = FocusNode();
    _retypePassword = FocusNode();
  }

  @override
  void dispose() {
    _phoneNumber.dispose();
    _email.dispose();
    _password.dispose();
    _retypePassword.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value, semanticsLabel: value),
    ));
  }

  @override
  String get restorationId => 'text_field_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateModeIndex, 'autovalidate_mode');
  }

  final RestorableInt _autoValidateModeIndex =
  RestorableInt(AutovalidateMode.disabled.index);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(debugLabel: '_register');
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
  GlobalKey<FormFieldState<String>>();
  final UsNumberTextInputFormatter _phoneNumberFormatter =
  UsNumberTextInputFormatter();

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateModeIndex.value =
          AutovalidateMode.always.index; // Start validating on every change.
      showInSnackBar("Please correct Errors",);
    } else {
      form.save();

      WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
        context: context,
        builder: (BuildContext context) {
          return register();
        },
      );
      });
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        if (isRegistered) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => VerifyPage(email : accountData.email,
                  password: person.password, sp: widget.sp)),
                  (route) => false);

        }
      });

    }
  }

  Widget register() {
    final bloc = AuthBloc();
    bloc.user.add(person);
    return StreamBuilder<RegisterAccount?>(
        stream: bloc.registerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data != null && snapshot.data!.statusCode == 201) {
            accountData = snapshot.data!;
            isRegistered = true;
            return AlertDialog(
                content: Text("Welcome ${person.username!}", semanticsLabel: "Registered Successfully, Welcome!",
                    style: const TextStyle(fontSize: 30)));
          } else {
            return  const AlertDialog( content:
            Text('Failed to Register', semanticsLabel: "Failed to Register",
                style: TextStyle(fontSize: 30)));
          }

        });

  }


  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter your username";
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return "Alphabetical characters only";
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return "Enter a valid phone number ";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final passwordField = _passwordFieldKey.currentState!;
    if (passwordField.value == null || passwordField.value!.isEmpty) {
      return "Enter in a password ";
    }
    if (passwordField.value != value) {
      return "Passwords do not match ";
    }
    person.password = value!;
    return null;
  }
  String? _validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;

  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.values[_autoValidateModeIndex.value],
      child: Scrollbar(
        child: SingleChildScrollView(
          restorationId: 'text_field_demo_scroll_view',
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              sizedBoxSpace,
              TextFormField(
                restorationId: 'name_field',
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  filled: true,
                  icon: Icon(Icons.person),
                  hintText: "Enter your username",
                  labelText: "Username*",
                ),
                onSaved: (value) {
                  person.username = value;
                  _phoneNumber.requestFocus();
                },
                validator: _validateName,
              ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'phone_number_field',
                textInputAction: TextInputAction.next,
                focusNode: _phoneNumber,
                decoration: const InputDecoration(
                  filled: true,
                  icon: Icon(Icons.phone),
                  hintText: "Enter your phone Number",
                  labelText: "Phone Number*",
                  prefixText: '+1 ',

                ),
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  person.phoneNumber = formatPhone(value);
                  _email.requestFocus();
                },
                maxLength: 14,
                validator: _validatePhoneNumber,
                // TextInputFormatters are applied in sequence.
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  // Fit the validating format.
                  _phoneNumberFormatter,
                ],
              ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'email_field',
                textInputAction: TextInputAction.next,
                focusNode: _email,
                decoration: const InputDecoration(
                  filled: true,
                  icon: Icon(Icons.email),
                  hintText: "Enter your email address",
                  labelText: "Email*",
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  person.email = value;
                },
              ),

              sizedBoxSpace,
              PasswordField(
                restorationId: 'password_field',
                textInputAction: TextInputAction.next,
                focusNode: _password,
                fieldKey: _passwordFieldKey,
                helperText: "Max 8 characters",
                labelText: "Password*",
                onFieldSubmitted: (value) {
                  setState(() {
                    _retypePassword.requestFocus();
                  });
                },
              ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'retype_password_field',
                focusNode: _retypePassword,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "Re-type password*",
                ),
                maxLength: 8,
                obscureText: true,
                validator: _validatePassword,
                onFieldSubmitted: (value) {
                  _handleSubmitted();
                },
              ),
              sizedBoxSpace,
              Center(  child:
                SizedBox( width: 175, height: 45,
                child: ElevatedButton(
                  style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(const Color.fromRGBO(39, 71, 110, 1)) ),
                  onPressed: _handleSubmitted,
                  child: const Text("Sign Up", semanticsLabel: "Submit registration",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                )),
              ),
              sizedBoxSpace,
              Text(
                "* indicate required field",
                style: Theme.of(context).textTheme.caption,
              ),
              sizedBoxSpace,
            ],
          ),
        ),
      ),
    );
  }
}

String? formatPhone(String? num) {
    final remove = ['(', ')', ' ','-' ];
    for (int i = 0; i < remove.length; i++) {
      num = num?.replaceAll(remove[i], "");
    }
  return num;
}

/// Format incoming numeric text to fit the format of (###) ###-#### ##
class _UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newTextLength = newValue.text.length;
    final newText = StringBuffer();
    var selectionIndex = newValue.selection.end;
    var usedSubstringIndex = 0;
    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}) ');
      if (newValue.selection.end >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write('${newValue.text.substring(6, usedSubstringIndex = 10)} ');
      if (newValue.selection.end >= 10) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
