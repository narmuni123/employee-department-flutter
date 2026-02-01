import 'package:equatable/equatable.dart';

sealed class DepartmentEvent extends Equatable {
  const DepartmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDepartments extends DepartmentEvent {
  const LoadDepartments();
}

class RefreshDepartments extends DepartmentEvent {
  const RefreshDepartments();
}
