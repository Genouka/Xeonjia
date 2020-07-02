import 'package:flutter/material.dart';

import 'package:xeonjia/ui/basic.dart';

class PageButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  PageButton({@required this.title, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      width: MediaQuery.of(context).size.width / 1.5,
      height: 50,
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black45),
          borderRadius: circularRadius),
      child: FlatButton(
        shape: const RoundedRectangleBorder(borderRadius: circularRadius),
        child: Text(title,
            style: const TextStyle(color: Colors.black, fontSize: 21)),
        onPressed: onPressed,
      ),
    );
  }
}
