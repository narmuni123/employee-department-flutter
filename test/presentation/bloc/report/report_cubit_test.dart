import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/usecases/download_report.dart';
import 'package:employment_department/presentation/bloc/report/report_cubit.dart';
import 'package:employment_department/presentation/bloc/report/report_state.dart';

// Mock classes
class MockDownloadReport extends Mock implements DownloadReport {}

void main() {
  late MockDownloadReport mockDownloadReport;
  late ReportCubit reportCubit;

  setUp(() {
    mockDownloadReport = MockDownloadReport();
    reportCubit = ReportCubit(downloadReport: mockDownloadReport);
  });

  tearDown(() {
    reportCubit.close();
  });

  group('ReportCubit', () {
    test('initial state is ReportState with initial status', () {
      expect(reportCubit.state, const ReportState());
      expect(reportCubit.state.status, ReportStatus.initial);
      expect(reportCubit.state.filePath, isNull);
      expect(reportCubit.state.errorMessage, isNull);
    });

    group('downloadDepartmentReport', () {
      const testFilePath = '/path/to/department_employees_report.pdf';

      blocTest<ReportCubit, ReportState>(
        'emits [downloading, downloaded] when download succeeds',
        build: () {
          when(
            () => mockDownloadReport(),
          ).thenAnswer((_) async => const Right(testFilePath));
          return reportCubit;
        },
        act: (cubit) => cubit.downloadDepartmentReport(),
        expect: () => [
          // First: downloading state with progress indicator
          // Validates: Requirement 6.6
          const ReportState(status: ReportStatus.downloading),
          // Second: downloaded state with file path
          // Validates: Requirements 6.2, 6.3
          const ReportState(
            status: ReportStatus.downloaded,
            filePath: testFilePath,
          ),
        ],
        verify: (_) {
          verify(() => mockDownloadReport()).called(1);
        },
      );

      blocTest<ReportCubit, ReportState>(
        'emits [downloading, error] when download fails with NetworkException',
        build: () {
          when(() => mockDownloadReport()).thenAnswer(
            (_) async => Left(NetworkException('No internet connection')),
          );
          return reportCubit;
        },
        act: (cubit) => cubit.downloadDepartmentReport(),
        expect: () => [
          // First: downloading state
          // Validates: Requirement 6.6
          const ReportState(status: ReportStatus.downloading),
          // Second: error state with message
          // Validates: Requirement 6.5
          const ReportState(
            status: ReportStatus.error,
            errorMessage: 'No internet connection',
          ),
        ],
        verify: (_) {
          verify(() => mockDownloadReport()).called(1);
        },
      );

      blocTest<ReportCubit, ReportState>(
        'emits [downloading, error] when download fails with ServerException',
        build: () {
          when(
            () => mockDownloadReport(),
          ).thenAnswer((_) async => Left(ServerException(500, 'Server error')));
          return reportCubit;
        },
        act: (cubit) => cubit.downloadDepartmentReport(),
        expect: () => [
          const ReportState(status: ReportStatus.downloading),
          const ReportState(
            status: ReportStatus.error,
            errorMessage: 'Server error',
          ),
        ],
      );

      blocTest<ReportCubit, ReportState>(
        'clears previous error when starting new download',
        build: () {
          when(
            () => mockDownloadReport(),
          ).thenAnswer((_) async => const Right(testFilePath));
          return reportCubit;
        },
        seed: () => const ReportState(
          status: ReportStatus.error,
          errorMessage: 'Previous error',
        ),
        act: (cubit) => cubit.downloadDepartmentReport(),
        expect: () => [
          const ReportState(status: ReportStatus.downloading),
          const ReportState(
            status: ReportStatus.downloaded,
            filePath: testFilePath,
          ),
        ],
      );

      blocTest<ReportCubit, ReportState>(
        'clears previous file path when starting new download',
        build: () {
          when(
            () => mockDownloadReport(),
          ).thenAnswer((_) async => const Right('/new/path/report.pdf'));
          return reportCubit;
        },
        seed: () => const ReportState(
          status: ReportStatus.downloaded,
          filePath: '/old/path/report.pdf',
        ),
        act: (cubit) => cubit.downloadDepartmentReport(),
        expect: () => [
          const ReportState(status: ReportStatus.downloading),
          const ReportState(
            status: ReportStatus.downloaded,
            filePath: '/new/path/report.pdf',
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<ReportCubit, ReportState>(
        'resets state to initial from downloaded state',
        build: () => reportCubit,
        seed: () => const ReportState(
          status: ReportStatus.downloaded,
          filePath: '/path/to/report.pdf',
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [const ReportState()],
      );

      blocTest<ReportCubit, ReportState>(
        'resets state to initial from error state',
        build: () => reportCubit,
        seed: () => const ReportState(
          status: ReportStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [const ReportState()],
      );
    });
  });

  group('ReportState', () {
    test('isDownloading returns true when status is downloading', () {
      const state = ReportState(status: ReportStatus.downloading);
      expect(state.isDownloading, isTrue);
      expect(state.isDownloaded, isFalse);
      expect(state.hasError, isFalse);
    });

    test('isDownloaded returns true when status is downloaded', () {
      const state = ReportState(
        status: ReportStatus.downloaded,
        filePath: '/path/to/file.pdf',
      );
      expect(state.isDownloading, isFalse);
      expect(state.isDownloaded, isTrue);
      expect(state.hasError, isFalse);
    });

    test('hasError returns true when status is error', () {
      const state = ReportState(
        status: ReportStatus.error,
        errorMessage: 'Error message',
      );
      expect(state.isDownloading, isFalse);
      expect(state.isDownloaded, isFalse);
      expect(state.hasError, isTrue);
    });

    test('copyWith creates new state with updated values', () {
      const original = ReportState(status: ReportStatus.initial);

      final updated = original.copyWith(
        status: ReportStatus.downloaded,
        filePath: () => '/path/to/file.pdf',
      );

      expect(updated.status, ReportStatus.downloaded);
      expect(updated.filePath, '/path/to/file.pdf');
      expect(updated.errorMessage, isNull);
    });

    test('copyWith preserves values when not specified', () {
      const original = ReportState(
        status: ReportStatus.downloaded,
        filePath: '/path/to/file.pdf',
      );

      final updated = original.copyWith(errorMessage: () => 'New error');

      expect(updated.status, ReportStatus.downloaded);
      expect(updated.filePath, '/path/to/file.pdf');
      expect(updated.errorMessage, 'New error');
    });

    test('copyWith can set nullable fields to null', () {
      const original = ReportState(
        status: ReportStatus.error,
        errorMessage: 'Some error',
        filePath: '/path/to/file.pdf',
      );

      final updated = original.copyWith(
        status: ReportStatus.downloading,
        errorMessage: () => null,
        filePath: () => null,
      );

      expect(updated.status, ReportStatus.downloading);
      expect(updated.errorMessage, isNull);
      expect(updated.filePath, isNull);
    });

    test('equality works correctly', () {
      const state1 = ReportState(
        status: ReportStatus.downloaded,
        filePath: '/path/to/file.pdf',
      );
      const state2 = ReportState(
        status: ReportStatus.downloaded,
        filePath: '/path/to/file.pdf',
      );
      const state3 = ReportState(
        status: ReportStatus.downloaded,
        filePath: '/different/path.pdf',
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
