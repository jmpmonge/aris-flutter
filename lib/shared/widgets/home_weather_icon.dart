import 'package:flutter/cupertino.dart';

/// Icono clima Home — solo sol amarillo (Cupertino / SF style).
class HomeWeatherIcon extends StatelessWidget {
  const HomeWeatherIcon({
    super.key,
    required this.size,
    required this.sunColor,
  });

  final double size;
  final Color sunColor;

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.sun_max,
      size: size,
      color: sunColor,
    );
  }
}
