import 'package:equatable/equatable.dart';

import '../../../domain/entities/employee.dart';

sealed class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {
  const EmployeeInitial();
}

class EmployeeLoading extends EmployeeState {
  const EmployeeLoading();
}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;

  const EmployeeLoaded(this.employees);

  bool get isEmpty => employees.isEmpty;

  @override
  List<Object?> get props => [employees];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmployeeDeleting extends EmployeeState {
  final List<Employee> employees;
  final int deletingId;

  const EmployeeDeleting(this.employees, this.deletingId);

  @override
  List<Object?> get props => [employees, deletingId];
}

class EmployeeDeleteSuccess extends EmployeeState {
  final List<Employee> employees;
  final String message;

  const EmployeeDeleteSuccess(this.employees, this.message);

  bool get isEmpty => employees.isEmpty;

  @override
  List<Object?> get props => [employees, message];
}

class EmployeeDeleteError extends EmployeeState {
  final List<Employee> employees;
  final String message;

  const EmployeeDeleteError(this.employees, this.message);

  @override
  List<Object?> get props => [employees, message];
}
