import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/image_picker/image_picker_cubit.dart';
import '../bloc/image_picker/image_picker_state.dart';
import '../widgets/loading_indicator.dart';

class ImagePickerScreen extends StatelessWidget {
  const ImagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image'),
        centerTitle: true,
        actions: [
          BlocBuilder<ImagePickerCubit, ImagePickerState>(
            builder: (context, state) {
              if (state.hasImage) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear image',
                  onPressed: () {
                    context.read<ImagePickerCubit>().clearImage();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ImagePickerCubit, ImagePickerState>(
        listener: (context, state) {
          if (state.wasCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image selection cancelled'),
                duration: Duration(seconds: 2),
              ),
            );
            context.read<ImagePickerCubit>().resetStatus();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildImagePreview(context, state)),
                if (state.hasError && state.errorMessage != null)
                  _buildErrorMessage(context, state.errorMessage!),
                _buildSourceSelectionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, ImagePickerState state) {
    if (state.isPicking) {
      return const LoadingIndicator(message: 'Opening...');
    }

    if (state.hasImage) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            state.selectedImage!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(
                context,
                icon: Icons.broken_image_outlined,
                message: 'Failed to load image',
              );
            },
          ),
        ),
      );
    }

    return _buildPlaceholder(
      context,
      icon: Icons.add_photo_alternate_outlined,
      message: 'No image selected\nTap a button below to select an image',
    );
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () {
              context.read<ImagePickerCubit>().resetStatus();
            },
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelectionButtons(
    BuildContext context,
    ImagePickerState state,
  ) {
    final isEnabled = !state.isPicking;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Image Source',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSourceButton(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onPressed: isEnabled
                      ? () => context.read<ImagePickerCubit>().pickFromCamera()
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSourceButton(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onPressed: isEnabled
                      ? () => context.read<ImagePickerCubit>().pickFromGallery()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final void Function(File image)? onImageSelected;
  final VoidCallback? onImageCleared;
  final double previewHeight;

  const ImagePickerWidget({
    super.key,
    this.onImageSelected,
    this.onImageCleared,
    this.previewHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImagePickerCubit, ImagePickerState>(
      listener: (context, state) {
        if (state.status == ImagePickerStatus.success && state.hasImage) {
          onImageSelected?.call(state.selectedImage!);
        }

        if (state.wasCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selection cancelled'),
              duration: Duration(seconds: 2),
            ),
          );
          context.read<ImagePickerCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: previewHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: _buildPreviewContent(context, state),
            ),

            if (state.hasError && state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isPicking
                        ? null
                        : () =>
                              context.read<ImagePickerCubit>().pickFromCamera(),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isPicking
                        ? null
                        : () => context
                              .read<ImagePickerCubit>()
                              .pickFromGallery(),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreviewContent(BuildContext context, ImagePickerState state) {
    if (state.isPicking) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.file(
              state.selectedImage!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.read<ImagePickerCubit>().clearImage();
                  onImageCleared?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select an image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
