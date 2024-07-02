import 'package:flutter/cupertino.dart';

class HeartAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback onEnd;
  const HeartAnimationWidget(
      {super.key,
      required this.child,
      required this.isAnimating,
      required this.duration,
      required this.onEnd});

  @override
  State<HeartAnimationWidget> createState() => _HeartAnimationWidgetState();
}

class _HeartAnimationWidgetState extends State<HeartAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    final halfDuration = widget.duration.inMilliseconds ~/ 2;
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: halfDuration));

    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(HeartAnimationWidget oldwidget) {
    super.didUpdateWidget(oldwidget);
    if (widget.isAnimating != oldwidget.isAnimating) {
      doAnimation();
    }
  }

  Future doAnimation() async {
    await controller.forward();
    await controller.reverse();

    widget.onEnd();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
