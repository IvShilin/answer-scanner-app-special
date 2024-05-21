import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../constants/types.dart';

class MainButton extends StatelessWidget {
  final Widget title;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final UIApplicationType type;
  final double height;
  final double width;
  const MainButton({
    required this.title,
    required this.onPressed,
    required this.type,
    this.onLongPress,
    this.height = 70,
    this.width = double.infinity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        type == UIApplicationType.disabled ? UIApplicationColors.yMidGrey : Colors.black;
    final onPress = type == UIApplicationType.disabled ? null : onPressed;
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPress,
        onLongPress: onLongPress,
        child: title,
        style: ButtonStyle(
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
          backgroundColor:
              MaterialStateProperty.all(type.resolveColor(context)),
          foregroundColor: MaterialStateProperty.all(foregroundColor),
          overlayColor: MaterialStateProperty.all(
            Color.lerp(type.resolveColor(context), Colors.white, 0.2),
          ),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
        ),
      ),
    );
  }
}
