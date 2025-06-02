import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitComplete;
  final TimeOfDay reminderTime; // Added time input
  final Function(bool?)? onChanged;
  final Function(BuildContext)? settingsTapped;
  final Function(BuildContext)? deleteTapped;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitComplete,
    required this.reminderTime,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
  });

  /// Format TimeOfDay to display as HH:MM (e.g., 07:30 AM)
  String formatTime(TimeOfDay time) {
    final hours = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hours:$minutes $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: settingsTapped,
              backgroundColor: Colors.grey,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: deleteTapped,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                focusColor: Theme.of(context).colorScheme.surface,
                checkColor: Theme.of(context).colorScheme.secondary,
                value: habitComplete,
                onChanged: onChanged,
              ),

              // Habit Name and Time Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habit Name
                    Text(
                      habitName,
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 4), // Spacing

                    // Reminder Time
                    Text(
                      'Reminder: ${formatTime(reminderTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
