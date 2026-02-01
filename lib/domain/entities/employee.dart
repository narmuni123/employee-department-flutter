import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final int id;
  final String name;
  final String email;
  final String position;
  final double salary;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.salary,
  });

  @override
  List<Object?> get props => [id, name, email, position, salary];
}
