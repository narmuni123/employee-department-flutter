import 'package:equatable/equatable.dart';

import '../../../domain/entities/department.dart';

sealed class DepartmentState extends Equatable {
  const DepartmentState();

  @override
  List<Object?> get props => [];
}

class DepartmentInitial extends DepartmentState {
  const DepartmentInitial();
}

class DepartmentLoading extends DepartmentState {
  const DepartmentLoading();
}

class DepartmentLoaded extends DepartmentState {
  final List<Department> departments;

  const DepartmentLoaded(this.departments);

  bool get isEmpty => departments.isEmpty;

  @override
  List<Object?> get props => [departments];
}

class DepartmentError extends DepartmentState {
  final String message;

  const DepartmentError(this.message);

  @override
  List<Object?> get props => [message];
}
