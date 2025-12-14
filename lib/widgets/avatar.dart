import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double radius;
  // final ImageProvider? backgroundImage;
  final String url;
  final Color backgroundColor;
  

  const Avatar({
    Key? key,
    this.radius = 20.0,
    required this.url,
    this.backgroundColor = const Color.fromARGB(255, 202, 202, 202),
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return url == ""? Icon(
      Icons.account_circle,
      size: radius * 2,
      color: backgroundColor,
    ) : CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
      backgroundColor: backgroundColor,
      
    );
  }

}