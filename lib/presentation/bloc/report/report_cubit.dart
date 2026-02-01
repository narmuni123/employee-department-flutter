import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

import '../../../domain/usecases/download_report.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final DownloadReport _downloadReport;

  ReportCubit({required DownloadReport downloadReport})
    : _downloadReport = downloadReport,
      super(const ReportState());

  Future<void> downloadDepartmentReport() async {
    emit(
      state.copyWith(
        status: ReportStatus.downloading,
        errorMessage: () => null,
        filePath: () => null,
      ),
    );

    final result = await _downloadReport();

    result.fold(
      (exception) {
        emit(
          state.copyWith(
            status: ReportStatus.error,
            errorMessage: () => exception.message,
          ),
        );
      },
      (filePath) {
        emit(
          state.copyWith(
            status: ReportStatus.downloaded,
            filePath: () => filePath,
          ),
        );
      },
    );
  }

  Future<bool> openReport() async {
    if (state.filePath == null) {
      return false;
    }

    try {
      final result = await OpenFile.open(state.filePath!);
      return result.type == ResultType.done;
    } catch (e) {
      emit(
        state.copyWith(
          status: ReportStatus.error,
          errorMessage: () => 'Failed to open PDF: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  Future<void> downloadAndOpenReport() async {
    await downloadDepartmentReport();

    if (state.isDownloaded && state.filePath != null) {
      await openReport();
    }
  }

  void reset() {
    emit(const ReportState());
  }
}
