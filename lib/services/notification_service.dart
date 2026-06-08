import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';
import 'storage_service.dart';

/// Background message handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static NotificationService? _instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load Firebase config from backend (no hardcoded keys)
      final config = await ApiService.instance.getFirebaseConfig();
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: config['apiKey'] as String? ?? '',
          appId: config['appId'] as String? ?? '',
          messagingSenderId: config['messagingSenderId'] as String? ?? '',
          projectId: config['projectId'] as String? ?? '',
        ),
      );
    } catch (e) {
      debugPrint('Firebase init from backend failed: $e');
      try {
        await Firebase.initializeApp();
      } catch (e2) {
        debugPrint('Firebase default init failed: $e2');
        return;
      }
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    await _setupFcmToken();
    _setupMessageHandlers();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _setupFcmToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final storage = await StorageService.getInstance();
      await storage.saveFcmToken(token);
    }
    _messaging.onTokenRefresh.listen((newToken) async {
      final storage = await StorageService.getInstance();
      await storage.saveFcmToken(newToken);
    });
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await showLocalNotification(
        title: notification.title ?? 'Noor Beauty Salon',
        body: notification.body ?? '',
        payload: message.data['type'] as String?,
      );
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    debugPrint('Message opened: ${message.data}');
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'noor_beauty_channel',
      'Noor Beauty Notifications',
      channelDescription: 'Booking confirmations, reminders, and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Booking confirmation — triggered within 5 seconds of booking.
  Future<void> showBookingConfirmation({
    required String serviceName,
    required String date,
    required String time,
  }) async {
    await showLocalNotification(
      id: 1,
      title: 'Booking Confirmed! ✨',
      body: 'Your $serviceName appointment on $date at $time is confirmed.',
      payload: 'booking_confirmation',
    );
  }

  /// 24-hour reminder before appointment.
  Future<void> scheduleReminder({
    required String serviceName,
    required String date,
    required String time,
  }) async {
    await showLocalNotification(
      id: 2,
      title: 'Appointment Tomorrow',
      body: 'Reminder: $serviceName on $date at $time. See you at Noor Beauty!',
      payload: 'booking_reminder',
    );
  }

  Future<void> showCancellationNotification({
    required String serviceName,
    required String date,
  }) async {
    await showLocalNotification(
      id: 3,
      title: 'Booking Cancelled',
      body: 'Your $serviceName appointment on $date has been cancelled.',
      payload: 'booking_cancelled',
    );
  }

  Future<void> showReviewPrompt({
    required String serviceName,
  }) async {
    await showLocalNotification(
      id: 4,
      title: 'How was your visit?',
      body: 'Rate your $serviceName experience at Noor Beauty Salon.',
      payload: 'review_prompt',
    );
  }
}
