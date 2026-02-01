import 'dart:async';

class NotificationPayload {
  final String? screen;
  final Map<String, dynamic>? data;

  NotificationPayload({this.screen, this.data});

  @override
  String toString() => 'NotificationPayload(screen: $screen, data: $data)';
}

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showLocalNotification(String title, String body);
  Stream<NotificationPayload> get onNotificationTapped;
  void dispose();
}

class MockNotificationService implements NotificationService {
  final StreamController<NotificationPayload> _notificationTapController =
      StreamController<NotificationPayload>.broadcast();

  final List<_MockNotification> _displayedNotifications = [];

  void Function(String title, String body)? onNotificationDisplayed;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  @override
  Future<void> showLocalNotification(String title, String body) async {
    if (!_isInitialized) {
      throw StateError(
        'NotificationService must be initialized before showing notifications',
      );
    }

    final notification = _MockNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _displayedNotifications.add(notification);
    onNotificationDisplayed?.call(title, body);
  }

  @override
  Stream<NotificationPayload> get onNotificationTapped =>
      _notificationTapController.stream;

  void simulateNotificationTap(NotificationPayload payload) {
    _notificationTapController.add(payload);
  }

  List<_MockNotification> get displayedNotifications =>
      List.unmodifiable(_displayedNotifications);

  void clearNotifications() {
    _displayedNotifications.clear();
  }

  bool get isInitialized => _isInitialized;

  @override
  void dispose() {
    _notificationTapController.close();
  }
}

class _MockNotification {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;

  _MockNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  @override
  String toString() =>
      '_MockNotification(id: $id, title: $title, body: $body, timestamp: $timestamp)';
}

class NotificationMessages {
  NotificationMessages._();

  static const String employeeNotificationTitle = 'Employee Management';
  static const String employeeAddedSuccessfully = 'Employee added successfully';
  static const String reportNotificationTitle = 'Reports';
  static const String reportGenerated = 'Report generated';
}

class NotificationScreenRoutes {
  NotificationScreenRoutes._();

  static const String employeeList = '/employees';
  static const String departmentList = '/departments';
  static const String reports = '/reports';
}
