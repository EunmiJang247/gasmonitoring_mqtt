// import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:go_router/go_router.dart';
// import 'package:meditation_friend_app/common/utils/kcolors.dart';

// class AttendanceCheck extends StatelessWidget {
//   const AttendanceCheck({super.key});

//   // 날짜에 해당하는 요일을 가져오는 함수
//   String getDayOfWeek(DateTime date) {
//     List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
//     return days[date.weekday - 1]; // DateTime의 weekday는 1 (월요일)부터 7 (일요일)
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> attendanceListStrings = ["2025-03-23", "2025-03-24"];
//     List<DateTime> attendanceList =
//         attendanceListStrings
//             .map((dateString) => DateTime.parse(dateString))
//             .toList();
//     DateTime now = DateTime.now();
//     List<DateTime> dates = [
//       now.subtract(Duration(days: 3)),
//       now.subtract(Duration(days: 2)),
//       now.subtract(Duration(days: 1)),
//       now, // 오늘
//       now.add(Duration(days: 1)),
//       now.add(Duration(days: 2)),
//       now.add(Duration(days: 3)),
//     ];

//     return GestureDetector(
//       onTap: () {
//         context.push('/attendance');
//       },
//       child: Card(
//         color: Kolors.kWhite,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ...dates.map((date) {
//                 bool isPresent = attendanceList.any(
//                   (attendanceDate) =>
//                       attendanceDate.year == date.year &&
//                       attendanceDate.month == date.month &&
//                       attendanceDate.day == date.day,
//                 );
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Column(
//                     children: [
//                       Icon(
//                         isPresent
//                             ? MaterialIcons.sentiment_very_satisfied
//                             : (date == now
//                                 ? MaterialIcons.sentiment_satisfied
//                                 : MaterialIcons.sentiment_neutral),
//                         color:
//                             isPresent
//                                 ? const Color.fromARGB(255, 78, 91, 235)
//                                 : (date == now ? Kolors.kOrange : null),
//                       ),
//                       Text(getDayOfWeek(date)),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
