import 'package:flutter/cupertino.dart';

/// Clima Home: nube Cupertino + sol amarillo asomado (v0.48.45).
class HomeWeatherIcon extends StatelessWidget {
  const HomeWeatherIcon({
    super.key,
    required this.size,
    required this.cloudColor,
    required this.sunColor,
  });

  final double size;
  final Color cloudColor;
  final Color sunColor;

  @override
  Widget build(BuildContext context) {
    final sunSize = size * 0.5;
    final cloudSize = size * 0.9;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomLeft,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              CupertinoIcons.sun_max_fill,
              size: sunSize,
              color: sunColor,
            ),
          ),
          Icon(
            CupertinoIcons.cloud,
            size: cloudSize,
            color: cloudColor,
          ),
        ],
      ),
    );
  }
}
