// ignore_for_file: library_private_types_in_public_api

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // full white bg
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,   // keep header left-aligned on all platforms
          titleSpacing: 0,      // avoid double spacing; we'll add our own padding
          toolbarHeight: 72,
          title: Builder(
            builder: (context) {
              final w = MediaQuery.of(context).size.width;
              return Padding(
                padding: EdgeInsets.only(left: w * 0.05), // ~5px on 400px wide phones
                child: const _HeaderTitle(),
              );
            },
          ),
          actions: const [_CloseBtn()],
        ),
        body: const SafeArea(child: TicketPage()),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left-aligned header
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'CTtransit',
          style: TextStyle(
            color: Color(0xFF3C4043),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Show operator your ticket',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3C4043),
          ),
        ),
      ],
    );
  }
}

class _CloseBtn extends StatelessWidget {
  const _CloseBtn();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with TickerProviderStateMixin {
  late String _formattedTime;
  late String _formattedDateAndTime;

  // Animations
  late final AnimationController _outerCtrl; // outer: 1.00s
  late final AnimationController _innerCtrl; // inner: 0.78s, 0.51s delay
  late final Animation<double> _outerAnim;
  late final Animation<double> _innerAnim;

  // Timing (CSS-like)
  static const int kOuterMs = 1000;
  static const int kInnerMs = 780;
  static const int kDelayMs = 510;

  // Scales (CSS-like, subtle; inner capped at 1.00)
  static const double kOuterBegin = 0.92;
  static const double kOuterEnd   = 1.17; // updated
  static const double kInnerBegin = 0.90;
  static const double kInnerEnd   = 1.00;

  // Colors
  // CT Transit Green
 static const Color kOuterColor = Color(0xFF00A86B); // main green
 static const Color kRingColor  = Color(0xFF009966); // slightly darker ring


  @override
  void initState() {
    super.initState();
    _tickTime();

    _outerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kOuterMs),
    )..repeat(reverse: true);
    _outerAnim = CurvedAnimation(parent: _outerCtrl, curve: Curves.easeInOut);

    _innerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kInnerMs),
    );
    Future.delayed(const Duration(milliseconds: kDelayMs), () {
      if (mounted) _innerCtrl.repeat(reverse: true);
    });
    _innerAnim = CurvedAnimation(parent: _innerCtrl, curve: Curves.easeInOut);
  }

  void _tickTime() {
    _formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
    _formattedDateAndTime =
        DateFormat('MMM dd, yyyy, h:mm a').format(DateTime.now().add(const Duration(hours: 2)));
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(_tickTime);
    });
  }

  @override
  void dispose() {
    _outerCtrl.dispose();
    _innerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap content in a centered, fixed max width so it's truly centered on iOS/Web
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep content centered within a reasonable width (looks centered everywhere)
        final double maxContentWidth = math.min(constraints.maxWidth, 520);

        final w = math.min(constraints.maxWidth, maxContentWidth);
        double badgeSize = w * 0.36;
        badgeSize = math.max(180, math.min(320, badgeSize));

        // Proportional geometry based on CSS 240px design
        final double ringMargin  = badgeSize * (32 / 240);
        final double whiteMargin = badgeSize * (48 / 240);
        final double ringWidth   = badgeSize * (24 / 240);

        return Align(
          alignment: Alignment.topCenter, // horizontally center the whole column
          child: SizedBox(
            width: maxContentWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center, // center inner children
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.11),

                // Badge
                PulseBadge(
                  size: badgeSize,
                  outerAnim: _outerAnim,
                  innerAnim: _innerAnim,
                  outerColor: kOuterColor,
                  ringColor: kRingColor,
                  ringWidth: ringWidth,
                  ringMargin: ringMargin,
                  whiteMargin: whiteMargin,
                  logoPath: 'assets/images/logo_3.png',
                  logoScale: 0.75,
                  outerBegin: kOuterBegin,
                  outerEnd: kOuterEnd,
                  innerBegin: kInnerBegin,
                  innerEnd: kInnerEnd,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.12),

                // Time (centered)
                Text(
                  _formattedTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.155,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3C4043),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                // Ticket info card (centered because it lives inside the centered SizedBox)
                Container(
                  // no big side-margins; width is centered by parent SizedBox
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                    horizontal: w * 0.05,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // keep text left within the card
                    children: [
                      Text(
                        'Adult 2 Hour - Local Service',
                        style: TextStyle(
                          fontSize: w * 0.062,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3C4043),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text(
                        'Hartford, New Haven, Stamford, Bristol, Meriden,\nNew Britain, Wallingford, and Waterbury',
                        style: TextStyle(
                          fontSize: w * 0.034,
                          color: const Color(0xFF5F6267),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      Text(
                        "Expires $_formattedDateAndTime",
                        style: TextStyle(
                          fontSize: w * 0.042,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF626569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PulseBadge extends StatelessWidget {
  final double size;                 // overall diameter
  final Animation<double> outerAnim; // outer pulse controller
  final Animation<double> innerAnim; // inner pulse controller
  final Color outerColor;            // filled outer circle color
  final Color ringColor;             // ring stroke color
  final double ringWidth;            // ring stroke width (responsive)
  final double ringMargin;           // responsive
  final double whiteMargin;          // responsive
  final String logoPath;             // asset path
  final double logoScale;            // fraction of white circle diameter
  final double outerBegin, outerEnd; // scale range for outer
  final double innerBegin, innerEnd; // scale range for inner

  const PulseBadge({
    super.key,
    required this.size,
    required this.outerAnim,
    required this.innerAnim,
    required this.outerColor,
    required this.ringColor,
    required this.ringWidth,
    required this.ringMargin,
    required this.whiteMargin,
    required this.logoPath,
    this.logoScale = 0.75,
    this.outerBegin = 0.92,
    this.outerEnd = 1.08,
    this.innerBegin = 0.90,
    this.innerEnd = 1.00,
  });

  @override
  Widget build(BuildContext context) {
    final outerScale = Tween(begin: outerBegin, end: outerEnd).animate(outerAnim);
    final innerScale = Tween(begin: innerBegin, end: innerEnd).animate(innerAnim);

    final double whiteDiameter = size - (whiteMargin * 2);
    final double logoSize = whiteDiameter * logoScale;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1) Outer filled circle (pulsing)
          ScaleTransition(
            scale: outerScale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: outerColor.withOpacity(0.95),
              ),
            ),
          ),
          // 2) Inner thick ring (pulsing)
          ScaleTransition(
            scale: innerScale,
            child: Container(
              margin: EdgeInsets.all(ringMargin),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: ringWidth),
              ),
            ),
          ),
          // 3) White inner disk (mask)
          Container(
            margin: EdgeInsets.all(whiteMargin),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // 4) Logo on top
          Image.asset(
            logoPath,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
