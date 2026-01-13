import "package:amateur_arena/constants/header.dart";
import "package:flutter/material.dart";

abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  Widget pageContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[600],
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Container(
            color: Colors.green[200],
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                header(context),
                Expanded(child: pageContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
