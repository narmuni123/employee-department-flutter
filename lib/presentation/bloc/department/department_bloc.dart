import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/usecases/get_departments.dart';
import 'department_event.dart';
import 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final GetDepartments _getDepartments;

  DepartmentBloc({required GetDepartments getDepartments})
    : _getDepartments = getDepartments,
      super(const DepartmentInitial()) {
    on<LoadDepartments>(_onLoadDepartments);
    on<RefreshDepartments>(_onRefreshDepartments);
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(const DepartmentLoading());

    final result = await _getDepartments();

    result.fold(
      (exception) => emit(DepartmentError(_mapExceptionToMessage(exception))),
      (departments) => emit(DepartmentLoaded(departments)),
    );
  }

  Future<void> _onRefreshDepartments(
    RefreshDepartments event,
    Emitter<DepartmentState> emit,
  ) async {
    await _onLoadDepartments(const LoadDepartments(), emit);
  }

  String _mapExceptionToMessage(AppException exception) {
    return switch (exception) {
      NetworkException() => 'No internet connection',
      ServerException(statusCode: 404) => 'Resource not found',
      ServerException(statusCode: 500) =>
        'Server error, please try again later',
      ServerException(:final message) => message,
      ValidationException(:final message) => message,
      ParsingException(:final message) => 'Data parsing error: $message',
    };
  }
}
