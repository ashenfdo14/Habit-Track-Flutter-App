import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_habit_box.dart';
import 'package:habit_tracker/components/notification_service.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _newHabitNameController = TextEditingController();
  TimeOfDay? _selectedTime;
  List todayHabitList = [];

  @override
  void initState() {
    super.initState();
    NotificationService.initialize(); // Initialize the notification service
    loadTodayHabits();
  }

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return MyHabitBox(
          hintText: "Enter habit name...",
          controller: _newHabitNameController,
          onSave: saveNewHabit,
          onCancel: cancelHabitBox,
          onTimeSelected: (time) => _selectedTime = time,
        );
      },
    );
  }

  void saveNewHabit() async {
    print("saveNewHabit() called");
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String todayDate = DateTime.now().toIso8601String().split('T').first;

    if (uid != null && _selectedTime != null) {
      print("Saving habit to Firestore...");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .add({
        'name': _newHabitNameController.text,
        'completed': false,
        'date': todayDate,
        'time': {'hour': _selectedTime!.hour, 'minute': _selectedTime!.minute},
      });
      print("Habit saved!");

      // Generate a valid 32-bit integer ID
      int notificationId = Random().nextInt(1 << 31); // Range: [0, 2^31 - 1]

      // Schedule the notification
      NotificationService.scheduleDailyNotification(
        id: notificationId,
        title: 'Habit Reminder',
        body: 'Time to do: ${_newHabitNameController.text}',
        time: _selectedTime!,
      );

      _newHabitNameController.clear();
      _selectedTime = null;
      loadTodayHabits();
      Navigator.of(context).pop();
    } else {
      print("Failed to save habit: Missing UID or time");
    }
  }

  void loadTodayHabits() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String todayDate = DateTime.now().toIso8601String().split('T').first;

    if (uid != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .where('date', isEqualTo: todayDate)
          .get();

      List habits = snapshot.docs.map((doc) {
        return [
          doc['name'],
          doc['completed'],
          TimeOfDay(
            hour: doc['time']['hour'],
            minute: doc['time']['minute'],
          ),
        ];
      }).toList();

      setState(() {
        todayHabitList = habits;
      });
    }
  }

  void cancelHabitBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  void openHabitSettings(int index) {
    _newHabitNameController.text = todayHabitList[index][0];
    _selectedTime = todayHabitList[index][2];

    showDialog(
      context: context,
      builder: (context) {
        return MyHabitBox(
          hintText: "Edit habit name...",
          controller: _newHabitNameController,
          onSave: () => saveExistingHabit(index),
          onCancel: cancelHabitBox,
          onTimeSelected: (time) => _selectedTime = time,
        );
      },
    );
  }

  void saveExistingHabit(int index) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String oldHabitName = todayHabitList[index][0];

    if (uid != null && _selectedTime != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .where('name', isEqualTo: oldHabitName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'name': _newHabitNameController.text,
          'time': {
            'hour': _selectedTime!.hour,
            'minute': _selectedTime!.minute
          },
        });

        int notificationId = Random().nextInt(1 << 31); // Range: [0, 2^31 - 1]

        // Update notification if time has changed
        NotificationService.scheduleDailyNotification(
          id: notificationId,
          title: 'Habit Reminder',
          body: 'Time to do: ${_newHabitNameController.text}',
          time: _selectedTime!,
        );

        setState(() {
          todayHabitList[index] = [
            _newHabitNameController.text,
            todayHabitList[index][1], // Keep the completion status
            _selectedTime!,
          ];
        });

        _newHabitNameController.clear();
        _selectedTime = null;
        Navigator.of(context).pop();
      }
    }
  }

  void deleteHabit(int index) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String habitName = todayHabitList[index][0];

    if (uid != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .where('name', isEqualTo: habitName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }

      setState(() {
        todayHabitList.removeAt(index);
      });
    }
  }

  void checkBoxTapped(bool? value, int index) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String habitName = todayHabitList[index][0];

    if (uid != null) {
      // Find the habit document by name and update its completion status
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .where('name', isEqualTo: habitName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'completed': value});
      }

      setState(() {
        todayHabitList[index][1] = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text("Habit Track"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todayHabitList.length,
        itemBuilder: (context, index) {
          return HabitTile(
            habitName: todayHabitList[index][0],
            habitComplete: todayHabitList[index][1],
            reminderTime: todayHabitList[index][2],
            onChanged: (value) => checkBoxTapped(value, index),
            settingsTapped: (context) => openHabitSettings(index),
            deleteTapped: (context) => deleteHabit(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.surface,
        onPressed: createNewHabit,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
          size: 30,
        ),
      ),
    );
  }
}
