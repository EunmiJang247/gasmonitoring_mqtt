import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/data/models/attendance.dart';
import 'package:meditation_friend/app/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final ValueNotifier<List<Attendance>> _selectedEvents;
  late final CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  // 샘플 데이터 - 실제로는 서버나 로컬 DB에서 가져와야 함
  final Map<DateTime, List<Attendance>> _events = {
    DateTime.utc(2025, 5, 20): [
      Attendance(
        attendanceDate: DateTime.utc(2025, 5, 20),
        mood: "행복",
        diary: "오늘은 20분 명상했어요1",
        imageUrl: "https://example.com/image.jpg",
      ),
      Attendance(
        attendanceDate: DateTime.utc(2025, 5, 20),
        mood: "행복",
        diary: "오늘은 20분 명상했어요2",
        imageUrl: "https://example.com/image.jpg",
      ),
      Attendance(
        attendanceDate: DateTime.utc(2025, 5, 20),
        mood: "행복",
        diary: "오늘은 20분 명상했어요3",
        imageUrl: "https://example.com/image.jpg",
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat.month;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  List<Attendance> _getEventsForDay(DateTime day) {
    // UTC 날짜로 변환하여 비교
    final eventDate = DateTime.utc(day.year, day.month, day.day);

    // 모든 이벤트를 순회하며 같은 날짜의 이벤트를 찾음
    List<Attendance> eventsForDay = [];
    _events.forEach((date, events) {
      if (date.year == eventDate.year &&
          date.month == eventDate.month &&
          date.day == eventDate.day) {
        eventsForDay.addAll(events);
      }
    });

    return eventsForDay;
  }

  // 기분별 아이콘 매핑
  IconData _getMoodIcon(String? mood) {
    switch (mood?.toLowerCase()) {
      case '행복':
        return Icons.sentiment_very_satisfied;
      case '평온':
        return Icons.sentiment_satisfied;
      case '슬픔':
        return Icons.sentiment_dissatisfied;
      case '화남':
        return Icons.mood_bad;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDark,
      appBar: CustomAppBar(
        leftSide: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        rightSide: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar<Attendance>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
            },
            calendarFormat: _calendarFormat,
            // 마커 스타일 설정
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Icon(
                      _getMoodIcon(events.first.mood),
                      color: AppColors.kBrighYellow,
                      size: 16,
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: AppColors.kBrighYellow),
              weekendTextStyle: TextStyle(color: AppColors.kBrighYellow),
              outsideTextStyle:
                  TextStyle(color: AppColors.kBrighYellow.withOpacity(0.5)),
              holidayTextStyle: TextStyle(color: AppColors.kBrighYellow),
              selectedTextStyle: TextStyle(color: Colors.black),
              selectedDecoration: BoxDecoration(
                color: AppColors.kBrighYellow,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                color: AppColors.kBrighYellow.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: AppColors.kBrighYellow),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: AppColors.kBrighYellow),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: AppColors.kBrighYellow),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.kBrighYellow),
              weekendStyle: TextStyle(color: AppColors.kBrighYellow),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Attendance>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return const Center(
                    child: Text(
                      '이 날의 기록이 없습니다',
                      style: TextStyle(color: AppColors.kBrighYellow),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.kBrighYellow,
                          width: 1.0,
                        ),
                      ),
                      color: AppColors.kDark,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getMoodIcon(event.mood),
                          color: AppColors.kBrighYellow,
                          size: 24,
                        ),
                        title: Text(
                          event.mood ?? '기분 없음',
                          style: TextStyle(color: AppColors.kBrighYellow),
                        ),
                        subtitle: Text(event.diary ?? '',
                            style: TextStyle(color: AppColors.kBrighYellow)),
                        trailing: event.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  event.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error,
                                          color: AppColors.kBrighYellow),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
