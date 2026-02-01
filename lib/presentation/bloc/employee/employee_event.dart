import 'package:equatable/equatable.dart';

sealed class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  final int departmentId;

  const LoadEmployees(this.departmentId);

  @override
  List<Object?> get props => [departmentId];
}

class RefreshEmployees extends EmployeeEvent {
  final int departmentId;

  const RefreshEmployees(this.departmentId);

  @override
  List<Object?> get props => [departmentId];
}

class DeleteEmployee extends EmployeeEvent {
  final int departmentId;
  final int employeeId;

  const DeleteEmployee(this.departmentId, this.employeeId);

  @override
  List<Object?> get props => [departmentId, employeeId];
}
