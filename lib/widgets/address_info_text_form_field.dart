import 'package:flutter/material.dart';

class InfoTextFormField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final bool enabled;

  InfoTextFormField({this.hint, this.label, this.controller, this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Theme(
        data: ThemeData(primarySwatch: Colors.orange),
        child: TextFormField(
          enabled: enabled,
          controller: controller,
          decoration: InputDecoration(
              hintText: 'Örn. $hint',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              labelText: label),
          validator: (value) {
            if (value.isEmpty) {
              return 'Lütfen boş bırakmayınız !';
            }
            return null;
          },
        ),
      ),
    );
  }
}
