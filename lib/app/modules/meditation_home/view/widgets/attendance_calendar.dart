// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class AttendanceCalendar extends StatefulWidget {
//   const AttendanceCalendar({Key? key}) : super(key: key);

//   @override
//   _AttendanceCalendarState createState() => _AttendanceCalendarState();
// }

// class _AttendanceCalendarState extends State<AttendanceCalendar> {
//   late final ValueNotifier<List<Event>> _selectedEvents;
//   late final CalendarFormat _calendarFormat;
//   late DateTime _focusedDay;
//   late DateTime _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _focusedDay = DateTime.now();
//     _selectedDay = _focusedDay;
//     _calendarFormat = CalendarFormat.month;
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
//   }

//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     super.dispose();
//   }

//   List<Event> _getEventsForDay(DateTime day) {
//     // 여기에 이벤트를 추가하는 로직을 넣으면 됩니다.
//     return [Event('Sample Event 1')];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         TableCalendar(
//           firstDay: DateTime.utc(2020, 1, 1),
//           lastDay: DateTime.utc(2025, 12, 31),
//           focusedDay: _focusedDay,
//           selectedDayPredicate: (day) {
//             return isSameDay(_selectedDay, day);
//           },
//           onDaySelected: (selectedDay, focusedDay) {
//             setState(() {
//               _selectedDay = selectedDay;
//               _focusedDay = focusedDay;
//               _selectedEvents.value = _getEventsForDay(selectedDay);
//             });
//           },
//           onPageChanged: (focusedDay) {
//             _focusedDay = focusedDay;
//           },
//           calendarFormat: _calendarFormat,
//         ),
//         const SizedBox(height: 8.0),
//         // 이벤트 목록을 표시하는 부분
//         ValueListenableBuilder<List<Event>>(
//           valueListenable: _selectedEvents,
//           builder: (context, events, _) {
//             return ListView.builder(
//               shrinkWrap: true, // Prevents ListView from taking infinite space
//               itemCount: events.length,
//               itemBuilder: (context, index) {
//                 return ListTile(title: Text(events[index].title));
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class Event {
//   final String title;
//   Event(this.title);
// }
