import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String fontFamily;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPaddingActive;
  final FloatingLabelBehavior floatingLabelBehavior;
  final double labelFontSize;

  const AuthTextField(
      {super.key,
      required this.controller,
      required this.focusNode,
      this.label,
      this.fontFamily = 'Poppins',
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.isPaddingActive = true,
      this.floatingLabelBehavior = FloatingLabelBehavior.never,
      this.labelFontSize = 12.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isPaddingActive == true ? 20.0 : 0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(
          fontSize: 16.0,
          decoration: TextDecoration.none,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey,
            fontFamily: fontFamily,
            fontSize: labelFontSize,
          ),
          floatingLabelBehavior: floatingLabelBehavior,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        cursorColor: Theme.of(context).colorScheme.onSurface,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
