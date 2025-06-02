import 'package:flutter/material.dart';

class MyHabitBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const MyHabitBox({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSave,
    required this.onCancel,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(hintText),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter habit name"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                onTimeSelected(pickedTime);
              }
            },
            child: Text(
              "Pick Time",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: onCancel,
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            )),
        TextButton(
            onPressed: onSave,
            child: Text(
              "Save",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            )),
      ],
    );
  }
}
