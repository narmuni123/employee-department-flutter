import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/usecases/delete_employee.dart' as usecase;
import '../../../domain/usecases/get_employees_by_department.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployeesByDepartment _getEmployeesByDepartment;
  final usecase.DeleteEmployee _deleteEmployee;

  EmployeeBloc({
    required GetEmployeesByDepartment getEmployeesByDepartment,
    required usecase.DeleteEmployee deleteEmployee,
  }) : _getEmployeesByDepartment = getEmployeesByDepartment,
       _deleteEmployee = deleteEmployee,
       super(const EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<RefreshEmployees>(_onRefreshEmployees);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeLoading());

    final result = await _getEmployeesByDepartment(event.departmentId);

    result.fold(
      (exception) => emit(EmployeeError(_mapExceptionToMessage(exception))),
      (employees) => emit(EmployeeLoaded(employees)),
    );
  }

  Future<void> _onRefreshEmployees(
    RefreshEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    await _onLoadEmployees(LoadEmployees(event.departmentId), emit);
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    final currentEmployees = _getCurrentEmployees();

    emit(EmployeeDeleting(currentEmployees, event.employeeId));

    final result = await _deleteEmployee(event.departmentId, event.employeeId);

    result.fold(
      (exception) => emit(
        EmployeeDeleteError(
          currentEmployees,
          _mapExceptionToMessage(exception),
        ),
      ),
      (_) {
        final updatedEmployees = currentEmployees
            .where((e) => e.id != event.employeeId)
            .toList();
        emit(
          EmployeeDeleteSuccess(
            updatedEmployees,
            'Employee deleted successfully',
          ),
        );
      },
    );
  }

  List<Employee> _getCurrentEmployees() {
    final currentState = state;
    return switch (currentState) {
      EmployeeLoaded(:final employees) => employees,
      EmployeeDeleting(:final employees) => employees,
      EmployeeDeleteSuccess(:final employees) => employees,
      EmployeeDeleteError(:final employees) => employees,
      _ => <Employee>[],
    };
  }

  String _mapExceptionToMessage(AppException exception) {
    return switch (exception) {
      NetworkException() => 'No internet connection',
      ServerException(statusCode: 404) => 'Resource not found',
      ServerException(statusCode: 500) =>
        'Server error, please try again later',
      ServerException(:final message) => message,
      ValidationException(:final message) => message,
    };
  }
}
