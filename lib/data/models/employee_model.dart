import 'package:equatable/equatable.dart';

import '../../domain/entities/employee.dart';

class EmployeeModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String position;
  final double salary;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.salary,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] is String
          ? int.parse(json['id'] as String)
          : json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      position: json['position'] as String,
      salary: (json['salary'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'position': position,
    'salary': salary,
  };

  Employee toEntity() => Employee(
    id: id,
    name: name,
    email: email,
    position: position,
    salary: salary,
  );

  factory EmployeeModel.fromEntity(Employee entity) => EmployeeModel(
    id: entity.id,
    name: entity.name,
    email: entity.email,
    position: entity.position,
    salary: entity.salary,
  );

  @override
  List<Object?> get props => [id, name, email, position, salary];
}
