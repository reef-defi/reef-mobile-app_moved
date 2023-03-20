import 'package:flutter/material.dart';

class MaxAmountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MaxAmountButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(30, 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        "Max",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 12,
        ),
      ),
    );
  }
}
