// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن رسم الشعارات الرسمية لمزودي الذكاء الاصطناعي
// تم رسمها بدقة كمتجهات (Vector CustomPainter) لضمان أعلى جودة بصرية
// ────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AiProviderLogo extends StatelessWidget {
  final AiProviderType provider;
  final double size;

  const AiProviderLogo({
    super.key,
    required this.provider,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    switch (provider) {
      case AiProviderType.openai:
        return _buildOpenAiLogo();
      case AiProviderType.claude:
        return _buildClaudeLogo();
      case AiProviderType.gemini:
        return _buildGeminiLogo();
      case AiProviderType.deepseek:
        return _buildDeepSeekLogo();
      case AiProviderType.groq:
        return _buildGroqLogo();
      case AiProviderType.qwen:
        return _buildQwenLogo();
      case AiProviderType.gimi:
        return _buildGimiLogo();
      case AiProviderType.custom:
        return _buildCustomLogo();
    }
  }

  // 1. OpenAI — الشعار الرسمي (الأخضر الزمردي #10A37F)
  Widget _buildOpenAiLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF10A37F).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Icon(
          TablerIcons.brand_openai,
          size: size * 0.72,
          color: const Color(0xFF10A37F),
        ),
      ),
    );
  }

  // 2. Claude (Anthropic) — شعار شمس/نجمة أنثروبيك المتشعبة الرسمية (#CC785C)
  Widget _buildClaudeLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.68, size * 0.68),
          painter: const _ClaudeSunburstPainter(color: Color(0xFFCC785C)),
        ),
      ),
    );
  }

  // 3. Google Gemini — نجمة الجيمني الرباعية المنحنية الرسمية مع تدرج جوجل
  Widget _buildGeminiLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.7, size * 0.7),
          painter: const _GeminiStarPainter(),
        ),
      ),
    );
  }

  // 4. DeepSeek — شعار حوت ديب سيك الأزرق الرسمي (#0066FF)
  Widget _buildDeepSeekLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0066FF).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.72, size * 0.72),
          painter: const _DeepSeekWhalePainter(color: Color(0xFF0066FF)),
        ),
      ),
    );
  }

  // 5. Groq — شعار Groq الهندسي البرتقالي السريع (#F55036)
  Widget _buildGroqLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF55036).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.68, size * 0.68),
          painter: const _GroqLogoPainter(color: Color(0xFFF55036)),
        ),
      ),
    );
  }

  // 6. Qwen — شعار الحلقة المتداخلة السحابية لـ Alibaba Qwen (#7C3AED)
  Widget _buildQwenLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.68, size * 0.68),
          painter: const _QwenRingPainter(color: Color(0xFF7C3AED)),
        ),
      ),
    );
  }

  // 7. Gimi — مساعد الذكاء الاصطناعي الطبي (#9333EA)
  Widget _buildGimiLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF9333EA).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Icon(
          Icons.smart_toy_outlined,
          size: size * 0.68,
          color: const Color(0xFF9333EA),
        ),
      ),
    );
  }

  // 8. Custom Base URL — سيرفر أو مزود مخصص (#64748B)
  Widget _buildCustomLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF64748B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Icon(
          Icons.dns_outlined,
          size: size * 0.65,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// الرسامون المخصصون للشعارات الرسمية (Vector Painters)
// ────────────────────────────────────────────────────────

/// رسام شمس أنثروبيك الرسمية لـ Claude
class _ClaudeSunburstPainter extends CustomPainter {
  final Color color;
  const _ClaudeSunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const int rays = 14;

    for (int i = 0; i < rays; i++) {
      final angle = (i * 2 * math.pi) / rays;
      final rayLength = i.isEven ? radius : radius * 0.72;
      final width = (math.pi * radius / rays) * 0.55;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final rRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -rayLength * 0.55),
          width: width,
          height: rayLength * 0.85,
        ),
        Radius.circular(width / 2),
      );
      canvas.drawRRect(rRect, paint);
      canvas.restore();
    }

    // دائرة المنتصف
    canvas.drawCircle(center, radius * 0.28, paint);
  }

  @override
  bool shouldRepaint(covariant _ClaudeSunburstPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// رسام نجمة Google Gemini الرسمية المنحنية بتدرج الألوان الأصلي
class _GeminiStarPainter extends CustomPainter {
  const _GeminiStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2563EB), // Blue
        Color(0xFF9333EA), // Violet
        Color(0xFFE11D48), // Pink
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // شكل نجمة الجيمني الرباعية ذات الأقواس المقعرة الدقيقة
    final path = Path();
    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// رسام حوت DeepSeek الرسمي الأزرق
class _DeepSeekWhalePainter extends CustomPainter {
  final Color color;
  const _DeepSeekWhalePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // مسار حوت DeepSeek الموجه للأمام
    final path = Path();
    path.moveTo(w * 0.15, h * 0.55);
    // منحنى الرأس الدائري الضخم
    path.cubicTo(w * 0.15, h * 0.25, w * 0.55, h * 0.15, w * 0.82, h * 0.35);
    // منحنى الظهر والذيل الصاعد
    path.cubicTo(w * 0.95, h * 0.45, w * 0.98, h * 0.3, w * 0.95, h * 0.22);
    path.cubicTo(w * 0.92, h * 0.2, w * 0.88, h * 0.3, w * 0.78, h * 0.48);
    // بطن الحوت السفلي
    path.cubicTo(w * 0.6, h * 0.78, w * 0.28, h * 0.82, w * 0.15, h * 0.55);
    path.close();

    canvas.drawPath(path, paint);

    // عين الحوت
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.38, h * 0.38), w * 0.05, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _DeepSeekWhalePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// رسام شعار Groq الهندسي السريع البرتقالي
class _GroqLogoPainter extends CustomPainter {
  final Color color;
  const _GroqLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // شكل حرف g المنحني الهندسي السريع الخاص بـ Groq
    final path = Path();
    path.moveTo(w * 0.8, h * 0.25);
    path.quadraticBezierTo(w * 0.25, h * 0.15, w * 0.25, h * 0.5);
    path.quadraticBezierTo(w * 0.25, h * 0.85, w * 0.75, h * 0.85);
    path.lineTo(w * 0.75, h * 0.48);
    path.lineTo(w * 0.48, h * 0.48);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GroqLogoPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// رسام حلقة Alibaba Qwen السحابية الرسمية
class _QwenRingPainter extends CustomPainter {
  final Color color;
  const _QwenRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;

    canvas.drawCircle(Offset(cx, cy), r, paint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + r, cy), size.width * 0.12, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _QwenRingPainter oldDelegate) =>
      color != oldDelegate.color;
}
