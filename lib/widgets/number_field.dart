import 'package:flutter/material.dart';
import '../app_theme.dart';

class NumberField extends StatefulWidget {
  final String label;
  final Map<String, dynamic> model;
  final String keyName;
  const NumberField({
    super.key,
    required this.label,
    required this.model,
    required this.keyName,
  });

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.model[widget.keyName].toString());
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.model[widget.keyName].toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (v) {
        widget.model[widget.keyName] = int.tryParse(v) ?? 0;
      },
    );
  }
}
