import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

abstract class LoginRegisterBase extends StatefulWidget {
  const LoginRegisterBase({super.key});
}

abstract class LoginRegisterBaseState<T extends LoginRegisterBase>
    extends State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<FormField> getFormFields();

  Future<void> submitAction();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  ...getFormFields(),
                  ElevatedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      _formKey.currentState!.save();

                      if (!_formKey.currentState!.validate()) return;

                      await submitAction();

                      if (!context.mounted) return;

                      context.go("/");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
