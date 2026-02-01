import 'dart:io';

import 'package:equatable/equatable.dart';

enum ImagePickerStatus { initial, picking, success, error, cancelled }

class ImagePickerState extends Equatable {
  final ImagePickerStatus status;
  final File? selectedImage;
  final String? errorMessage;

  const ImagePickerState({
    this.status = ImagePickerStatus.initial,
    this.selectedImage,
    this.errorMessage,
  });

  bool get isPicking => status == ImagePickerStatus.picking;
  bool get hasImage => selectedImage != null;
  bool get hasError => status == ImagePickerStatus.error;
  bool get wasCancelled => status == ImagePickerStatus.cancelled;

  ImagePickerState copyWith({
    ImagePickerStatus? status,
    File? Function()? selectedImage,
    String? Function()? errorMessage,
  }) {
    return ImagePickerState(
      status: status ?? this.status,
      selectedImage: selectedImage != null
          ? selectedImage()
          : this.selectedImage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedImage?.path, errorMessage];
}
