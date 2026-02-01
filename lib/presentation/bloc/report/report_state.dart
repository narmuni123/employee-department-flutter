import 'package:equatable/equatable.dart';

enum ReportStatus { initial, downloading, downloaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final String? filePath;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.filePath,
    this.errorMessage,
  });

  bool get isDownloading => status == ReportStatus.downloading;
  bool get isDownloaded => status == ReportStatus.downloaded;
  bool get hasError => status == ReportStatus.error;

  ReportState copyWith({
    ReportStatus? status,
    String? Function()? filePath,
    String? Function()? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      filePath: filePath != null ? filePath() : this.filePath,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, filePath, errorMessage];
}
