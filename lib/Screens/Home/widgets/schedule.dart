import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  // 🎯 لون الخلفية الأساسي للكارد
  final Color cardBg = const Color(0xffEEF2F7);

  // 📚 الكارد
  Widget classCard({
    required String time,
    required String title,
    required String subtitle,
    required Color color,
    bool isMissing = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ➤ السهم + الوقت
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 10),

          // الخط الملون
          Container(
            width: 3,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 10),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                if (!isMissing)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,

                      fontFamily: 'Robot',
                    ),
                  ),

                if (isMissing) ...[
                  Row(
                    children: const [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      SizedBox(width: 5),
                      Text(
                        "Missing assignment",
                        style: TextStyle(color: Colors.black, fontSize: 12),
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
  Widget dateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xffDCE3ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            "October 18th, 2025",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: 'Robot',
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              dayItem("18", "Mon", selected: true, badge: "2"),
              dayItem("19", "Tue", badge: "1"),
              dayItem("20", "Wed"),
              dayItem("21", "Thu", badge: "3"),
              dayItem("22", "sun"),
            ],
          ),
        ],
      ),
    );
  }

  // 📅 عنصر اليوم
  Widget dayItem(
    String day,
    String week, {
    bool selected = false,
    String? badge,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xff7FA9E6) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Robot',
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),

            // 🔴 badge
            if (badge != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(week, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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

          // 📅 header
          dateHeader(),

          const SizedBox(height: 12),

          // 📚 المواد
          classCard(
            time: "10:10 AM",
            title: "EC 202 – Principles Microeconomics",
            subtitle: "Room 302",
            color: Colors.purple,
          ),

          classCard(
            time: "11:10 AM",
            title: "FN 215 – Financial Management",
            subtitle: "Room 111",
            color: Colors.blue,
          ),

          classCard(
            time: "11:59 PM",
            title: "EC 203 – Principles Macroeconomics",
            subtitle: "",
            color: Colors.teal,
            isMissing: true,
          ),

          classCard(
            time: "11:59 PM",
            title: "MGT 101 – Organization Management",
            subtitle: "",
            color: Colors.orange,
            isMissing: true,
          ),
        ],
      ),
    );
  }
}
