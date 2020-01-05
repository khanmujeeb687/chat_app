import 'dart:async';

import 'package:chat_app/src/data/models/custom_error.dart';
import 'package:chat_app/src/data/models/user_with_token.dart';
import 'package:chat_app/src/data/repositories/register_repository.dart';
import 'package:chat_app/src/screens/home/home_view.dart';
import 'package:chat_app/src/utils/custom_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterController {

  final BuildContext context;

  RegisterRepository _registerRepository = RegisterRepository();

  StreamController<String> streamController = StreamController();

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isFormValid = false;
  get isFormValid => _isFormValid;

  bool _formSubmitting = false;
  get formSubmitting => _formSubmitting;

  RegisterController({
    @required this.context,
  }) {
    this.init();
  }

  void init() {
    this.nameController.addListener(this.validateForm);
    this.usernameController.addListener(this.validateForm);
    this.passwordController.addListener(this.validateForm);
  }

  void validateForm() {
    bool isFormValid = _isFormValid;
    String name = this.nameController.value.text;
    String username = this.usernameController.value.text;
    String password = this.passwordController.value.text;
    if (name.trim() == "" || username.trim() == "" || password.trim() == "") {
      isFormValid = false;
    } else {
      isFormValid = true;
    }
    _isFormValid = isFormValid;
    notifyListeners();
  }

  void submitForm() async {
    _formSubmitting = true;
    notifyListeners();
    String name = this.nameController.value.text;
    String username = this.usernameController.value.text;
    String password = this.passwordController.value.text;
    var loginResponse = await _registerRepository.register(name, username, password);
    if (loginResponse is CustomError) {
      showAlertDialog(loginResponse.errorMessage);
    } else if (loginResponse is UserWithToken) {
      await CustomSharedPreferences.setString('token', loginResponse.token);
      await CustomSharedPreferences.setString('user', loginResponse.user.toString());
      Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (_) => false);
    }
    _formSubmitting = false;
    notifyListeners();
  }

  void notifyListeners() {
    streamController.add("change");
  }

  showAlertDialog(String message) {
    // configura o button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Verifique os erros"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    // exibe o dialog
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    streamController.close();
  }

}