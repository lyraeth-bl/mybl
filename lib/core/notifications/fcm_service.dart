// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../features/device_token/domain/usecases/register_use_case.dart';
import '../../features/notifications/data/datasources/notification_local_data_source.dart';
import '../../features/notifications/data/models/app_notification_model/app_notification_model.dart';
import '../../firebase_options.dart';
import '../storage/storage_keys/hive_storage_names.dart';

const String _notificationChannelId = 'my_bl_notifications';
const String _notificationChannelName = 'My BL Notifications';
const String _downloadChannelId = 'my_bl_downloads';
const String _downloadChannelName = 'My BL Downloads';

enum FCMActivationResult { enabled, denied, failed }

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await _initializeFirebaseIfNeeded();
  final notification = await _BackgroundNotificationStorage.save(message);

  if (message.notification == null) {
    await _BackgroundNotificationDisplay.show(notification, message.data);
  }
}

class FCMService {
  FCMService(
    this._firebaseMessaging,
    this._localNotifications,
    this._notificationLocalDataSource,
    this._registerDeviceTokenUseCase,
  );

  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationLocalDataSource _notificationLocalDataSource;
  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;

  Future<void>? _initialization;
  Future<FCMActivationResult>? _authenticatedActivation;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<bool> areNotificationsEnabled() async {
    await initialize();

    return _areNotificationsEnabled();
  }

  Future<bool> shouldAskNotificationPermission() async {
    await initialize();

    final areNotificationsEnabled = await _areNotificationsEnabled();
    return !areNotificationsEnabled;
  }

  Future<FCMActivationResult> activateSilentlyForAuthenticatedUser() async {
    final areNotificationsEnabled = await _areNotificationsEnabled();
    if (!areNotificationsEnabled) return FCMActivationResult.denied;

    return _registerDeviceTokenForAuthenticatedUser();
  }

  Future<FCMActivationResult> activateForAuthenticatedUser() async {
    if (_tokenRefreshSubscription != null) return FCMActivationResult.enabled;
    if (_authenticatedActivation != null) return _authenticatedActivation!;

    _authenticatedActivation = _activateForAuthenticatedUser();

    try {
      final result = await _authenticatedActivation!;
      if (result == FCMActivationResult.failed) {
        _authenticatedActivation = null;
      }

      return result;
    } catch (_) {
      _authenticatedActivation = null;
      return FCMActivationResult.failed;
    }
  }

