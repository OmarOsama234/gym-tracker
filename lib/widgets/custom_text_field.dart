import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

/// Custom text field widget with professional styling
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? helperText;
  final bool showCounter;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.helperText,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: showCounter ? maxLength : null,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            helperText: helperText,
            counterText: showCounter ? null : '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultSpacing,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom numeric text field with specific formatting
class NumericTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool isDecimal;
  final double? min;
  final double? max;
  final Function(String)? onChanged;

  const NumericTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.isDecimal = false,
    this.min,
    this.max,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      validator: validator,
      onChanged: onChanged,
      inputFormatters: [
        if (isDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}