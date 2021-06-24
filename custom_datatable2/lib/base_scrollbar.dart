import 'package:flutter/material.dart';

class BaseScrollbar extends StatelessWidget {
  const BaseScrollbar({
    Key? key,
    required this.child,
    required this.controller,
    this.padding,
    this.enabled = true,
    this.isAlwaysShown = true,
  }) : super(key: key);
  final bool enabled;
  final Widget child;
  final ScrollController controller;
  final EdgeInsets? padding;
  final bool isAlwaysShown;
  @override
  Widget build(BuildContext context) {
    final Widget paddedChild = Padding(
      padding: padding ?? EdgeInsets.only(right: 16),
      child: child,
    );
    return enabled
        ? Scrollbar(
            controller: controller,
            radius: Radius.circular(4),
            thickness: 0,
            showTrackOnHover: false,
            isAlwaysShown: isAlwaysShown,
            child: paddedChild,
          )
        : paddedChild;
  }
}