  Future<void> deactivateForUnauthenticatedUser() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _authenticatedActivation = null;
  }

  Future<void> _initialize() async {
    await _initializeFirebaseIfNeeded();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) await _handleOpenedMessage(initialMessage);
  }

  Future<FCMActivationResult> _activateForAuthenticatedUser() async {
    await initialize();
    final authorizationStatus = await _requestNotificationPermission();

    if (!_canReceiveNotifications(authorizationStatus)) {
      return FCMActivationResult.denied;
    }

    return _registerDeviceTokenForAuthenticatedUser();
  }

  Future<FCMActivationResult> _registerDeviceTokenForAuthenticatedUser() async {
    final isTokenRegistered = await _registerCurrentToken();
    if (!isTokenRegistered) return FCMActivationResult.failed;

    _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen(
      (token) => _registerDeviceToken(token).ignore(),
    );

    return FCMActivationResult.enabled;
  }

  Future<bool> _areNotificationsEnabled() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final areAndroidNotificationsEnabled = await androidPlugin
        ?.areNotificationsEnabled();

    if (areAndroidNotificationsEnabled != null) {
      return areAndroidNotificationsEnabled;
    }

    final settings = await _firebaseMessaging.getNotificationSettings();

    return _canReceiveNotifications(settings.authorizationStatus);
  }

  Future<void> showDownloadProgress({
    required int id,
    required String title,
    required int progress,
    int maxProgress = 100,
    String? body,
  }) async {
    await _localNotifications.show(
      id: id,
      title: title,
      body: body ?? '$progress%',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _downloadChannelId,
          _downloadChannelName,
          channelDescription: 'Download progress notifications',
          importance: Importance.low,
          priority: Priority.low,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          ongoing: progress < maxProgress,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: progress == maxProgress,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  Future<void> showDownloadComplete({
    required int id,
    required String title,
    String? body,
  }) async {
    await _localNotifications.show(
      id: id,
      title: title,
      body: body ?? 'Download selesai',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _downloadChannelId,
          _downloadChannelName,
          channelDescription: 'Download progress notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showDownloadFailed({
    required int id,
    required String title,
    String? body,
  }) async {
    await _localNotifications.show(
      id: id,
      title: title,
      body: body ?? 'Download gagal',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _downloadChannelId,
          _downloadChannelName,
          channelDescription: 'Download progress notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelDownloadNotification(int id) =>
      _localNotifications.cancel(id: id);

  Future<AuthorizationStatus> _requestNotificationPermission() async {
    final settings = await _firebaseMessaging.requestPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return settings.authorizationStatus;
  }

  bool _canReceiveNotifications(AuthorizationStatus authorizationStatus) {
    return switch (authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
      AuthorizationStatus.denied || AuthorizationStatus.notDetermined => false,
    };
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _notificationChannelId,
        _notificationChannelName,
        description: 'General app notifications',
        importance: Importance.high,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _downloadChannelId,
        _downloadChannelName,
        description: 'Download progress notifications',
        importance: Importance.low,
      ),
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
  }

  Future<bool> _registerCurrentToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token == null) return false;

    return _registerDeviceToken(token);
  }

  Future<bool> _registerDeviceToken(String token) async {
    final result = await _registerDeviceTokenUseCase(fcmToken: token);

    return result.match((failure) => false, (unit) => true);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = AppNotificationModel.fromRemoteMessage(message);

    await _notificationLocalDataSource.saveNotification(notification);
    await _showForegroundNotification(notification, message.data);
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    final notification = AppNotificationModel.fromRemoteMessage(message);

    await _notificationLocalDataSource.saveNotification(notification);
    await _notificationLocalDataSource.markAsRead(notification.id);
  }

  Future<void> _showForegroundNotification(
    AppNotificationModel notification,
    Map<String, dynamic> data,
  ) async {
    await _localNotifications.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: const AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode({
        'id': notification.id,
        'target_type': notification.targetType,
        'target_value': notification.targetValue,
        'data': data,
      }),
    );
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      return;
    }

    if (decoded is! Map<String, dynamic>) return;

    final id = decoded['id'];
    final notificationId = id is int ? id : int.tryParse(id?.toString() ?? '');
    if (notificationId == null) return;

    await _notificationLocalDataSource.markAsRead(notificationId);
  }
}

Future<void> _initializeFirebaseIfNeeded() async {
  if (Firebase.apps.isNotEmpty) return;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class _BackgroundNotificationStorage {
  static Future<AppNotificationModel> save(RemoteMessage message) async {
    await Hive.initFlutter();

    if (!Hive.isBoxOpen(HiveStorageBoxNames.userBoxKey)) {
      await Hive.openBox(HiveStorageBoxNames.userBoxKey);
    }

    final notification = AppNotificationModel.fromRemoteMessage(message);
    final box = Hive.box(HiveStorageBoxNames.userBoxKey);
    final rawListData = box.get(HiveStorageNames.userNotificationsKey);
    final notifications = rawListData == null
        ? <Map<String, dynamic>>[]
        : (rawListData as List<dynamic>)
              .map((m) => Map<String, dynamic>.from(m))
              .toList();

    final duplicateIndex = notifications.indexWhere(
      (storedNotification) =>
          storedNotification['id'] == notification.id ||
          (notification.fcmMessageId != null &&
              storedNotification['fcm_message_id'] ==
                  notification.fcmMessageId),
    );

    if (duplicateIndex >= 0) {
      notifications[duplicateIndex] = notification.toJson();
    } else {
      notifications.insert(0, notification.toJson());
    }

    await box.put(HiveStorageNames.userNotificationsKey, notifications);

    return notification;
  }
}

class _BackgroundNotificationDisplay {
  static Future<void> show(
    AppNotificationModel notification,
    Map<String, dynamic> data,
  ) async {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await localNotifications.initialize(settings: initializationSettings);

    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _notificationChannelId,
            _notificationChannelName,
            description: 'General app notifications',
            importance: Importance.high,
          ),
        );

    await localNotifications.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode({
        'id': notification.id,
        'target_type': notification.targetType,
        'target_value': notification.targetValue,
        'data': data,
      }),
    );
  }
}
