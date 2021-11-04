import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Color> _colors = [
  Color(0XFF060761),
  Color(0XFF050437),
  Color(0XFFC54A85),
  Color(0XFF113BC6),
  Color(0XFF141518),
  // Color(0XFF903843),
  // Color(0XFFFF664B),
  // Color(0XFFFFE17C),
  // Color(0XFFFFFCAF),
  // Color(0XFFCE2029),
];
void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation, _rocketAnimation, _rocketOpacity, _textAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..forward();
    _animationController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 2));
          _animationController.forward(from: 0.0);
        }
      },
    );

    _animation = CurvedAnimation(
        curve: const Interval(0.4,1), parent: _animationController);
    _textAnimation = CurvedAnimation(
        curve: const Interval(0.8, 1), parent: _animationController);

    super.initState();
  }

  final List<Particles> _particles = List.generate(
    20000,
    (index) {
      final size = Random().nextDouble() * 2;
      final speed = Random().nextInt(150) * 1.0;

      final angle = Random().nextInt(360) * 1.0;
      final color = _colors[index % _colors.length];
      return Particles(
        color: color,
        size: size,
        speed: speed,
        angle: angle,
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    _rocketAnimation =
        Tween<Offset>(begin: Offset(0, height + 50), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController, curve: const Interval(0.0, 0.4)));
    _rocketOpacity = CurvedAnimation(
        parent: _animationController, curve: const Interval(0.0, 0.4));
    return Scaffold(
      backgroundColor: const Color(0XFF141518),
      body: SafeArea(
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, snapshot) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 1 - _animationController.value.clamp(0.5, 1),
                    child: CustomPaint(
                      painter: FireWork(
                          particles: _particles, value: _animation.value),
                      size: const Size(400, 400),
                    ),
                  ),
                  Text("Happy Diwali",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.greatVibes(
                          fontSize: _textAnimation.value * 50,
                          color: Colors.white)),
                  Transform.translate(
                    offset: _rocketAnimation.value,
                    child: Opacity(
                      opacity: 1.0 - _rocketOpacity.value,
                      child: Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Colors.white,
                          Colors.red,
                        ])),
                        height: 60,
                        width: 5,
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}

class FireWork extends CustomPainter {
  final List<Particles> particles;
  final double value;
  FireWork({required this.particles, required this.value});
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      //Center
      final _center = Offset(size.width / 2, size.height / 2);
      //XPoint  
      final xPoint = _center.dx +
          cos(angleToRadian(particle.angle)) *
              ((value * size.width / 2) - ((value) * particle.speed));

      //YPoint
      final yPoint = _center.dx +
          sin(angleToRadian(particle.angle)) *
              ((value * size.width / 2) - ((value) * particle.speed));
      //Offset on Cnavas
      final _offSet = Offset(xPoint, yPoint);

      //drawing Circles of the different sizes
      canvas.drawCircle(
          _offSet, particle.size, Paint()..color = particle.color);
    }
  }

  double angleToRadian(double angle) {
    return angle * (180 / 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particles {
  final Color color;
  final double size;
  final double speed;

  final double angle;
  Particles(
      {required this.color,
      required this.size,
      required this.speed,
      required this.angle});
}
