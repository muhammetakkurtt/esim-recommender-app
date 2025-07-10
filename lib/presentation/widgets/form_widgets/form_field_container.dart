import 'package:flutter/material.dart';
import '../../utils/styles/form_styles.dart';

/// Standard container that wraps all form fields
class FormFieldContainer extends StatelessWidget {
  final Widget child;
  final double bottomMargin;
  final BoxDecoration? decoration;
  
  const FormFieldContainer({
    super.key,
    required this.child,
    this.bottomMargin = 24.0,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: decoration ?? FormStyles.formFieldContainerDecoration,
      child: child,
    );
  }
} 