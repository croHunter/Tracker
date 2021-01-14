import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[300], width: 5),
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: NetworkImage(
                'https://flutter.io/images/catalog-widget-placeholder.png'),
          ),
        ),
        child: Container(
          height: 125.0,
          width: 125.0,
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            backgroundBlendMode: BlendMode.exclusion,
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
