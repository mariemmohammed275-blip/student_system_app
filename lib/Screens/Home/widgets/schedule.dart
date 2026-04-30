import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

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
        // Switch card background to dark grey in dark mode
        color: isDark ? Colors.grey[800] : const Color(0xffEEF2F7),
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
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    // Remove hardcoded black
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      // Remove hardcoded black
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 10),

          // الخط الملون
          Container(
            width: 2,
            height: 62,
            decoration: BoxDecoration(
              color:
                  color, // The accent color (purple, blue, etc.) stays the same!
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
                  // If the text color matches the accent color, keep it, but brighten it slightly if needed
                  style: TextStyle(
                    color: isDark ? color.withOpacity(0.9) : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                if (!isMissing)
                  Text(
                    subtitle,
                    style: TextStyle(
                      // Remove hardcoded black
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
                          // Remove hardcoded black
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
  Widget dateHeader(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : const Color(0xffEEF2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            "October 18th, 2025",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              dayItem(context, "18", "Mon", selected: true, badge: "2"),
              dayItem(context, "19", "Tue", badge: "1"),
              dayItem(context, "20", "Wed"),
              dayItem(context, "21", "Thu", badge: "3"),
              dayItem(context, "22", "Sun"),
            ],
          ),
        ],
      ),
    );
  }

  // 📅 عنصر اليوم
  Widget dayItem(
    BuildContext context,
    String day,
    String week, {
    bool selected = false,
    String? badge,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
                  day,
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
                  week,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          //const SizedBox(height: 3),

          // 🔴 badge (fixed size so layout never shifts)
          SizedBox(
            height: 16,
            child: badge != null
                ? Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
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

          // 📅 header
          dateHeader(context),

          const SizedBox(height: 12),

          // 📚 المواد
          classCard(
            context: context,
            time: "10:10 AM",
            title: "EC 202 – Principles Microeconomics",
            subtitle: "Room 302",
            color: Colors
                .purpleAccent, // Switched to Accent for better dark mode visibility
          ),

          classCard(
            context: context,
            time: "11:10 AM",
            title: "FN 215 – Financial Management",
            subtitle: "Room 111",
            color: Colors.blueAccent,
          ),

          classCard(
            context: context,
            time: "11:59 PM",
            title: "EC 203 – Principles Macroeconomics",
            subtitle: "",
            color: const Color.fromARGB(255, 92, 230, 198),
            isMissing: true,
          ),

          classCard(
            context: context,
            time: "11:59 PM",
            title: "MGT 101 – Organization Management",
            subtitle: "",
            color: Colors.orangeAccent,
            isMissing: true,
          ),
        ],
      ),
    );
  }
}
