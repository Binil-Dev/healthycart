import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:healthycart/app.dart';
import 'package:healthycart/core/di/injection.dart';
import 'package:healthycart/core/services/foreground_notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Channel_id', 'channel_name',
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependancy();
  await ForegroundNotificationService.messageInit(
      channel: channel,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
  runApp( App(
    androidNotificationChannel: channel,
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  ),
  );
}
 