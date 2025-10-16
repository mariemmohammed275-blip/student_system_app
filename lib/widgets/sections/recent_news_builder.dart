import 'package:flutter/material.dart';
import 'package:student_systemv1/widgets/recent_news_widget.dart';

class RecentNewsBuilder extends StatelessWidget {
  const RecentNewsBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 280,
          width: 320,
          child: GestureDetector(onTap: () {}, child: RecentNews()),
        );
      },
    );
  }
}
