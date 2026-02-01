import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool autofocus;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.errorText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          autofocus: autofocus,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceContainerHighest,
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
