import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:push_noti/home.dart';

void msg(details) {
  if (details.payload != null) {
    Get.to(() => Home());
  }
}

class NotificationService extends GetxController {
  static NotificationService notification = Get.find();
  String? token;
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  void requestPermission() async {
    FirebaseMessaging msg = FirebaseMessaging.instance;

    NotificationSettings settings = await msg.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("user granted provisional permission");
    } else {
      print("user declined");
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      print(value);
      saveToken(token);
    });
  }

  void saveToken(token) {
    FirebaseFirestore.instance.collection("Token").doc("user").set(
      {'token': token},
    );
  }

  void init() {
    InitializationSettings initializationSettings =
        const InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    notifications.initialize(
      initializationSettings,
      // onDidReceiveBackgroundNotificationResponse: (details) {
      //   // msg(details);
      //   if (details.payload == "Hello") {
      //     Get.to(() => Home());
      //   }
      // },

      //when app in foreground state it will receive notification from fcm
      onDidReceiveNotificationResponse: (details) {
        print("recevie msg =========> ${details.payload}");
        try {
          Get.to(() => Home());
        } catch (e) {
          print(e.toString());
        }
      },
      // onDidReceiveBackgroundNotificationResponse: (details) {
      //   Get.to(Home());
      // },
    );

    //when app is terminated state and you get the notification
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        Get.to(() => Home());
      }
    });

    //when app in foreground state
    FirebaseMessaging.onMessage.listen((message) async {
      print("${message.notification?.title}");
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'dbfood',
        'dbfood',
        importance: Importance.high,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      await notifications.show(
        0,
        message.notification!.title,
        message.notification!.body,
        platformChannelSpecifics,
        payload: "Hello",
      );
    });

    // when app in background not terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("${message.notification?.title}");
      if (message.notification!.title != null) {
        Get.to(() => Home());
      }
    });
  }
}
