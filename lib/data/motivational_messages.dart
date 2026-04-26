/// Motivational Messages
/// Dynamic Arabic messages for different contexts
class MotivationalMessages {
  /// Get context-appropriate motivational message
  static String getMessage({
    required MessageContext context,
    int streak = 0,
    bool isUrge = false,
  }) {
    List<String> messages;

    switch (context) {
      case MessageContext.morning:
        messages = _morningMessages;
        break;
      case MessageContext.evening:
        messages = _eveningMessages;
        break;
      case MessageContext.urge:
        messages = _urgeMessages;
        break;
      case MessageContext.relapse:
        messages = _relapseMessages;
        break;
      case MessageContext.milestone:
        messages = _getMilestoneMessages(streak);
        break;
      case MessageContext.general:
        messages = _generalMessages;
        break;
    }

    // Return a semi-random message (based on streak to avoid repetition)
    final index = (streak + DateTime.now().hour) % messages.length;
    return messages[index];
  }

  // ========================================
  // MORNING MESSAGES
  // ========================================
  static const List<String> _morningMessages = [
    'صباح الخير! يوم جديد، فرصة جديدة للنصر',
    'ابدأ يومك بالقوة والعزيمة',
    'أنت أقوى مما تتخيل. توكل على الله وانطلق',
    'كل صباح هو ولادة جديدة لك',
    'الفجر الجديد يحمل لك النصر',
  ];

  // ========================================
  // EVENING MESSAGES
  // ========================================
  static const List<String> _eveningMessages = [
    'انتهى اليوم بنجاح! فخور بك',
    'يوم آخر من الانتصارات. نم بسلام',
    'دماغك يُعيد بناء نفسه الآن في نومك',
    'كل يوم تنجح فيه هو خطوة نحو الحرية',
  ];

  // ========================================
  // URGE MESSAGES (DURING 90 SECOND TIMER)
  // ========================================
  static const List<String> _urgeMessages = [
    'دماغك يتغير الآن',
    'الرغبة مؤقتة، سوف تمضي',
    'أنت أقوى من الأمس بكثير',
    '90 ثانية فقط وتنتصر',
    'تنفس... أنت تسيطر الآن',
    'هذه اللحظة تحدد مستقبلك',
    'الألم مؤقت، الفخر دائم',
    'الله معك، استعن به',
    'مجرد موجة ستمر',
    'أنت لست عبداً لرغباتك',
  ];

  // ========================================
  // RELAPSE MESSAGES (NON-PUNISHING)
  // ========================================
  static const List<String> _relapseMessages = [
    'لم تسقط... أنت تتعلم',
    'العودة السريعة هي القوة الحقيقية',
    'الله غفور رحيم، عُد إليه الآن',
    'كل الأبطال سقطوا ثم قاموا',
    'الزلة ليست نهاية، بل درس',
    'تب الآن، والله يحب التوابين',
    'أنت أقوى مما كنت بالأمس',
  ];

  // ========================================
  // GENERAL MOTIVATIONAL MESSAGES
  // ========================================
  static const List<String> _generalMessages = [
    'لا تستسلم أبداً',
    'رحلتك ملهمة',
    'كل يوم أنت أقوى',
    'الحرية قريبة جداً',
    'أنت تستحق حياة أفضل',
    'قوتك في التزامك',
    'المستقبل مشرق بإذن الله',
    'ثق بنفسك وبقدراتك',
  ];

  // ========================================
  // MILESTONE MESSAGES (BASED ON STREAK)
  // ========================================
  static List<String> _getMilestoneMessages(int streak) {
    if (streak == 1) {
      return [
        'بداية موفقة! "إن الله يحب التوابين"',
        'أول خطوة في رحلة الألف ميل',
      ];
    } else if (streak == 3) {
      return [
        '3 أيام! الجسم بدأ التعافي',
        'استمر... النصر قريب',
      ];
    } else if (streak == 7) {
      return [
        'أسبوع من القوة! استمر في جهاد نفسك',
        'الدماغ يعيد بناء نفسه الآن',
      ];
    } else if (streak == 30) {
      return [
        'شهر كامل! أنت بطل حقيقي',
        'إنجاز أسطوري، فخور بك',
      ];
    } else if (streak == 90) {
      return [
        'الحرية الكاملة! دماغك تعافى تماماً',
        'أنت ملهم لكل من حولك',
      ];
    }
    return _generalMessages;
  }

  // ========================================
  // URGE TIMER SPECIFIC PHRASES
  // ========================================
  static const List<String> urgeTimerPhrases = [
    'تنفس بعمق...',
    'الرغبة ستمر...',
    'أنت أقوى...',
    'استمر...',
    'النصر قريب...',
    'لا تستسلم الآن...',
    'أنت تسيطر...',
  ];

  /// Get random urge timer phrase
  static String getUrgeTimerPhrase() {
    final index = DateTime.now().second % urgeTimerPhrases.length;
    return urgeTimerPhrases[index];
  }
}

/// Message Context
enum MessageContext {
  morning,
  evening,
  urge,
  relapse,
  milestone,
  general,
}
