import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:employment_department/core/services/notification_service.dart';

void main() {
  group('MockNotificationService', () {
    late MockNotificationService service;

    setUp(() {
      service = MockNotificationService();
    });

    tearDown(() {
      service.dispose();
    });

    group('initialize', () {
      test('should initialize successfully', () async {
        expect(service.isInitialized, isFalse);

        await service.initialize();

        expect(service.isInitialized, isTrue);
      });

      test('should be idempotent - multiple calls should not fail', () async {
        await service.initialize();
        await service.initialize();
        await service.initialize();

        expect(service.isInitialized, isTrue);
      });
    });

    group('showLocalNotification', () {
      test('should throw StateError if not initialized', () async {
        expect(
          () => service.showLocalNotification('Title', 'Body'),
          throwsStateError,
        );
      });

      test('should display notification when initialized', () async {
        await service.initialize();

        await service.showLocalNotification('Test Title', 'Test Body');

        expect(service.displayedNotifications.length, equals(1));
        expect(
          service.displayedNotifications.first.title,
          equals('Test Title'),
        );
        expect(service.displayedNotifications.first.body, equals('Test Body'));
      });

      test('should call onNotificationDisplayed callback', () async {
        await service.initialize();

        String? capturedTitle;
        String? capturedBody;
        service.onNotificationDisplayed = (title, body) {
          capturedTitle = title;
          capturedBody = body;
        };

        await service.showLocalNotification('Callback Title', 'Callback Body');

        expect(capturedTitle, equals('Callback Title'));
        expect(capturedBody, equals('Callback Body'));
      });

      test(
        'should display employee added notification with correct message',
        () async {
          await service.initialize();

          await service.showLocalNotification(
            NotificationMessages.employeeNotificationTitle,
            NotificationMessages.employeeAddedSuccessfully,
          );

          expect(service.displayedNotifications.length, equals(1));
          expect(
            service.displayedNotifications.first.body,
            equals('Employee added successfully'),
          );
        },
      );

      test(
        'should display report generated notification with correct message',
        () async {
          await service.initialize();

          await service.showLocalNotification(
            NotificationMessages.reportNotificationTitle,
            NotificationMessages.reportGenerated,
          );

          expect(service.displayedNotifications.length, equals(1));
          expect(
            service.displayedNotifications.first.body,
            equals('Report generated'),
          );
        },
      );

      test('should store multiple notifications', () async {
        await service.initialize();

        await service.showLocalNotification('Title 1', 'Body 1');
        await service.showLocalNotification('Title 2', 'Body 2');
        await service.showLocalNotification('Title 3', 'Body 3');

        expect(service.displayedNotifications.length, equals(3));
      });
    });

    group('onNotificationTapped', () {
      test('should emit payload when notification is tapped', () async {
        await service.initialize();

        final payload = NotificationPayload(
          screen: NotificationScreenRoutes.employeeList,
          data: {'departmentId': 1},
        );

        expectLater(
          service.onNotificationTapped,
          emits(
            predicate<NotificationPayload>(
              (p) =>
                  p.screen == NotificationScreenRoutes.employeeList &&
                  p.data?['departmentId'] == 1,
            ),
          ),
        );

        service.simulateNotificationTap(payload);
      });

      test('should emit multiple payloads for multiple taps', () async {
        await service.initialize();

        final payloads = [
          NotificationPayload(screen: NotificationScreenRoutes.employeeList),
          NotificationPayload(screen: NotificationScreenRoutes.departmentList),
          NotificationPayload(screen: NotificationScreenRoutes.reports),
        ];

        expectLater(
          service.onNotificationTapped,
          emitsInOrder([
            predicate<NotificationPayload>(
              (p) => p.screen == NotificationScreenRoutes.employeeList,
            ),
            predicate<NotificationPayload>(
              (p) => p.screen == NotificationScreenRoutes.departmentList,
            ),
            predicate<NotificationPayload>(
              (p) => p.screen == NotificationScreenRoutes.reports,
            ),
          ]),
        );

        for (final payload in payloads) {
          service.simulateNotificationTap(payload);
        }
      });

      test('should support broadcast - multiple listeners', () async {
        await service.initialize();

        final completer1 = Completer<NotificationPayload>();
        final completer2 = Completer<NotificationPayload>();

        service.onNotificationTapped.first.then(completer1.complete);
        service.onNotificationTapped.first.then(completer2.complete);

        final payload = NotificationPayload(
          screen: NotificationScreenRoutes.reports,
        );
        service.simulateNotificationTap(payload);

        final result1 = await completer1.future;
        final result2 = await completer2.future;

        expect(result1.screen, equals(NotificationScreenRoutes.reports));
        expect(result2.screen, equals(NotificationScreenRoutes.reports));
      });
    });

    group('clearNotifications', () {
      test('should clear all displayed notifications', () async {
        await service.initialize();

        await service.showLocalNotification('Title 1', 'Body 1');
        await service.showLocalNotification('Title 2', 'Body 2');
        expect(service.displayedNotifications.length, equals(2));

        service.clearNotifications();

        expect(service.displayedNotifications.length, equals(0));
      });
    });

    group('dispose', () {
      test('should close the stream controller', () async {
        await service.initialize();

        service.dispose();

        // After dispose, adding to the stream should not work
        // The stream should be closed
        expect(
          () => service.simulateNotificationTap(NotificationPayload()),
          throwsStateError,
        );
      });
    });
  });

  group('NotificationPayload', () {
    test('should create with screen and data', () {
      final payload = NotificationPayload(
        screen: '/test',
        data: {'key': 'value'},
      );

      expect(payload.screen, equals('/test'));
      expect(payload.data, equals({'key': 'value'}));
    });

    test('should create with null values', () {
      final payload = NotificationPayload();

      expect(payload.screen, isNull);
      expect(payload.data, isNull);
    });

    test('should have meaningful toString', () {
      final payload = NotificationPayload(screen: '/test', data: {'id': 1});

      expect(payload.toString(), contains('/test'));
      expect(payload.toString(), contains('id'));
    });
  });

  group('NotificationMessages', () {
    test('should have correct employee added message', () {
      expect(
        NotificationMessages.employeeAddedSuccessfully,
        equals('Employee added successfully'),
      );
    });

    test('should have correct report generated message', () {
      expect(NotificationMessages.reportGenerated, equals('Report generated'));
    });
  });

  group('NotificationScreenRoutes', () {
    test('should have correct route constants', () {
      expect(NotificationScreenRoutes.employeeList, equals('/employees'));
      expect(NotificationScreenRoutes.departmentList, equals('/departments'));
      expect(NotificationScreenRoutes.reports, equals('/reports'));
    });
  });
}
