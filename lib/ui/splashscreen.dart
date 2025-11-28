// lib/ui/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  const SplashScreen({super.key, this.duration = const Duration(milliseconds: 3000)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  late final Animation<Offset> _leftTextSlide;
  late final Animation<Offset> _rightTextSlide;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.40, curve: Curves.easeIn)),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack)),
    );

    _leftTextSlide = Tween<Offset>(begin: const Offset(-1.8, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)),
    );

    _rightTextSlide = Tween<Offset>(begin: const Offset(1.8, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic)),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 0.90, curve: Curves.easeIn)),
    );

    _ctrl.forward();

    Timer(widget.duration + const Duration(milliseconds: 200), _goNext);
  }

  void _goNext() {
    debugPrint('[Splash] animation done, goNext called. Navigating to /login for debug.');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final logoSize = (width * 0.26).clamp(80.0, 180.0);

    final textStyleLeft = TextStyle(
      fontSize: (logoSize * 0.26).clamp(18.0, 32.0),
      color: Colors.red,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
    );

    final textStyleRight = TextStyle(
      fontSize: (logoSize * 0.26).clamp(18.0, 32.0),
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          size: logoSize * 0.56,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Opacity(
                    opacity: _textFade.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _leftTextSlide,
                          child: Text("d'JAWA ", style: textStyleLeft),
                        ),
                        SlideTransition(
                          position: _rightTextSlide,
                          child: Text("BUS", style: textStyleRight),
                        ),
                      ],
                    ),
                  ),

                  // ← loading bar sudah DIHAPUS untuk tampilan clean
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
