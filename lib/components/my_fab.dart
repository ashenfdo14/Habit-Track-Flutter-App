import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  final Function()? onPressed;

  const MyFloatingActionButton(
    void Function(), {
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.surface,
      onPressed: onPressed,
      child: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.inversePrimary,
        size: 30,
      ),
    );
  }
}
