// schedule_dropdown.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NightScheduleDropdown extends StatefulWidget {
  const NightScheduleDropdown({Key? key}) : super(key: key);

  @override
  _NightScheduleDropdownState createState() => _NightScheduleDropdownState();
}

class _NightScheduleDropdownState extends State<NightScheduleDropdown> {
  final Map<String, String> schedule = {
    "Monday": "Monday 10:00 PM - 06:00 AM",
    "Tuesday": "Tuesday 10:00 PM - 06:00 AM",
    "Wednesday": "Wednesday 10:00 PM - 06:00 AM",
    "Thursday": "Thursday 10:00 PM - 06:00 AM",
    "Friday": "Friday 10:00 PM - 06:00 AM",
    "Saturday": "Saturday 10:00 PM - 06:00 AM",
    "Sunday": "Sunday Closed",
  };

  late String selectedSchedule;

  @override
  void initState() {
    super.initState();
    selectedSchedule = _getTodaySchedule();
  }

  String _getTodaySchedule() {
    String today = DateFormat('EEEE').format(DateTime.now());
    return schedule[today] ?? 'No Schedule Available';
  }

  @override
  Widget build(BuildContext context) {
    final scheduleList = schedule.values.toSet().toList(); // Ensure uniqueness

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: scheduleList.contains(selectedSchedule)
              ? selectedSchedule
              : null, // Ensure value matches an item in the list
          items: scheduleList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedSchedule = newValue!;
            });
          },
        ),

      ],
    );
  }
}
