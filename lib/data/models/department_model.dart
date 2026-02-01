import 'package:equatable/equatable.dart';

import '../../domain/entities/department.dart';
import 'employee_model.dart';

class DepartmentModel extends Equatable {
  final int id;
  final String name;
  final String location;
  final List<EmployeeModel> employees;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.location,
    this.employees = const [],
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      employees:
          (json['employees'] as List<dynamic>?)
              ?.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'employees': employees.map((e) => e.toJson()).toList(),
  };

  Department toEntity() => Department(
    id: id,
    name: name,
    location: location,
    employees: employees.map((e) => e.toEntity()).toList(),
  );

  @override
  List<Object?> get props => [id, name, location, employees];
}
