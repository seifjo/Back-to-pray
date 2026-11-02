import 'package:back_to_prayer/core/services/islamic_quiz_store.dart';
import 'package:back_to_prayer/data/islamic_quiz_catalog.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/islamic_quiz.dart';
import 'package:back_to_prayer/providers/islamic_quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Islamic Quiz available', () {
    final feature =
        MoreFeaturesCatalog.features.firstWhere((item) => item.id == 'quiz');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.quiz);
  });

  test('catalog covers six topics with sources and four options', () {
    expect(IslamicQuizCatalog.topics.length, 6);
    expect(IslamicQuizCatalog.all, isNotEmpty);
    for (final topic in QuizTopic.values) {
      expect(
        IslamicQuizCatalog.forTopic(topic),
        isNotEmpty,
        reason: 'topic $topic should have questions',
      );
    }
    for (final q in IslamicQuizCatalog.all) {
      expect(q.optionsEn.length, 4);
      expect(q.optionsAr.length, 4);
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.sourceEn.trim(), isNotEmpty);
      expect(q.sourceAr.trim(), isNotEmpty);
      expect(q.explanationEn.trim(), isNotEmpty);
      expect(q.explanationAr.trim(), isNotEmpty);
    }
  });

  test('answer validation and scoring helpers', () {
    final q = IslamicQuizCatalog.byId('quran_surah_count')!;
    expect(IslamicQuizProvider.validateAnswer(q, q.correctIndex), isTrue);
    expect(IslamicQuizProvider.validateAnswer(q, (q.correctIndex + 1) % 4),
        isFalse);

    final answers = [
      QuizAnswerRecord(
        questionId: q.id,
        selectedIndex: q.correctIndex,
        correct: true,
        answeredAt: DateTime(2026, 1, 1),
      ),
      QuizAnswerRecord(
        questionId: 'hadith_intentions',
        selectedIndex: 0,
        correct: false,
        answeredAt: DateTime(2026, 1, 1),
      ),
    ];
    expect(IslamicQuizProvider.scoreCorrect(answers), 1);
  });

  test('question navigation and scoring through a session', () async {
    final provider = IslamicQuizProvider(
      clock: () => DateTime(2026, 3, 20, 10),
    );
    await provider.initialize();
    provider.setDifficulty(QuizDifficulty.beginner);
    final started = await provider.startTopicQuiz(QuizTopic.quran);
    expect(started, isTrue);
    expect(provider.session, isNotNull);
    expect(provider.currentQuestion, isNotNull);

    final first = provider.currentQuestion!;
    provider.selectOption(first.correctIndex);
    final ok = await provider.submitAnswer();
    expect(ok, isTrue);
    expect(provider.revealed, isTrue);
    expect(provider.lifetimeCorrect, 1);
    expect(provider.lifetimeAnswered, 1);

    final cursorBefore = provider.session!.cursor;
    await provider.nextQuestion();
    if (!provider.session!.isComplete) {
      expect(provider.session!.cursor, cursorBefore + 1);
      expect(provider.revealed, isFalse);
      expect(provider.pendingSelection, isNull);
    }
  });

  test('session restoration and settings persistence', () async {
    final store = IslamicQuizStore();
    final provider = IslamicQuizProvider(
      store: store,
      clock: () => DateTime(2026, 3, 20, 11),
    );
    await provider.initialize();
    provider.setDifficulty(QuizDifficulty.intermediate);
    await provider.startTopicQuiz(QuizTopic.hadith);
    final question = provider.currentQuestion!;
    provider.selectOption((question.correctIndex + 1) % 4);
    await provider.submitAnswer();
    expect(provider.incorrectIds.contains(question.id), isTrue);

    final restored = IslamicQuizProvider(
      store: store,
      clock: () => DateTime(2026, 3, 20, 12),
    );
    await restored.initialize();
    expect(restored.session, isNotNull);
    expect(restored.session!.id, provider.session!.id);
    expect(restored.session!.cursor, provider.session!.cursor);
    expect(restored.incorrectIds.contains(question.id), isTrue);
    expect(restored.lifetimeAnswered, greaterThanOrEqualTo(1));
    expect(restored.topicsReviewed.contains(QuizTopic.hadith.name), isTrue);
  });

  test('localization keys exist in English and Arabic', () {
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    const keys = [
      'quizTitle',
      'quizDifficultyBeginner',
      'quizTopicQuran',
      'quizTopicHadith',
      'quizTopicSeerah',
      'quizTopicProphets',
      'quizTopicHistory',
      'quizTopicGeneral',
      'quizRetryIncorrect',
      'quizRevisionMode',
      'quizAnswerCorrect',
      'quizSource',
      'quizNoLeaderboard',
    ];
    for (final key in keys) {
      expect(en.tr(key), isNot(equals(key)));
      expect(ar.tr(key), isNot(equals(key)));
      expect(ar.tr(key), isNot(equals(en.tr(key))));
    }
  });
}
