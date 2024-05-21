// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/services.dart';
// import 'NotificationService.dart';
// import 'firebase_options.dart';
// import 'HomePage.dart';
// import 'WorkoutPage.dart';
// import 'Account.dart';
// import 'logIn.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'Session.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'NotificationService.dart';
//
// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({super.key});
//
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//   TextEditingController notificationTitle = TextEditingController();
//   TextEditingController notificationDescription = TextEditingController();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     tz.initializeTimeZones();
//     NotificationService.initialize();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notification Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: TextField(
//                 controller: notificationTitle,
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Enter Title'
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: TextField(
//                 controller: notificationDescription,
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Enter Description'
//                 ),
//               ),
//             ),
//
//             ElevatedButton(
//                 onPressed: () {
//                   NotificationService.display(
//                       1,
//                       notificationTitle.text,
//                       notificationDescription.text);
//                 },
//                 child: Text('click me')),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
