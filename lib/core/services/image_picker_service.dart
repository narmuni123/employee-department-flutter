import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as ip;

import '../error/app_exception.dart';

enum ImageSource { camera, gallery }

abstract class ImagePickerService {
  Future<Either<AppException, File?>> pickImage(ImageSource source);
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ip.ImagePicker _imagePicker;

  ImagePickerServiceImpl({ip.ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ip.ImagePicker();

  @override
  Future<Either<AppException, File?>> pickImage(ImageSource source) async {
    try {
      final ipSource = _convertImageSource(source);

      final ip.XFile? pickedFile = await _imagePicker.pickImage(
        source: ipSource,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return const Right(null);
      }

      final file = File(pickedFile.path);
      return Right(file);
    } on PlatformException catch (e) {
      return Left(_handlePlatformException(e, source));
    } on Exception catch (e) {
      return Left(
        ServerException(500, 'Failed to pick image: ${e.toString()}'),
      );
    }
  }

  ip.ImageSource _convertImageSource(ImageSource source) {
    return switch (source) {
      ImageSource.camera => ip.ImageSource.camera,
      ImageSource.gallery => ip.ImageSource.gallery,
    };
  }

  AppException _handlePlatformException(
    PlatformException e,
    ImageSource source,
  ) {
    final code = e.code;

    if (code == 'camera_access_denied' ||
        code == 'photo_access_denied' ||
        code.contains('permission') ||
        code.contains('denied')) {
      return ServerException(403, _getPermissionDeniedMessage(code, source));
    }

    if (code == 'invalid_source') {
      return ServerException(
        400,
        e.message ??
            'Invalid image source. Camera may not be available on this device.',
      );
    }

    return ServerException(500, e.message ?? 'Failed to pick image');
  }

  String _getPermissionDeniedMessage(String errorCode, ImageSource source) {
    if (errorCode == 'camera_access_denied' || source == ImageSource.camera) {
      return 'Camera access denied. Please grant camera permission in your device settings to capture photos.';
    } else if (errorCode == 'photo_access_denied' ||
        source == ImageSource.gallery) {
      return 'Photo library access denied. Please grant photo library permission in your device settings to select images.';
    }
    return 'Permission denied. Please grant the required permission in your device settings.';
  }
}

class MockImagePickerService implements ImagePickerService {
  File? mockFile;
  bool simulateCancellation = false;
  bool simulatePermissionDenied = false;
  ImageSource? deniedSource;
  bool simulateError = false;
  String errorMessage = 'Mock error occurred';
  ImageSource? lastPickedSource;

  @override
  Future<Either<AppException, File?>> pickImage(ImageSource source) async {
    lastPickedSource = source;
    await Future.delayed(const Duration(milliseconds: 100));

    if (simulatePermissionDenied) {
      final message = source == ImageSource.camera
          ? 'Camera access denied. Please grant camera permission in your device settings to capture photos.'
          : 'Photo library access denied. Please grant photo library permission in your device settings to select images.';
      return Left(ServerException(403, message));
    }

    if (simulateError) {
      return Left(ServerException(500, errorMessage));
    }

    if (simulateCancellation) {
      return const Right(null);
    }

    return Right(mockFile);
  }

  void reset() {
    mockFile = null;
    simulateCancellation = false;
    simulatePermissionDenied = false;
    deniedSource = null;
    simulateError = false;
    errorMessage = 'Mock error occurred';
    lastPickedSource = null;
  }
}
