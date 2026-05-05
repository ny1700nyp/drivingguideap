import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _idlePauseNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool _idleNotificationsInitialized = false;

const int kIdlePauseNotificationId = 918273;
const String _kAndroidChannelId = 'guiding_idle_pause';
const String _kAndroidChannelName = 'Guiding status';
const String _kAndroidChannelDescription =
    'When guiding pauses automatically after inactivity';

/// Sets up channels and requests OS permission where needed. Safe to call
/// multiple times. Never throws — malformed icon resources must not crash the app.
Future<void> ensureIdlePauseNotificationsReady() async {
  if (kIsWeb || _idleNotificationsInitialized) {
    return;
  }

  try {
    const androidInit = AndroidInitializationSettings('ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _idlePauseNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      ),
    );

    if (Platform.isAndroid) {
      final android = _idlePauseNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            _kAndroidChannelId,
            _kAndroidChannelName,
            description: _kAndroidChannelDescription,
            importance: Importance.high,
          ),
        );
        await android.requestNotificationsPermission();
      }
    }

    if (Platform.isIOS) {
      final ios = _idlePauseNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _idleNotificationsInitialized = true;
  } on PlatformException catch (e, st) {
    debugPrint('Idle notifications init failed: $e\n$st');
  } catch (e, st) {
    debugPrint('Idle notifications init failed: $e\n$st');
  }
}

/// Shows the localized idle-pause message as a system notification.
Future<void> showIdlePauseNotification({
  required String title,
  required String body,
}) async {
  if (kIsWeb) {
    return;
  }
  try {
    await ensureIdlePauseNotificationsReady();
    if (!_idleNotificationsInitialized) {
      return;
    }
    await _idlePauseNotificationsPlugin.show(
      id: kIdlePauseNotificationId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _kAndroidChannelId,
          _kAndroidChannelName,
          channelDescription: _kAndroidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  } on PlatformException catch (e, st) {
    debugPrint('Idle notification show failed: $e\n$st');
  } catch (e, st) {
    debugPrint('Idle notification show failed: $e\n$st');
  }
}

/// Removes the idle-pause notification when the user returns to the app.
Future<void> dismissIdlePauseNotification() async {
  if (kIsWeb) {
    return;
  }
  try {
    await ensureIdlePauseNotificationsReady();
    if (!_idleNotificationsInitialized) {
      return;
    }
    await _idlePauseNotificationsPlugin.cancel(id: kIdlePauseNotificationId);
  } on PlatformException catch (e, st) {
    debugPrint('Idle notification dismiss failed: $e\n$st');
  } catch (e, st) {
    debugPrint('Idle notification dismiss failed: $e\n$st');
  }
}
