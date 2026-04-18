// Exercise data models for all practice game types

class ExerciseQuestion {
  final String question;
  final String answer;
  final List<String> options; // must include the correct answer

  const ExerciseQuestion({
    required this.question,
    required this.answer,
    required this.options,
  });
}

class MatchingPair {
  final String term;
  final String definition;

  const MatchingPair({required this.term, required this.definition});
}

class TrueFalseQuestion {
  final String statement;
  final bool isTrue;
  final String explanation;

  const TrueFalseQuestion({
    required this.statement,
    required this.isTrue,
    required this.explanation,
  });
}

class FlashCard {
  final String front;
  final String back;

  const FlashCard({required this.front, required this.back});
}

class AnagramChallenge {
  final String answer; // e.g. "OCTAVE"
  final String hint;

  const AnagramChallenge({required this.answer, required this.hint});
}

class LessonExerciseSet {
  final int chapterNumber;
  final int partNumber;
  final String lessonTitle;
  final List<ExerciseQuestion> quiz;
  final List<MatchingPair> matching;
  final List<TrueFalseQuestion> trueFalse;
  final List<FlashCard> flashcards;
  final List<AnagramChallenge> anagrams;

  const LessonExerciseSet({
    required this.chapterNumber,
    required this.partNumber,
    required this.lessonTitle,
    required this.quiz,
    required this.matching,
    required this.trueFalse,
    required this.flashcards,
    required this.anagrams,
  });

  String get key => '$partNumber-$chapterNumber';
}
