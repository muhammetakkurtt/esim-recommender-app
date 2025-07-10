import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../form_widgets/form_field_container.dart';
import '../../utils/styles/form_styles.dart';

/// Standard text input field widget
class TextInputField extends StatelessWidget {
  /// Form field name
  final String name;
  
  /// Field label
  final String label;
  
  /// Prefix icon
  final IconData prefixIcon;
  
  /// Suffix icon (optional)
  final IconData? suffixIcon;
  
  /// Keyboard type
  final TextInputType keyboardType;
  
  /// Next field focus
  final TextInputAction textInputAction;
  
  /// Value validators
  final List<FormFieldValidator<String>> validators;
  
  /// Minimum value (for numeric fields)
  final double? minValue;
  
  /// Maximum value (for numeric fields)
  final double? maxValue;
  
  /// Initial value
  final String? initialValue;
  
  /// Function to be called when value changes
  final Function(String?)? onChanged;

  const TextInputField({
    super.key,
    required this.name,
    required this.label,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validators = const [],
    this.minValue,
    this.maxValue,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Combine all validators
    final List<FormFieldValidator<String>> allValidators = [
      FormBuilderValidators.required(errorText: '${label} field is required'),
      ...validators,
    ];
    
    // Additional validators for numeric fields
    if (keyboardType == TextInputType.number) {
      allValidators.add(FormBuilderValidators.numeric(errorText: 'Please enter numbers only'));
      
      if (minValue != null) {
        allValidators.add(FormBuilderValidators.min(minValue!, 
            errorText: 'Must be at least ${minValue!}'));
      }
      
      if (maxValue != null) {
        allValidators.add(FormBuilderValidators.max(maxValue!, 
            errorText: 'Must be at most ${maxValue!}'));
      }
    }

    return FormFieldContainer(
      child: FormBuilderTextField(
        name: name,
        initialValue: initialValue,
        decoration: FormStyles.inputDecoration(
          labelText: label,
          prefixIconData: prefixIcon,
          suffixIconData: suffixIcon,
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: FormBuilderValidators.compose(allValidators),
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
          
          // Haptic feedback
          HapticFeedback.selectionClick();
        },
      ),
    );
  }
  
  /// Factory constructor to create a numeric input field
  factory TextInputField.number({
    required String name,
    required String label,
    required IconData prefixIcon,
    IconData? suffixIcon,
    TextInputAction textInputAction = TextInputAction.next,
    double? minValue,
    double? maxValue,
    String? initialValue,
    Function(String?)? onChanged,
  }) {
    return TextInputField(
      name: name,
      label: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      minValue: minValue,
      maxValue: maxValue,
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }
} 