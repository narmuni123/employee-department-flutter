import 'package:equatable/equatable.dart';

class AddDepartmentState extends Equatable {
  final String id;
  final String name;
  final String location;
  final String? idError;
  final String? nameError;
  final String? locationError;
  final String? apiError;
  final bool isSubmitting;
  final bool isSuccess;
  final String? successMessage;

  const AddDepartmentState({
    this.id = '',
    this.name = '',
    this.location = '',
    this.idError,
    this.nameError,
    this.locationError,
    this.apiError,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.successMessage,
  });

  AddDepartmentState copyWith({
    String? id,
    String? name,
    String? location,
    String? idError,
    String? nameError,
    String? locationError,
    String? apiError,
    bool? isSubmitting,
    bool? isSuccess,
    String? successMessage,
  }) {
    return AddDepartmentState(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      idError: idError,
      nameError: nameError,
      locationError: locationError,
      apiError: apiError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  bool get isValid =>
      id.isNotEmpty &&
      name.isNotEmpty &&
      location.isNotEmpty &&
      idError == null &&
      nameError == null &&
      locationError == null;

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    idError,
    nameError,
    locationError,
    apiError,
    isSubmitting,
    isSuccess,
    successMessage,
  ];
}
