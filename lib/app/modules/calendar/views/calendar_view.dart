import 'package:flutter/material.dart';
import 'package:meditation_friend/app/data/models/attendance.dart';
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
        diary: "오늘은 20분 명상했어요",
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
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
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
      appBar: AppBar(title: const Text('명상달력')),
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
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Attendance>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return const Center(
                    child: Text('이 날의 기록이 없습니다'),
                  );
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getMoodIcon(event.mood),
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        title: Text(event.mood ?? '기분 없음'),
                        subtitle: Text(event.diary ?? ''),
                        trailing: event.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  event.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
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
