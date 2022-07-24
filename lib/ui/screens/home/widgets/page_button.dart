import 'package:flutter/material.dart';

class PageButton extends StatelessWidget {
  const PageButton({required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        width: MediaQuery.of(context).size.width / 1.5,
        margin: const EdgeInsets.only(bottom: 15),
        height: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black45),
            borderRadius: const BorderRadius.all(Radius.circular(30))),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 21, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
