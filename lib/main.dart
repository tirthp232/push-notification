import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'notification_service.dart';
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print(message);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      .then((value) => Get.put(NotificationService()));
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationService.notification.requestPermission();
  NotificationService.notification.getToken();
  NotificationService.notification.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var path = ' ';
  var count = 1;
  final item = ItemScrollController();
  ScrollController controller = ScrollController();

  Future scrolltoRight() async {
    // item.scrollTo(index: count, duration: Duration(seconds: 1));
    // count++;

    double start = 0;

    controller.jumpTo(start);
  }

  Future scrolltoleft() async {
    // count--;
    // item.scrollTo(index: count, duration: Duration(seconds: 1));
    double end = controller.position.maxScrollExtent;
    controller.jumpTo(end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text("From background"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => scrolltoRight(), child: Text(".")),
    );
  }
}
