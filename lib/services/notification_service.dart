// lib/services/notification_service.dart
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:aud_for_bank/app/app.locator.dart';
import 'package:aud_for_bank/app/app.router.dart';

class NotificationService {
  final NavigationService _navigationService = locator<NavigationService>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  static const int IMAGE_LIMIT = 2;

  final _notificationTapController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onNotificationTap => _notificationTapController.stream;
  NotificationService() {
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      print('Received notification: ${message.notification?.title}, data: ${message.data}');
      final type = message.data['type'] as String?;
      if (type != null && _isValidThreatType(type)) {
        _navigationService.navigateTo(Routes.notificationView);
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  bool _isValidThreatType(String type) {
    return ['atm', 'bank'].contains(type.toLowerCase());
  }

  // Stream for ATM images
  Stream<List<String>> getAtmImagesStream() {
    return _databaseRef
        .child('images/atm_camera')
        .orderByKey()
        .limitToLast(IMAGE_LIMIT)
        .onValue
        .map((event) {
      final List<String> images = [];
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final image = value['image'] as String?;
          if (image != null && image.isNotEmpty) {
            images.add(image);
          }
        });
      }
      print('ATM images updated: ${images.length}');
      return images;
    });
  }

  // Stream for Bank images
  Stream<List<String>> getBankImagesStream() {
    return _databaseRef
        .child('images/locker_camera')
        .orderByKey()
        .limitToLast(IMAGE_LIMIT)
        .onValue
        .map((event) {
      final List<String> images = [];
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final image = value['image'] as String?;
          if (image != null && image.isNotEmpty) {
            images.add(image);
          }
        });
      }
      print('Bank images updated: ${images.length}');
      return images;
    });
  }
}