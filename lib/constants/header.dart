import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';

Column header(BuildContext context) {
  return Column(
    children: [
      Row(
        children: [
          Text("Amateur Arena", style: TextStyle(fontSize: 30)),
          Spacer(),
          CircleAvatar(),
        ],
      ),
      Divider(color: Colors.black),
      Row(
        spacing: 10,
        children: [
          ElevatedButton(onPressed: () => context.go("/"), child: Text("Home")),
          ElevatedButton(
            onPressed: () => context.go("/events"),
            child: Text("Events"),
          ),
          ElevatedButton(
            onPressed: () => context.go("/marketplace"),
            child: Text("Marketplace"),
          ),
        ],
      ),
      Divider(color: Colors.black),
    ],
  );
}
