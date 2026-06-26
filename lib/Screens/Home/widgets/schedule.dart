import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_systemv1/models/timetable_item.dart';
import 'package:student_systemv1/API/api_service.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late DateTime selectedDate;
  late List<DateTime> weekDates;
  late Future<List<TimetableItem>> scheduleFuture;

  final List<Color> cardColors = [
    Colors.purpleAccent,
    Colors.blueAccent,
    const Color.fromARGB(255, 92, 230, 198),
    Colors.orangeAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    weekDates = List.generate(
      5,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    scheduleFuture = ApiService.getTimetable();
  }

  // 📚 الكارد
  Widget classCard({
    required BuildContext context,
    required String time,
    required String title,
    required String subtitle,
    required Color color,
    bool isMissing = false,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xffEEF2F7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 2,
            height: 62,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? color.withOpacity(0.9) : color,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (!isMissing)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black,
                      fontSize: 12,
                      fontFamily: 'Robot',
                    ),
                  ),
                if (isMissing) ...[
                  Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        "Missing assignment",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📅 التاريخ (header)
  // 👇 Now takes the schedule list to check for classes
  Widget dateHeader(BuildContext context, List<TimetableItem> schedule) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : const Color(0xffEEF2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM d, yyyy').format(selectedDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDates.map((date) {
              // Check if the current day has any matching classes in the schedule
              String dayName = DateFormat('EEEE').format(date);
              bool hasClasses = schedule.any(
                (item) => item.day.toLowerCase() == dayName.toLowerCase(),
              );

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
                child: dayItem(
                  context,
                  date,
                  selected: date.day == selectedDate.day,
                  hasClasses: hasClasses, // Pass it down to the UI
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 📅 عنصر اليوم
  Widget dayItem(
    BuildContext context,
    DateTime date, {
    bool selected = false,
    bool hasClasses = false,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String dayNum = DateFormat('d').format(date);
    String weekAbbr = DateFormat('E').format(date);

    return SizedBox(
      width: 55,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xff7FA9E6) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  dayNum,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weekAbbr,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // 🔴 Red dot indicator for classes
          SizedBox(
            height: 6,
            child: hasClasses
                ? Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  )
                : const SizedBox(), // Empty if no classes
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Schedule",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Robot',
            ),
          ),
          const SizedBox(height: 12),

          // 👇 FutureBuilder now wraps BOTH the Header and the List
          FutureBuilder<List<TimetableItem>>(
            future: scheduleFuture,
            builder: (context, snapshot) {
              // While loading, show the calendar with NO dots, and a spinner below
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    dateHeader(context, []),
                    const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Column(
                  children: [
                    dateHeader(context, []),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Error loading schedule"),
                      ),
                    ),
                  ],
                );
              }

              List<TimetableItem> fullSchedule = snapshot.data ?? [];
              String selectedDayName = DateFormat('EEEE').format(selectedDate);

              // Filter classes matching the selected day of the week
              List<TimetableItem> dailyClasses = fullSchedule
                  .where(
                    (item) =>
                        item.day.toLowerCase() == selectedDayName.toLowerCase(),
                  )
                  .toList();

              return Column(
                children: [
                  // 1. Render Date Header WITH dots based on full schedule
                  dateHeader(context, fullSchedule),
                  const SizedBox(height: 12),

                  // 2. Render Classes List based on selected date
                  if (dailyClasses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text(
                          "No classes for $selectedDayName! 🎉",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...dailyClasses.asMap().entries.map((entry) {
                      int index = entry.key;
                      TimetableItem classInfo = entry.value;

                      return classCard(
                        context: context,
                        time: "${classInfo.startTime} - ${classInfo.endTime}",
                        title:
                            "${classInfo.courseCode} - ${classInfo.courseName}",
                        subtitle: classInfo.room,
                        color: cardColors[index % cardColors.length],
                      );
                    }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
