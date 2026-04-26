// Journey Models
// Recovery journeys for behavioral change

class Journey {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<JourneyStage> stages;
  final EffectsExplanation effects;
  final int recommendedDays;
  final List<String> benefits;
  final List<String> tips;

  const Journey({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.stages,
    required this.effects,
    required this.recommendedDays,
    required this.benefits,
    required this.tips,
  });
}

class JourneyStage {
  final String name;
  final String description;
  final int durationDays;
  final List<String> symptoms;
  final List<String> copingStrategies;
  final String spiritualGuidance;
  final String scientificExplanation;

  const JourneyStage({
    required this.name,
    required this.description,
    required this.durationDays,
    required this.symptoms,
    required this.copingStrategies,
    required this.spiritualGuidance,
    required this.scientificExplanation,
  });
}

class EffectsExplanation {
  final String brainEffects;
  final String bodyEffects;
  final String psychologyEffects;

  const EffectsExplanation({
    required this.brainEffects,
    required this.bodyEffects,
    required this.psychologyEffects,
  });
}
