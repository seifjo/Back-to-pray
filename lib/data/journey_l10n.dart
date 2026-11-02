import '../models/journey.dart';

/// English copy of the existing recovery journeys.
class JourneyL10n {
  static Journey localize(Journey journey, bool english) {
    if (!english) return journey;
    final pack = _packs[journey.id];
    if (pack == null) return journey;
    return Journey(
      id: journey.id,
      title: pack.title,
      description: pack.description,
      icon: journey.icon,
      recommendedDays: journey.recommendedDays,
      benefits: pack.benefits,
      tips: pack.tips,
      effects: EffectsExplanation(
        brainEffects: pack.brain,
        bodyEffects: pack.body,
        psychologyEffects: pack.mind,
      ),
      stages: [
        for (var i = 0; i < journey.stages.length; i++)
          _stage(journey.stages[i], i < pack.stages.length ? pack.stages[i] : null),
      ],
    );
  }

  static JourneyStage _stage(JourneyStage source, _StagePack? pack) {
    if (pack == null) return source;
    return JourneyStage(
      name: pack.name,
      description: pack.description,
      durationDays: source.durationDays,
      symptoms: pack.symptoms,
      copingStrategies: pack.coping,
      spiritualGuidance: pack.guidance,
      scientificExplanation: pack.science,
    );
  }
}

class _StagePack {
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> coping;
  final String guidance;
  final String science;

  const _StagePack({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.coping,
    required this.guidance,
    required this.science,
  });
}

class _Pack {
  final String title;
  final String description;
  final List<String> benefits;
  final List<String> tips;
  final String brain;
  final String body;
  final String mind;
  final List<_StagePack> stages;

  const _Pack({
    required this.title,
    required this.description,
    required this.benefits,
    required this.tips,
    required this.brain,
    required this.body,
    required this.mind,
    required this.stages,
  });
}

const _packs = <String, _Pack>{
  'masturbation_recovery': _Pack(
    title: 'Recovery from a compulsive habit',
    description: 'A path to leave a compulsive sexual habit and build a healthier day.',
    benefits: [
      'Clearer focus and energy',
      'More self-trust',
      'Steadier mood',
      'Stronger relationships',
      'Better sleep',
      'A quieter closeness to Allah',
    ],
    tips: [
      'Remove triggers from your device',
      'Move your body every day',
      'Fill empty time with a useful task',
      'Make wudu when the urge rises',
      'Leave the room immediately',
      'Use the 90-second urge timer',
    ],
    brain: 'A compulsive habit can drain reward and make ordinary focus feel flat.',
    body: 'Lower energy, disrupted sleep, and a body that feels heavy are common while the habit continues.',
    mind: 'Shame, anxiety, and isolation often grow with secrecy. The plan treats a missed day as a point to begin again.',
    stages: [
      _StagePack(
        name: 'Withdrawal (days 1–7)',
        description: 'The body and mind adjust to fewer sudden spikes of stimulation.',
        symptoms: ['Strong repeated urges', 'Harder sleep', 'Tension', 'Feeling easily stirred'],
        coping: ['Wudu when the urge rises', 'Leave the room and walk', 'Read Quran', 'Exercise', 'Fast if you are able'],
        guidance: 'Allah loves those who turn back. This moment can be a beginning, not a verdict.',
        science: 'The reward system starts to settle as the artificial spikes become less frequent.',
      ),
      _StagePack(
        name: 'Rebalancing (days 8–30)',
        description: 'Energy and mood begin to feel more even.',
        symptoms: ['Mood lifts gradually', 'More energy', 'Urgent cravings come less often'],
        coping: ['Keep a daily dhikr', 'Start one hobby', 'Spend time with people', 'Set one small daily aim'],
        guidance: 'Allah loves those who repent and those who keep themselves clean. Each day kept is enough.',
        science: 'Attention can return to slower, ordinary rewards.',
      ),
      _StagePack(
        name: 'Steadiness (days 31–90)',
        description: 'New habits become the usual shape of the day.',
        symptoms: ['More emotional steadiness', 'More self-trust', 'Relationships feel easier'],
        coping: ['Help someone else privately', 'A small act of service', 'Learn one new skill'],
        guidance: 'Whoever repents and sets things right, Allah turns to them. Continue, and thank Him.',
        science: 'Repeated healthy choices become the easier default.',
      ),
    ],
  ),
  'nicotine_recovery': _Pack(
    title: 'Recovery from nicotine',
    description: 'Leaving cigarettes and shisha.',
    benefits: [
      'Cleaner lungs',
      'Easier breathing',
      'Money kept',
      'A healthier heart',
      'Smell and taste returning',
      'More energy',
    ],
    tips: [
      'Drink water often',
      'Chew gum',
      'Avoid the usual triggers',
      'Use slow breathing',
      'Keep your hands busy',
      'Remember why you stopped',
    ],
    brain: 'Nicotine trains the reward system to expect a fast spike.',
    body: 'Heart and lung strain, weaker immunity, and faster aging are among the bodily costs.',
    mind: 'Anxiety, irritability, and low mood are common in the first days after stopping.',
    stages: [
      _StagePack(
        name: 'First days (1–3)',
        description: 'The sharpest nicotine withdrawal.',
        symptoms: ['Strong craving', 'Headache', 'Irritability', 'Harder focus'],
        coping: ['Drink water', 'Chew gum', 'Slow breathing', 'Prayer'],
        guidance: 'Patience is the door of relief. Allah loves those who are patient.',
        science: 'The body starts clearing nicotine while the craving is still loud.',
      ),
      _StagePack(
        name: 'Early recovery (4–14)',
        description: 'Breathing and energy start to improve.',
        symptoms: ['Easier breath', 'Smell returning', 'More energy'],
        coping: ['Exercise', 'Avoid triggers', 'Stay near supportive people'],
        guidance: 'The body is a trust from Allah. Caring for it is worship.',
        science: 'The lungs begin to clear, and the craving usually comes in shorter waves.',
      ),
    ],
  ),
  'dopamine_recovery': _Pack(
    title: 'Recovery from fast stimulation',
    description: 'Leaving compulsive social media and constant digital stimulation.',
    benefits: [
      'Better focus',
      'More useful hours',
      'Pleasure in simple things',
      'Time for real aims',
      'Deeper conversations',
      'A quieter mind',
    ],
    tips: [
      'Delete the apps that pull you',
      'Put the phone in another room',
      'Read a book',
      'Go outside',
      'Use your hands',
      'Give the phone a set time',
    ],
    brain: 'Endless short rewards make ordinary tasks feel dull and attention harder to hold.',
    body: 'Neck pain, tired eyes, poor sleep, and little movement often follow long sessions.',
    mind: 'Anxiety, emptiness, and constant comparison are common companions of the feed.',
    stages: [
      _StagePack(
        name: 'Digital detox (days 1–7)',
        description: 'Cut phone use sharply for one week.',
        symptoms: ['Boredom', 'Fear of missing something', 'A sense of emptiness'],
        coping: ['Delete distracting apps', 'Leave the phone away', 'Read', 'Go outside'],
        guidance: 'Time is a trust. Spend it on what benefits you.',
        science: 'Attention recovers when the fastest rewards are less available.',
      ),
    ],
  ),
};
