import 'package:amateur_arena/screens/authentication/authentication_base.dart';
import 'package:amateur_arena/services/auth.dart';
import "package:flutter/material.dart";

class LoginScreen extends LoginRegisterBase {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends LoginRegisterBaseState<LoginScreen> {
  String email = "";
  String password = "";

  @override
  List<FormField> getFormFields() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: "Email"),
        validator: (value) => value!.isEmpty ? "Email cannot be empty" : null,
        onSaved: (value) => email = value!,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Password"),
        obscureText: true,
        validator: (value) =>
            value!.length < 6 ? "Password must be at least 6 characters" : null,
        onSaved: (value) => password = value!,
      ),
    ];
  }

  @override
  Future<void> submitAction() async {
    await AuthService().signInWithEmailAndPassword(email, password);
  }
}
