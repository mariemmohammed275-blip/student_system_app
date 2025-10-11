import 'package:flutter/material.dart';

class RecentNews extends StatelessWidget {
  const RecentNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image section
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/event.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // text section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'The Faculty of Engineering at Helwan University organizes a training course.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class RecentNews extends StatelessWidget {
//   const RecentNews({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             clipBehavior: Clip.antiAlias,
//             elevation: 2,
//             child: SizedBox(
//               height: 180,
//               width: double.infinity,
//               child: Image.asset('assets/images/event.jpg', fit: BoxFit.cover),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'The Faculty of Engineering at Helwan University organizes a training course.',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
