// schedule_dropdown.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleDropdown extends StatefulWidget {
  const ScheduleDropdown({Key? key}) : super(key: key);

  @override
  _ScheduleDropdownState createState() => _ScheduleDropdownState();
}

class _ScheduleDropdownState extends State<ScheduleDropdown> {
  final Map<String, String> schedule = {
    "Monday": "Monday 09:00 AM - 07:00 PM",
    "Tuesday": "Tuesday 09:00 AM - 07:00 PM",
    "Wednesday": "Wednesday 09:00 AM - 07:00 PM",
    "Thursday": "Thursday 09:00 AM - 07:00 PM",
    "Friday": "Friday 09:00 AM - 07:00 PM",
    "Saturday": "Saturday 09:00 AM - 02:00 PM",
    "Sunday": "Sunday 09:00 AM - 02:00 PM",
  };

  late String selectedSchedule;

  @override
  void initState() {
    super.initState();
    selectedSchedule = _getTodaySchedule();
  }

  String _getTodaySchedule() {
    String today = DateFormat('EEEE').format(DateTime.now());
    print("Today is: $today");
    return schedule[today] ?? 'No Schedule Available';
  }

  @override
  Widget build(BuildContext context) {
    final scheduleList = schedule.values.toSet().toList(); // Ensure uniqueness
    print("Dropdown Items: $scheduleList");
    print("Selected Schedule: $selectedSchedule");

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
              child: Text(value,overflow: TextOverflow.ellipsis,),
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
