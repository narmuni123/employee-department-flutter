import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/usecases/download_report.dart';
import 'package:employment_department/presentation/bloc/report/report_cubit.dart';
import 'package:employment_department/presentation/screens/reports_screen.dart';

class MockDownloadReport extends Mock implements DownloadReport {}

void main() {
  late MockDownloadReport mockDownloadReport;
  late ReportCubit reportCubit;

  setUp(() {
    mockDownloadReport = MockDownloadReport();
  });

  tearDown(() {
    reportCubit.close();
  });

  Widget createTestWidget() {
    reportCubit = ReportCubit(downloadReport: mockDownloadReport);
    return MaterialApp(
      home: BlocProvider<ReportCubit>.value(
        value: reportCubit,
        child: const ReportsScreen(),
      ),
    );
  }

  group('ReportsScreen', () {
    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('displays header with icon and title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Header icon
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);

      // Header title
      expect(find.text('Department Reports'), findsOneWidget);

      // Header subtitle
      expect(
        find.text('Download and view organizational reports'),
        findsOneWidget,
      );
    });

    testWidgets('displays download button in initial state', (tester) async {
      // Validates: Requirement 6.1 - Display a button to download Department Employee Report
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Download Report'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('displays report card with title and description', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Department Employee Report'), findsOneWidget);
      expect(
        find.text('Complete list of all employees by department'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('displays info text at bottom', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(
        find.text(
          'Reports are generated as PDF files and will open in your device\'s default PDF viewer.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays progress indicator while downloading', (
      tester,
    ) async {
      // Validates: Requirement 6.6 - Display a progress indicator while download is in progress
      final completer = Completer<Either<AppException, String>>();
      when(() => mockDownloadReport()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      // Tap download button
      await tester.tap(find.text('Download Report'));
      await tester.pump();

      // Should show progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Downloading report...'), findsOneWidget);

      // Download button should not be visible
      expect(find.text('Download Report'), findsNothing);
    });

    testWidgets('displays success state after download completes', (
      tester,
    ) async {
      // Validates: Requirements 6.3, 6.4 - Save file and open with PDF viewer
      when(
        () => mockDownloadReport(),
      ).thenAnswer((_) async => const Right('/path/to/report.pdf'));

      await tester.pumpWidget(createTestWidget());

      // Tap download button
      await tester.tap(find.text('Download Report'));
      await tester.pumpAndSettle();

      // Should show success message (may appear in both card and snackbar)
      expect(find.text('Report downloaded successfully'), findsWidgets);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Should show action buttons
      expect(find.text('Open Again'), findsOneWidget);
      expect(find.text('Download New'), findsOneWidget);
    });

    testWidgets('displays error message when download fails', (tester) async {
      // Validates: Requirement 6.5 - Display an error message if download fails
      when(() => mockDownloadReport()).thenAnswer(
        (_) async => Left(NetworkException('No internet connection')),
      );

      await tester.pumpWidget(createTestWidget());

      // Tap download button
      await tester.tap(find.text('Download Report'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Should show retry button
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('retries download when Try Again button is pressed', (
      tester,
    ) async {
      // First call returns error
      when(() => mockDownloadReport()).thenAnswer(
        (_) async => Left(NetworkException('No internet connection')),
      );

      await tester.pumpWidget(createTestWidget());

      // Tap download button
      await tester.tap(find.text('Download Report'));
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsOneWidget);

      // Setup: Second call returns success
      when(
        () => mockDownloadReport(),
      ).thenAnswer((_) async => const Right('/path/to/report.pdf'));

      // Tap retry button
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Should now show success (may appear in both card and snackbar)
      expect(find.text('Report downloaded successfully'), findsWidgets);
    });

    testWidgets('can download new report after successful download', (
      tester,
    ) async {
      when(
        () => mockDownloadReport(),
      ).thenAnswer((_) async => const Right('/path/to/report.pdf'));

      await tester.pumpWidget(createTestWidget());

      // First download
      await tester.tap(find.text('Download Report'));
      await tester.pumpAndSettle();

      expect(find.text('Report downloaded successfully'), findsWidgets);

      // Tap Download New button
      await tester.tap(find.text('Download New'));
      await tester.pumpAndSettle();

      // Should show success again (new download completed)
      expect(find.text('Report downloaded successfully'), findsWidgets);

      // Verify download was called twice
      verify(() => mockDownloadReport()).called(2);
    });

    testWidgets('displays server error message correctly', (tester) async {
      // Validates: Requirement 6.5 - Display an error message if download fails
      when(() => mockDownloadReport()).thenAnswer(
        (_) async =>
            Left(ServerException(500, 'Server error, please try again later')),
      );

      await tester.pumpWidget(createTestWidget());

      // Tap download button
      await tester.tap(find.text('Download Report'));
      await tester.pumpAndSettle();

      // Should show server error message
      expect(find.text('Server error, please try again later'), findsOneWidget);
    });

    testWidgets('shows snackbar on successful download', (tester) async {
      when(
        () => mockDownloadReport(),
      ).thenAnswer((_) async => const Right('/path/to/report.pdf'));

      await tester.pumpWidget(createTestWidget());

      // Tap download button
      await tester.tap(find.text('Download Report'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Report downloaded successfully'), findsNWidgets(2));
    });
  });
}
