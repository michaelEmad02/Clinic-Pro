// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على منطق ترتيب قائمة الانتظار (Queue Sorter)
// يتم الترتيب برمجياً في التطبيق (Client-side) دون تخزينه في قاعدة البيانات
// ────────────────────────────────────────────────────────

class QueueSorter {
  /// ترتيب المواعيد بناءً على القواعد التالية:
  /// 1. المواعيد التي بدأت أو انتهت (in_progress, done) تبقى ثابتة في البداية بترتيب استدعائها (called_at).
  /// 2. الحالات الطارئة (is_urgent = true) تأتي أولاً في الانتظار.
  /// 3. بقية الحالات يتم ترتيبها بناءً على النمط المحدد للطبيب (doctor_queue_rules)
  ///    مثال للنمط: ["normal", "normal", "urgent"]
  /// 4. في حال عدم وجود نمط، يتم الترتيب حسب وقت الوصول (arrived_at) تصاعدياً.
  static List<Map<String, dynamic>> sort({
    required List<Map<String, dynamic>> appointments,
    List<String>? ruleSlots,
  }) {
    // 1. تصفية المواعيد الملغية أو التي لم تصل بعد
    final activeAppointments = appointments.where((appt) {
      final status = appt['status'] as String?;
      final arrivedAt = appt['arrived_at'];
      return arrivedAt != null && status != 'cancelled';
    }).toList();

    // 2. تقسيم المواعيد إلى: ثابتة (قيد الفحص حالياً) وقيد الانتظار
    final fixedAppointments = activeAppointments.where((appt) {
      final status = appt['status'] as String?;
      return status == 'in_progress';
    }).toList();

    final waitingAppointments = activeAppointments.where((appt) {
      final status = appt['status'] as String?;
      return status != 'in_progress' && status != 'done';
    }).toList();

    // ترتيب الثابتة بناءً على وقت الاستدعاء (called_at)
    fixedAppointments.sort((a, b) {
      final aCalled = a['called_at'] != null ? DateTime.parse(a['called_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0);
      final bCalled = b['called_at'] != null ? DateTime.parse(b['called_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0);
      return aCalled.compareTo(bCalled);
    });

    // 3. ترتيب المرضى المنتظرين
    final waitingSorted = <Map<String, dynamic>>[];

    // فصل الحالات الطارئة العاجلة (is_urgent == true)
    final urgentWaiting = waitingAppointments.where((appt) => appt['is_urgent'] == true).toList();
    // ترتيب الحالات العاجلة حسب وقت الوصول (arrived_at)
    urgentWaiting.sort((a, b) {
      final aArrived = DateTime.parse(a['arrived_at'] as String);
      final bArrived = DateTime.parse(b['arrived_at'] as String);
      return aArrived.compareTo(bArrived);
    });

    // المرضى المنتظرين العاديين
    final normalWaiting = waitingAppointments.where((appt) => appt['is_urgent'] != true).toList();
    normalWaiting.sort((a, b) {
      final aArrived = DateTime.parse(a['arrived_at'] as String);
      final bArrived = DateTime.parse(b['arrived_at'] as String);
      return aArrived.compareTo(bArrived);
    });

    // 4. تطبيق النمط (Doctor Queue Rules Pattern)
    if (ruleSlots != null && ruleSlots.isNotEmpty) {
      final cycleLength = ruleSlots.length;
      final startIndex = fixedAppointments.length;

      // نضع الحالات العاجلة جداً أولاً
      waitingSorted.addAll(urgentWaiting);

      // نقوم بتوزيع الحالات العادية حسب النمط المتاح
      // سنقوم بالمرور على الخانات المتاحة للانتظار وتعبئتها من قائمة الانتظار
      int normalIndex = 0;
      int slotOffset = 0;

      while (normalIndex < normalWaiting.length) {
        final currentSlotIndex = (startIndex + waitingSorted.length + slotOffset) % cycleLength;
        final expectedType = ruleSlots[currentSlotIndex]; // normal, urgent, revisit, consult

        // البحث عن أول موعد يطابق النوع المطلوب
        final matchIndex = normalWaiting.indexWhere((appt) {
          final typeName = appt['appointment_types']?['name'] as String? ?? '';
          return _mapTypeNameToSlotType(typeName) == expectedType;
        }, normalIndex);

        if (matchIndex != -1) {
          // وجدنا موعد مطابق للنمط، نسحبه ونضعه في الترتيب
          final matchedAppt = normalWaiting.removeAt(matchIndex);
          waitingSorted.add(matchedAppt);
        } else {
          // لم نجد نوع مطابق للخانة الحالية في النمط، نتجاوز الخانة وننتقل للخانة التالية
          slotOffset++;
          // إذا نفدت الخيارات ولم نتمكن من المطابقة، نقوم بإضافة المرضى المتبقين حسب ترتيب وصولهم لمنع الجمود (Starvation)
          if (slotOffset > cycleLength) {
            waitingSorted.addAll(normalWaiting);
            break;
          }
        }
      }
    } else {
      // إذا لم يكن هناك نمط محدد للطبيب، يتم الترتيب العادي: الحالات الطارئة أولاً ثم البقية حسب وقت الوصول
      waitingSorted.addAll(urgentWaiting);
      waitingSorted.addAll(normalWaiting);
    }

    return [...fixedAppointments, ...waitingSorted];
  }

  /// تحويل اسم نوع الموعد النصي للنوع المقابل له في نمط الترتيب
  static String _mapTypeNameToSlotType(String typeName) {
    typeName = typeName.toLowerCase();
    if (typeName.contains('طارئ') || typeName.contains('urgent') || typeName.contains('مستعجل')) {
      return 'urgent';
    }
    if (typeName.contains('إعادة') || typeName.contains('revisit') || typeName.contains('مراجعة')) {
      return 'revisit';
    }
    if (typeName.contains('استشارة') || typeName.contains('consult')) {
      return 'consult';
    }
    return 'normal';
  }
}
