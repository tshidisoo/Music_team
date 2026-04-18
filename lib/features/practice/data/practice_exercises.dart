import '../models/exercise_models.dart';

/// All exercise sets for every lesson — keyed by "$partNumber-$chapterNumber"
class PracticeExercises {
  PracticeExercises._();

  static LessonExerciseSet? getForLesson(int partNumber, int chapterNumber) =>
      _all['$partNumber-$chapterNumber'];

  static final Map<String, LessonExerciseSet> _all = {
    // ══════════════════════════════════════════════════════════════
    // PART I
    // ══════════════════════════════════════════════════════════════

    '1-1': const LessonExerciseSet(
      chapterNumber: 1,
      partNumber: 1,
      lessonTitle: 'Sounds and Notes',
      quiz: [
        ExerciseQuestion(
          question: 'What letter names are used for musical notes?',
          answer: 'A B C D E F G',
          options: ['A B C D E F G', 'Do Re Mi Fa Sol La Ti', '1 2 3 4 5 6 7', 'A B C D E F G H'],
        ),
        ExerciseQuestion(
          question: 'The distance between one note and the next note of the same name is called a…',
          answer: 'Octave',
          options: ['Octave', 'Fifth', 'Tone', 'Semitone'],
        ),
        ExerciseQuestion(
          question: 'How many different letter names exist for musical notes?',
          answer: '7',
          options: ['7', '8', '12', '5'],
        ),
        ExerciseQuestion(
          question: 'Middle C is also written as…',
          answer: 'C4',
          options: ['C4', 'C3', 'C5', 'C1'],
        ),
        ExerciseQuestion(
          question: 'Written notes tell us…',
          answer: 'Both pitch and duration',
          options: ['Both pitch and duration', 'Only pitch', 'Only duration', 'Neither pitch nor duration'],
        ),
        ExerciseQuestion(
          question: 'After the note G, the sequence continues with…',
          answer: 'A (the pattern repeats)',
          options: ['A (the pattern repeats)', 'H', 'Z', 'Back to C only'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Note', definition: 'A sound with a definite pitch'),
        MatchingPair(term: 'Octave', definition: 'Distance between two notes of the same name'),
        MatchingPair(term: 'Pitch', definition: 'How high or low a sound is'),
        MatchingPair(term: 'Middle C', definition: 'The C nearest the centre of a piano (C4)'),
        MatchingPair(term: 'Duration', definition: 'How long a note is held'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'Notes are named using the first 12 letters of the alphabet.', isTrue: false, explanation: 'Only 7 letters are used: A B C D E F G'),
        TrueFalseQuestion(statement: 'An octave higher sounds the same but at a higher pitch.', isTrue: true, explanation: 'Correct — same character, higher frequency'),
        TrueFalseQuestion(statement: 'Middle C is the C nearest the centre of a standard piano.', isTrue: true, explanation: 'Yes — also called C4'),
        TrueFalseQuestion(statement: 'After G, the next note letter is H.', isTrue: false, explanation: 'After G the pattern repeats: the next is A'),
        TrueFalseQuestion(statement: 'Written notes can show both pitch and duration.', isTrue: true, explanation: 'The position shows pitch; the shape shows duration'),
      ],
      flashcards: [
        FlashCard(front: 'What is a musical note?', back: 'A sound with a definite, recognisable pitch'),
        FlashCard(front: 'How many letter names exist for notes?', back: '7 — A B C D E F G'),
        FlashCard(front: 'What is an octave?', back: 'The distance between one note and the next note with the same letter name'),
        FlashCard(front: 'What is Middle C?', back: 'The C nearest the centre of a piano keyboard — also called C4'),
        FlashCard(front: 'What does "pitch" describe?', back: 'How high or low a sound is'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'OCTAVE', hint: 'The distance between two same-named notes'),
        AnagramChallenge(answer: 'PITCH', hint: 'How high or low a sound is'),
        AnagramChallenge(answer: 'SCALE', hint: 'An ordered sequence of notes'),
        AnagramChallenge(answer: 'NOTE', hint: 'A sound with definite pitch'),
      ],
    ),

    '1-2': const LessonExerciseSet(
      chapterNumber: 2,
      partNumber: 1,
      lessonTitle: 'The Stave, Clefs and Notes',
      quiz: [
        ExerciseQuestion(
          question: 'How many lines does a stave have?',
          answer: '5',
          options: ['5', '4', '6', '3'],
        ),
        ExerciseQuestion(
          question: 'The treble clef fixes which line as G4?',
          answer: '2nd line',
          options: ['2nd line', '1st line', '3rd line', '4th line'],
        ),
        ExerciseQuestion(
          question: 'The bass clef fixes which line as F3?',
          answer: '4th line',
          options: ['4th line', '2nd line', '3rd line', '5th line'],
        ),
        ExerciseQuestion(
          question: 'Short extra lines above or below the stave are called…',
          answer: 'Ledger lines',
          options: ['Ledger lines', 'Beam lines', 'Stave extensions', 'Extra bars'],
        ),
        ExerciseQuestion(
          question: 'Which clef is used for violin and flute?',
          answer: 'Treble clef',
          options: ['Treble clef', 'Bass clef', 'Alto clef', 'Tenor clef'],
        ),
        ExerciseQuestion(
          question: 'How many spaces are between the 5 stave lines?',
          answer: '4',
          options: ['4', '5', '3', '6'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Treble clef', definition: 'Used for violin, flute, piano right hand'),
        MatchingPair(term: 'Bass clef', definition: 'Used for cello, tuba, piano left hand'),
        MatchingPair(term: 'Stave', definition: '5 horizontal lines on which music is written'),
        MatchingPair(term: 'Ledger lines', definition: 'Short lines extending above or below the stave'),
        MatchingPair(term: '2nd line (treble)', definition: 'Fixed as G4 — above middle C'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A stave has six lines.', isTrue: false, explanation: 'A stave has exactly 5 lines and 4 spaces'),
        TrueFalseQuestion(statement: 'The treble clef is used for higher-pitched instruments.', isTrue: true, explanation: 'Violin, flute, oboe, trumpet all use it'),
        TrueFalseQuestion(statement: 'Middle C is written on a ledger line below the treble clef stave.', isTrue: true, explanation: 'Correct — it sits on a short ledger line below'),
        TrueFalseQuestion(statement: 'The bass clef marks the 2nd line as F3.', isTrue: false, explanation: 'It marks the 4th line as F3'),
        TrueFalseQuestion(statement: 'Notes placed higher on the stave have a higher pitch.', isTrue: true, explanation: 'Higher position = higher pitch'),
      ],
      flashcards: [
        FlashCard(front: 'What is a stave?', back: '5 horizontal lines (and 4 spaces) on which music is written'),
        FlashCard(front: 'What note does the treble clef fix on the 2nd line?', back: 'G4 — just above middle C'),
        FlashCard(front: 'What note does the bass clef fix on the 4th line?', back: 'F3 — below middle C'),
        FlashCard(front: 'What are ledger lines?', back: 'Short extra lines added above or below the stave for notes beyond its range'),
        FlashCard(front: 'Which instruments use the treble clef?', back: 'Violin, flute, oboe, trumpet, and piano right hand'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'STAVE', hint: '5 lines for writing music'),
        AnagramChallenge(answer: 'TREBLE', hint: 'Type of clef for higher instruments'),
        AnagramChallenge(answer: 'LEDGER', hint: 'Extra lines beyond the stave'),
        AnagramChallenge(answer: 'CLEF', hint: 'Symbol that fixes note pitches on the stave'),
      ],
    ),

    '1-3': const LessonExerciseSet(
      chapterNumber: 3,
      partNumber: 1,
      lessonTitle: 'Note Values',
      quiz: [
        ExerciseQuestion(
          question: 'How many beats does a semibreve last?',
          answer: '4',
          options: ['4', '2', '1', '3'],
        ),
        ExerciseQuestion(
          question: 'Another name for a crotchet is…',
          answer: 'Quarter note',
          options: ['Quarter note', 'Half note', 'Whole note', 'Eighth note'],
        ),
        ExerciseQuestion(
          question: 'A quaver is worth how many crotchet beats?',
          answer: '½ beat',
          options: ['½ beat', '1 beat', '2 beats', '¼ beat'],
        ),
        ExerciseQuestion(
          question: 'Which note value has TWO flags on its stem?',
          answer: 'Semiquaver',
          options: ['Semiquaver', 'Quaver', 'Crotchet', 'Minim'],
        ),
        ExerciseQuestion(
          question: 'A minim is worth how many crotchets?',
          answer: '2',
          options: ['2', '4', '1', '3'],
        ),
        ExerciseQuestion(
          question: 'What replaces individual flags when quavers are grouped?',
          answer: 'Beams',
          options: ['Beams', 'Ties', 'Slurs', 'Bar lines'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Semibreve', definition: 'Whole note — 4 beats (open oval, no stem)'),
        MatchingPair(term: 'Minim', definition: 'Half note — 2 beats (open oval with stem)'),
        MatchingPair(term: 'Crotchet', definition: 'Quarter note — 1 beat (filled oval with stem)'),
        MatchingPair(term: 'Quaver', definition: 'Eighth note — ½ beat (1 flag)'),
        MatchingPair(term: 'Semiquaver', definition: 'Sixteenth note — ¼ beat (2 flags)'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A minim lasts twice as long as a crotchet.', isTrue: true, explanation: 'Minim = 2 beats; crotchet = 1 beat'),
        TrueFalseQuestion(statement: 'A semiquaver has one flag on its stem.', isTrue: false, explanation: 'A semiquaver has TWO flags; a quaver has one'),
        TrueFalseQuestion(statement: 'The crotchet is the standard unit of beat in most music.', isTrue: true, explanation: 'When we count 1 2 3 4, each count = one crotchet'),
        TrueFalseQuestion(statement: 'Quavers and semiquavers can be joined by beams.', isTrue: true, explanation: 'Beams replace individual flags for clarity'),
        TrueFalseQuestion(statement: 'A semibreve has a stem.', isTrue: false, explanation: 'The semibreve is an open oval with NO stem'),
      ],
      flashcards: [
        FlashCard(front: 'What is a semibreve?', back: 'A whole note worth 4 crotchet beats — an open oval with no stem'),
        FlashCard(front: 'What is a minim?', back: 'A half note worth 2 crotchet beats — an open oval with a stem'),
        FlashCard(front: 'What is a crotchet?', back: 'A quarter note worth 1 beat — a filled oval with a stem'),
        FlashCard(front: 'What is a quaver?', back: 'An eighth note worth ½ beat — a filled oval with one flag'),
        FlashCard(front: 'What are beams?', back: 'Thick horizontal lines joining quavers/semiquavers instead of individual flags'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'MINIM', hint: 'Half note worth 2 beats'),
        AnagramChallenge(answer: 'CROTCHET', hint: 'Quarter note — the standard beat unit'),
        AnagramChallenge(answer: 'QUAVER', hint: 'Eighth note with one flag'),
        AnagramChallenge(answer: 'SEMIBREVE', hint: 'Whole note worth 4 beats'),
      ],
    ),

    '1-4': const LessonExerciseSet(
      chapterNumber: 4,
      partNumber: 1,
      lessonTitle: 'Time Signatures and Bar Lines',
      quiz: [
        ExerciseQuestion(
          question: 'In a time signature, the TOP number tells us…',
          answer: 'How many beats are in each bar',
          options: ['How many beats are in each bar', 'What type of note gets one beat', 'How fast to play', 'How many bars in the piece'],
        ),
        ExerciseQuestion(
          question: 'In 3/4 time, how many beats are in each bar?',
          answer: '3',
          options: ['3', '4', '2', '1'],
        ),
        ExerciseQuestion(
          question: 'In 4/4 time, the bottom "4" means which note gets one beat?',
          answer: 'Crotchet',
          options: ['Crotchet', 'Minim', 'Quaver', 'Semibreve'],
        ),
        ExerciseQuestion(
          question: 'A bar line serves what purpose?',
          answer: 'Divides music into equal bars',
          options: ['Divides music into equal bars', 'Shows the end of a piece', 'Indicates a repeat', 'Shows the key'],
        ),
        ExerciseQuestion(
          question: 'Which time signature is called "common time"?',
          answer: '4/4',
          options: ['4/4', '3/4', '2/4', '2/2'],
        ),
        ExerciseQuestion(
          question: 'The very end of a piece is marked by…',
          answer: 'A final bar line (thin + thick)',
          options: ['A final bar line (thin + thick)', 'A double bar line', 'A repeat sign', 'A fermata'],
        ),
      ],
      matching: [
        MatchingPair(term: '4/4', definition: 'Four crotchet beats per bar — the most common'),
        MatchingPair(term: '3/4', definition: 'Three crotchet beats per bar — waltz feel'),
        MatchingPair(term: '2/4', definition: 'Two crotchet beats per bar — march feel'),
        MatchingPair(term: 'Top number', definition: 'Beats per bar'),
        MatchingPair(term: 'Bottom number', definition: 'Note value that receives one beat'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'In 3/4 time there are three crotchet beats per bar.', isTrue: true, explanation: '3 = three beats, 4 = crotchet gets one beat'),
        TrueFalseQuestion(statement: 'The bottom "4" in a time signature means minim.', isTrue: false, explanation: '"4" means crotchet (quarter note); "2" means minim'),
        TrueFalseQuestion(statement: 'A double bar line marks the very end of a piece.', isTrue: false, explanation: 'A FINAL bar line (thin + thick) ends the piece; a double bar line ends a section'),
        TrueFalseQuestion(statement: '4/4 is sometimes called common time.', isTrue: true, explanation: 'It is so common it has a special C symbol'),
        TrueFalseQuestion(statement: 'Bar lines divide music into equal groups of beats.', isTrue: true, explanation: 'Each bar contains exactly the same number of beats'),
      ],
      flashcards: [
        FlashCard(front: 'What does a time signature tell us?', back: 'Top number = beats per bar; Bottom number = which note gets one beat'),
        FlashCard(front: 'What does "4" as the bottom number mean?', back: 'The crotchet (quarter note) gets one beat'),
        FlashCard(front: 'What is a bar?', back: 'An equal unit of music between two bar lines, containing a set number of beats'),
        FlashCard(front: 'Double bar line vs final bar line?', back: 'Double bar line ends a section; final bar line (thin + thick) ends the whole piece'),
        FlashCard(front: 'What feel does 3/4 time give?', back: 'A waltz feel — ONE-two-three, ONE-two-three'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'BARLINE', hint: 'Vertical line dividing music into equal units'),
        AnagramChallenge(answer: 'TEMPO', hint: 'The speed of music'),
        AnagramChallenge(answer: 'WALTZ', hint: 'A dance in 3/4 time'),
        AnagramChallenge(answer: 'BEAT', hint: 'The regular pulse in music'),
      ],
    ),

    '1-5': const LessonExerciseSet(
      chapterNumber: 5,
      partNumber: 1,
      lessonTitle: 'Dotted Notes and Ties',
      quiz: [
        ExerciseQuestion(
          question: 'What does a dot after a note do to its value?',
          answer: 'Adds half its value',
          options: ['Adds half its value', 'Doubles its value', 'Halves its value', 'Has no effect'],
        ),
        ExerciseQuestion(
          question: 'How many beats does a dotted minim last?',
          answer: '3',
          options: ['3', '2', '4', '2.5'],
        ),
        ExerciseQuestion(
          question: 'A tie connects two notes of…',
          answer: 'The same pitch',
          options: ['The same pitch', 'Different pitches', 'Any pitch', 'Only adjacent notes'],
        ),
        ExerciseQuestion(
          question: 'A slur tells a performer to…',
          answer: 'Play the notes smoothly (legato)',
          options: ['Play the notes smoothly (legato)', 'Play staccato (detached)', 'Hold both notes combined', 'Repeat the notes'],
        ),
        ExerciseQuestion(
          question: 'A dotted crotchet lasts how many beats?',
          answer: '1½',
          options: ['1½', '1', '2', '¾'],
        ),
        ExerciseQuestion(
          question: 'The key difference between a tie and a slur is…',
          answer: 'Tie = same pitch; slur = different pitches',
          options: ['Tie = same pitch; slur = different pitches', 'Tie = different pitches; slur = same pitch', 'They mean the same thing', 'Ties are only in piano music'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Dot', definition: 'Adds half the note\'s own value to it'),
        MatchingPair(term: 'Tie', definition: 'Curved line connecting two notes of the SAME pitch'),
        MatchingPair(term: 'Slur', definition: 'Curved line connecting notes of DIFFERENT pitches — play smoothly'),
        MatchingPair(term: 'Dotted minim', definition: '2 + 1 = 3 beats'),
        MatchingPair(term: 'Dotted crotchet', definition: '1 + ½ = 1½ beats'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A dot after a note doubles its value.', isTrue: false, explanation: 'A dot adds HALF the note\'s value, not double'),
        TrueFalseQuestion(statement: 'A tie means you hold the note without restriking.', isTrue: true, explanation: 'You hold through — the second note is not struck again'),
        TrueFalseQuestion(statement: 'A slur and a tie look the same but have different meanings.', isTrue: true, explanation: 'Both are curved lines, but tie = same pitch; slur = different pitches'),
        TrueFalseQuestion(statement: 'A dotted quaver lasts one full beat.', isTrue: false, explanation: 'A dotted quaver lasts ¾ beat (½ + ¼)'),
        TrueFalseQuestion(statement: 'Ties can extend a note across a bar line.', isTrue: true, explanation: 'This is one of the main uses of ties'),
      ],
      flashcards: [
        FlashCard(front: 'What does a dotted note do?', back: 'A dot adds half of the note\'s own value (e.g., dotted minim = 3 beats)'),
        FlashCard(front: 'What is a tie?', back: 'A curved line connecting two notes of the SAME pitch — hold for the combined duration, do not restrike'),
        FlashCard(front: 'What is a slur?', back: 'A curved line over notes of DIFFERENT pitches — play them smoothly (legato)'),
        FlashCard(front: 'How long is a dotted crotchet?', back: '1½ beats (1 + ½)'),
        FlashCard(front: 'Why are ties used across bar lines?', back: 'To create note durations that span from one bar into the next'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'LEGATO', hint: 'Italian for smooth, connected playing'),
        AnagramChallenge(answer: 'DOTTED', hint: 'A note with half its value added'),
        AnagramChallenge(answer: 'SLUR', hint: 'Curved line for smooth playing of different pitches'),
        AnagramChallenge(answer: 'DURATION', hint: 'How long a note is held'),
      ],
    ),

    '1-6': const LessonExerciseSet(
      chapterNumber: 6,
      partNumber: 1,
      lessonTitle: 'Scales and Keys — The Major Scale',
      quiz: [
        ExerciseQuestion(
          question: 'What is the tone/semitone pattern of every major scale?',
          answer: 'T T S T T T S',
          options: ['T T S T T T S', 'T S T T S T T', 'T T T S T T S', 'S T T T S T T'],
        ),
        ExerciseQuestion(
          question: 'How many semitones equal one tone?',
          answer: '2',
          options: ['2', '3', '1', '4'],
        ),
        ExerciseQuestion(
          question: 'Which major scale has no sharps or flats?',
          answer: 'C major',
          options: ['C major', 'G major', 'F major', 'D major'],
        ),
        ExerciseQuestion(
          question: 'What is the smallest step in Western music?',
          answer: 'Semitone',
          options: ['Semitone', 'Tone', 'Half-tone', 'Interval'],
        ),
        ExerciseQuestion(
          question: 'The notes of C major are…',
          answer: 'C D E F G A B C',
          options: ['C D E F G A B C', 'C D E F♯ G A B C', 'C D E♭ F G A B C', 'C D♯ E F G A B C'],
        ),
        ExerciseQuestion(
          question: 'The interval from E to F on a piano is…',
          answer: 'A semitone',
          options: ['A semitone', 'A tone', 'A minor 3rd', 'A major 2nd'],
        ),
      ],
      matching: [
        MatchingPair(term: 'C major scale', definition: 'C D E F G A B C — no sharps or flats'),
        MatchingPair(term: 'Semitone', definition: 'The smallest interval — adjacent piano keys'),
        MatchingPair(term: 'Tone', definition: 'Two semitones'),
        MatchingPair(term: 'Tonic', definition: 'The home note — 1st degree of the scale'),
        MatchingPair(term: 'T T S T T T S', definition: 'The tone/semitone pattern of every major scale'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'C major is the only major scale with no sharps or flats.', isTrue: true, explanation: 'All other major scales need at least one accidental'),
        TrueFalseQuestion(statement: 'A tone is smaller than a semitone.', isTrue: false, explanation: 'A tone = 2 semitones, so a tone is LARGER'),
        TrueFalseQuestion(statement: 'Every major scale follows the pattern T T S T T T S.', isTrue: true, explanation: 'This pattern defines all major scales'),
        TrueFalseQuestion(statement: 'The interval from E to F is a tone.', isTrue: false, explanation: 'E to F is a semitone — there is no black key between them'),
        TrueFalseQuestion(statement: 'The note B to C is a semitone.', isTrue: true, explanation: 'No black key between B and C — they are adjacent'),
      ],
      flashcards: [
        FlashCard(front: 'What is a scale?', back: 'A sequence of notes in alphabetical order, from one note to the same note an octave higher'),
        FlashCard(front: 'What is the major scale pattern?', back: 'T T S T T T S (Tone Tone Semitone Tone Tone Tone Semitone)'),
        FlashCard(front: 'What is a semitone?', back: 'The smallest interval in Western music — the distance between two adjacent piano keys'),
        FlashCard(front: 'What are the notes of C major?', back: 'C D E F G A B C — all white keys, no sharps or flats'),
        FlashCard(front: 'What does "key" mean?', back: 'The scale the music is based on; the piece feels centred on the tonic note'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'MAJOR', hint: 'Scale type with a bright, happy sound'),
        AnagramChallenge(answer: 'TONIC', hint: 'The home note and 1st degree of a scale'),
        AnagramChallenge(answer: 'SEMITONE', hint: 'The smallest musical interval'),
        AnagramChallenge(answer: 'SCALE', hint: 'An ordered ascending sequence of notes'),
      ],
    ),

    '1-7': const LessonExerciseSet(
      chapterNumber: 7,
      partNumber: 1,
      lessonTitle: 'Sharps, Flats and Naturals',
      quiz: [
        ExerciseQuestion(
          question: 'What does a sharp (♯) do to a note?',
          answer: 'Raises it by one semitone',
          options: ['Raises it by one semitone', 'Lowers it by one semitone', 'Cancels a flat', 'Raises it by a tone'],
        ),
        ExerciseQuestion(
          question: 'What does a flat (♭) do to a note?',
          answer: 'Lowers it by one semitone',
          options: ['Lowers it by one semitone', 'Raises it by one semitone', 'Cancels a sharp', 'Lowers it by a tone'],
        ),
        ExerciseQuestion(
          question: 'How long does an accidental apply?',
          answer: 'For the rest of the bar',
          options: ['For the rest of the bar', 'For one note only', 'For the whole piece', 'Until cancelled by a double bar line'],
        ),
        ExerciseQuestion(
          question: 'F♯ and G♭ are examples of…',
          answer: 'Enharmonic equivalents',
          options: ['Enharmonic equivalents', 'Chromatic pairs', 'Double accidentals', 'Key signature notes'],
        ),
        ExerciseQuestion(
          question: 'What symbol cancels a previous sharp or flat?',
          answer: 'Natural (♮)',
          options: ['Natural (♮)', 'Double bar line', 'New time signature', 'A dot'],
        ),
        ExerciseQuestion(
          question: 'A double sharp raises a note by…',
          answer: 'Two semitones',
          options: ['Two semitones', 'One semitone', 'A tone and a half', 'Three semitones'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Sharp ♯', definition: 'Raises a note by one semitone'),
        MatchingPair(term: 'Flat ♭', definition: 'Lowers a note by one semitone'),
        MatchingPair(term: 'Natural ♮', definition: 'Cancels a sharp or flat within the bar'),
        MatchingPair(term: 'Accidental', definition: 'Symbol that temporarily alters a note\'s pitch'),
        MatchingPair(term: 'Enharmonic equivalent', definition: 'Same pitch, different name (e.g., F♯ = G♭)'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A sharp raises a note by one semitone.', isTrue: true, explanation: 'F♯ is one semitone higher than F'),
        TrueFalseQuestion(statement: 'An accidental only applies to the one note it is placed before.', isTrue: false, explanation: 'It applies to ALL notes on that pitch for the rest of the bar'),
        TrueFalseQuestion(statement: 'A natural sign raises a note by a semitone.', isTrue: false, explanation: 'A natural CANCELS a sharp or flat — it does not raise the pitch'),
        TrueFalseQuestion(statement: 'F♯ and G♭ sound like different pitches.', isTrue: false, explanation: 'They are enharmonic equivalents — identical pitch, different names'),
        TrueFalseQuestion(statement: 'A double flat lowers a note by two semitones.', isTrue: true, explanation: 'Double flat (𝄫) = two semitones lower'),
      ],
      flashcards: [
        FlashCard(front: 'What is a sharp (♯)?', back: 'A symbol that raises a note by one semitone'),
        FlashCard(front: 'What is a flat (♭)?', back: 'A symbol that lowers a note by one semitone'),
        FlashCard(front: 'How long does an accidental last?', back: 'For the rest of the bar, unless cancelled earlier by a natural sign'),
        FlashCard(front: 'What are enharmonic equivalents?', back: 'Two notes that sound identical but are written differently (e.g., F♯ = G♭)'),
        FlashCard(front: 'What is a natural (♮)?', back: 'A symbol that cancels a previous sharp or flat, returning the note to its original pitch'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'SHARP', hint: 'Symbol ♯ — raises a note one semitone'),
        AnagramChallenge(answer: 'NATURAL', hint: 'Symbol ♮ — cancels an accidental'),
        AnagramChallenge(answer: 'FLAT', hint: 'Symbol ♭ — lowers a note one semitone'),
        AnagramChallenge(answer: 'ACCIDENTAL', hint: 'Symbol that temporarily changes a note\'s pitch'),
      ],
    ),

    '1-8': const LessonExerciseSet(
      chapterNumber: 8,
      partNumber: 1,
      lessonTitle: 'Tones and Semitones — More Major Scales',
      quiz: [
        ExerciseQuestion(
          question: 'G major has how many sharps?',
          answer: '1 (F♯)',
          options: ['1 (F♯)', '2', '0', '3'],
        ),
        ExerciseQuestion(
          question: 'Which note is sharp in G major?',
          answer: 'F♯',
          options: ['F♯', 'C♯', 'G♯', 'B♭'],
        ),
        ExerciseQuestion(
          question: 'F major has how many flats?',
          answer: '1 (B♭)',
          options: ['1 (B♭)', '2', '3', '0'],
        ),
        ExerciseQuestion(
          question: 'What is the order in which SHARPS are added?',
          answer: 'F C G D A E B',
          options: ['F C G D A E B', 'B E A D G C F', 'C G D A E B F', 'A E B F C G D'],
        ),
        ExerciseQuestion(
          question: 'D major has how many sharps?',
          answer: '2 (F♯ and C♯)',
          options: ['2 (F♯ and C♯)', '1', '3', '4'],
        ),
        ExerciseQuestion(
          question: 'What is the order in which FLATS are added?',
          answer: 'B E A D G C F',
          options: ['B E A D G C F', 'F C G D A E B', 'E A D G C F B', 'C F G D A E B'],
        ),
      ],
      matching: [
        MatchingPair(term: 'G major', definition: '1 sharp — F♯'),
        MatchingPair(term: 'D major', definition: '2 sharps — F♯, C♯'),
        MatchingPair(term: 'F major', definition: '1 flat — B♭'),
        MatchingPair(term: 'B♭ major', definition: '2 flats — B♭, E♭'),
        MatchingPair(term: 'Key signature', definition: 'Sharps or flats placed at the start of each stave'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'G major has one sharp: F♯.', isTrue: true, explanation: 'The major scale pattern starting on G forces F to be sharp'),
        TrueFalseQuestion(statement: 'F major has one flat: B♭.', isTrue: true, explanation: 'Starting the pattern on F forces B to be flat'),
        TrueFalseQuestion(statement: 'D major has two flats.', isTrue: false, explanation: 'D major has 2 SHARPS: F♯ and C♯'),
        TrueFalseQuestion(statement: 'Sharps are added in the order F C G D A E B.', isTrue: true, explanation: 'Remember: Father Charles Goes Down And Ends Battle'),
        TrueFalseQuestion(statement: 'A key signature saves us from writing accidentals on every note.', isTrue: true, explanation: 'It applies to all notes of that pitch throughout the piece'),
      ],
      flashcards: [
        FlashCard(front: 'How many sharps does G major have?', back: '1 sharp — F♯'),
        FlashCard(front: 'How many sharps does D major have?', back: '2 sharps — F♯ and C♯'),
        FlashCard(front: 'How many flats does F major have?', back: '1 flat — B♭'),
        FlashCard(front: 'What is the order sharps are added?', back: 'F C G D A E B (Father Charles Goes Down And Ends Battle)'),
        FlashCard(front: 'What is the order flats are added?', back: 'B E A D G C F (Battle Ends And Down Goes Charles\'s Father)'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'SIGNATURE', hint: 'Key ___ shows which notes are always sharp or flat'),
        AnagramChallenge(answer: 'DOMINANT', hint: 'The 5th degree of a scale'),
        AnagramChallenge(answer: 'KEYBOARD', hint: 'Instrument with black and white keys'),
        AnagramChallenge(answer: 'SHARP', hint: 'Symbol ♯ used in key signatures'),
      ],
    ),

    '1-9': const LessonExerciseSet(
      chapterNumber: 9,
      partNumber: 1,
      lessonTitle: 'Minor Scales',
      quiz: [
        ExerciseQuestion(
          question: 'What is the tone/semitone pattern of the natural minor scale?',
          answer: 'T S T T S T T',
          options: ['T S T T S T T', 'T T S T T T S', 'S T T S T T T', 'T T T S T T S'],
        ),
        ExerciseQuestion(
          question: 'The harmonic minor differs from natural minor by…',
          answer: 'Raising the 7th degree by a semitone',
          options: ['Raising the 7th degree by a semitone', 'Lowering the 6th degree', 'Raising both 6th and 7th', 'Lowering the 7th'],
        ),
        ExerciseQuestion(
          question: 'A minor is the relative minor of which major key?',
          answer: 'C major',
          options: ['C major', 'G major', 'F major', 'D major'],
        ),
        ExerciseQuestion(
          question: 'The melodic minor ascending raises which degrees?',
          answer: '6th and 7th',
          options: ['6th and 7th', '7th only', '6th only', '5th and 7th'],
        ),
        ExerciseQuestion(
          question: 'The relative minor starts on which degree of the major scale?',
          answer: '6th degree',
          options: ['6th degree', '7th degree', '3rd degree', '4th degree'],
        ),
        ExerciseQuestion(
          question: 'The harmonic minor\'s characteristic interval is…',
          answer: 'Augmented 2nd (between 6th and 7th)',
          options: ['Augmented 2nd (between 6th and 7th)', 'Minor 3rd', 'Perfect 5th', 'Major 2nd'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Natural minor', definition: 'Uses only the key signature notes — T S T T S T T'),
        MatchingPair(term: 'Harmonic minor', definition: 'Raises the 7th degree by one semitone'),
        MatchingPair(term: 'Melodic minor', definition: 'Raises 6th and 7th ascending; natural minor descending'),
        MatchingPair(term: 'Relative minor', definition: 'Shares the same key signature as its major counterpart'),
        MatchingPair(term: 'A minor', definition: 'Relative minor of C major — no sharps or flats'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'The harmonic minor raises the 7th degree.', isTrue: true, explanation: 'This creates the distinctive augmented 2nd interval'),
        TrueFalseQuestion(statement: 'A minor and C major have the same key signature.', isTrue: true, explanation: 'Both have no sharps or flats — they are relative'),
        TrueFalseQuestion(statement: 'The melodic minor ascending and descending are the same.', isTrue: false, explanation: 'Ascending raises 6th and 7th; descending uses natural minor'),
        TrueFalseQuestion(statement: 'The relative minor starts on the 3rd degree of the major scale.', isTrue: false, explanation: 'It starts on the 6th degree'),
        TrueFalseQuestion(statement: 'The augmented 2nd in harmonic minor has a distinctive sound.', isTrue: true, explanation: 'This interval gives harmonic minor its exotic, expressive character'),
      ],
      flashcards: [
        FlashCard(front: 'What is the natural minor scale pattern?', back: 'T S T T S T T'),
        FlashCard(front: 'How does the harmonic minor differ from natural minor?', back: 'It raises the 7th degree by one semitone, creating an augmented 2nd between the 6th and 7th'),
        FlashCard(front: 'What is the relative minor?', back: 'A minor scale sharing the same key signature as a major key; starts on its 6th degree'),
        FlashCard(front: 'How is A minor related to C major?', back: 'A minor is the relative minor of C major — both have no sharps or flats'),
        FlashCard(front: 'How does the melodic minor work?', back: 'Raises 6th and 7th when ascending; returns to natural minor when descending'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'MINOR', hint: 'Scale type with a darker, more expressive sound'),
        AnagramChallenge(answer: 'HARMONIC', hint: 'Minor scale variety with a raised 7th'),
        AnagramChallenge(answer: 'RELATIVE', hint: 'Two keys sharing the same key signature'),
        AnagramChallenge(answer: 'MELODIC', hint: 'Minor scale variety that changes between ascending and descending'),
      ],
    ),

    '1-10': const LessonExerciseSet(
      chapterNumber: 10,
      partNumber: 1,
      lessonTitle: 'Intervals',
      quiz: [
        ExerciseQuestion(
          question: 'The interval from C to E is called…',
          answer: 'A 3rd',
          options: ['A 3rd', 'A 4th', 'A 2nd', 'A 5th'],
        ),
        ExerciseQuestion(
          question: 'How do you count the size of an interval?',
          answer: 'Include both the starting and ending notes',
          options: ['Include both the starting and ending notes', 'Count only the spaces between', 'Count only white keys', 'Subtract 1 from the number of steps'],
        ),
        ExerciseQuestion(
          question: 'C to G is what interval?',
          answer: 'A 5th',
          options: ['A 5th', 'A 4th', 'A 6th', 'A 7th'],
        ),
        ExerciseQuestion(
          question: 'Notes played simultaneously form a…',
          answer: 'Harmonic interval',
          options: ['Harmonic interval', 'Melodic interval', 'Compound interval', 'Perfect interval'],
        ),
        ExerciseQuestion(
          question: 'An octave spans how many letter names?',
          answer: '8',
          options: ['8', '7', '12', '6'],
        ),
        ExerciseQuestion(
          question: 'C to F is what interval?',
          answer: 'A 4th',
          options: ['A 4th', 'A 3rd', 'A 5th', 'A 6th'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Unison', definition: 'Two notes of exactly the same pitch'),
        MatchingPair(term: '3rd', definition: 'Interval spanning 3 letter names (e.g., C to E)'),
        MatchingPair(term: '5th', definition: 'Interval spanning 5 letter names (e.g., C to G)'),
        MatchingPair(term: 'Octave', definition: 'Interval spanning 8 letter names — 12 semitones'),
        MatchingPair(term: 'Melodic interval', definition: 'Two notes played one after the other'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'You must count both the starting and ending note when naming an interval.', isTrue: true, explanation: 'C to E = 3rd because C, D, E are three notes'),
        TrueFalseQuestion(statement: 'C to D is a 3rd.', isTrue: false, explanation: 'C to D is a 2nd (C, D = two letter names)'),
        TrueFalseQuestion(statement: 'A harmonic interval means notes are played simultaneously.', isTrue: true, explanation: 'Harmonic = together; melodic = in sequence'),
        TrueFalseQuestion(statement: 'An octave spans exactly 12 semitones.', isTrue: true, explanation: 'From C to the next C is 12 semitones'),
        TrueFalseQuestion(statement: 'C to B is an octave.', isTrue: false, explanation: 'C to B spans 7 letter names — it is a 7th'),
      ],
      flashcards: [
        FlashCard(front: 'What is an interval?', back: 'The distance in pitch between two notes'),
        FlashCard(front: 'How do you count an interval?', back: 'Count all letter names from lower to upper note, including BOTH the first and last'),
        FlashCard(front: 'What is C to E?', back: 'A 3rd (C, D, E = three letter names)'),
        FlashCard(front: 'Melodic vs harmonic interval?', back: 'Melodic: notes played in sequence; Harmonic: notes played simultaneously'),
        FlashCard(front: 'What is an octave?', back: '8 letter names apart — 12 semitones — same letter name, one register higher'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'INTERVAL', hint: 'The distance in pitch between two notes'),
        AnagramChallenge(answer: 'OCTAVE', hint: '8 notes spanning 12 semitones'),
        AnagramChallenge(answer: 'UNISON', hint: 'Two notes of exactly the same pitch'),
        AnagramChallenge(answer: 'HARMONIC', hint: 'Notes played at the same time'),
      ],
    ),

    '1-11': const LessonExerciseSet(
      chapterNumber: 11,
      partNumber: 1,
      lessonTitle: 'Triads and Chords',
      quiz: [
        ExerciseQuestion(
          question: 'A triad is built by stacking intervals of…',
          answer: '3rds',
          options: ['3rds', '4ths', '5ths', '2nds'],
        ),
        ExerciseQuestion(
          question: 'The tonic triad in C major consists of…',
          answer: 'C E G',
          options: ['C E G', 'C D G', 'C F G', 'C E A'],
        ),
        ExerciseQuestion(
          question: 'A major triad has, from the bottom up…',
          answer: 'Major 3rd + minor 3rd',
          options: ['Major 3rd + minor 3rd', 'Minor 3rd + major 3rd', 'Two major 3rds', 'Perfect 4th + minor 2nd'],
        ),
        ExerciseQuestion(
          question: 'Which degrees form the tonic triad?',
          answer: '1st, 3rd, and 5th',
          options: ['1st, 3rd, and 5th', '1st, 2nd, and 5th', '1st, 4th, and 5th', '2nd, 4th, and 6th'],
        ),
        ExerciseQuestion(
          question: 'An arpeggio is…',
          answer: 'Chord notes played one after another',
          options: ['Chord notes played one after another', 'All chord notes played at once', 'A scale starting on the 3rd', 'A type of ornament'],
        ),
        ExerciseQuestion(
          question: 'A minor triad has, from the bottom up…',
          answer: 'Minor 3rd + major 3rd',
          options: ['Minor 3rd + major 3rd', 'Major 3rd + minor 3rd', 'Two minor 3rds', 'Perfect 4th + major 2nd'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Tonic triad', definition: 'Chord built on the 1st, 3rd, and 5th degrees'),
        MatchingPair(term: 'Major triad', definition: 'Major 3rd + minor 3rd from the bottom (e.g., C–E–G)'),
        MatchingPair(term: 'Minor triad', definition: 'Minor 3rd + major 3rd from the bottom (e.g., A–C–E)'),
        MatchingPair(term: 'Block chord', definition: 'All notes of a chord played simultaneously'),
        MatchingPair(term: 'Arpeggio', definition: 'Notes of a chord played one after another'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'The tonic triad uses the 1st, 3rd, and 5th degrees.', isTrue: true, explanation: 'In C major: C (1st) + E (3rd) + G (5th)'),
        TrueFalseQuestion(statement: 'C E G is the tonic triad of C major.', isTrue: true, explanation: 'C = 1st, E = 3rd, G = 5th of C major'),
        TrueFalseQuestion(statement: 'A minor triad has a major 3rd on the bottom.', isTrue: false, explanation: 'A minor triad has a MINOR 3rd on the bottom and major 3rd on top'),
        TrueFalseQuestion(statement: 'An arpeggio is when chord notes are played separately.', isTrue: true, explanation: 'Also called a broken chord'),
        TrueFalseQuestion(statement: 'All triads consist of two notes.', isTrue: false, explanation: 'A triad has THREE notes — that\'s what "tri" means'),
      ],
      flashcards: [
        FlashCard(front: 'What is a triad?', back: 'A chord of three notes built by stacking two 3rds'),
        FlashCard(front: 'What notes form the tonic triad of C major?', back: 'C E G — the 1st, 3rd, and 5th degrees'),
        FlashCard(front: 'Major triad vs minor triad?', back: 'Major: major 3rd + minor 3rd (e.g., C–E–G); Minor: minor 3rd + major 3rd (e.g., A–C–E)'),
        FlashCard(front: 'Block chord vs arpeggio?', back: 'Block chord: all notes together; Arpeggio (broken chord): notes played one at a time'),
        FlashCard(front: 'The three most important triads in a key?', back: 'I (Tonic), IV (Subdominant), and V (Dominant)'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'TRIAD', hint: 'A chord of three notes'),
        AnagramChallenge(answer: 'CHORD', hint: 'Three or more notes sounded together'),
        AnagramChallenge(answer: 'ARPEGGIO', hint: 'Broken chord — notes played one after another'),
        AnagramChallenge(answer: 'DOMINANT', hint: 'The 5th degree of a scale — basis of chord V'),
      ],
    ),

    '1-12': const LessonExerciseSet(
      chapterNumber: 12,
      partNumber: 1,
      lessonTitle: 'More About Keys — The Circle of Fifths',
      quiz: [
        ExerciseQuestion(
          question: 'Moving CLOCKWISE on the circle of fifths…',
          answer: 'Adds one sharp to the key signature',
          options: ['Adds one sharp to the key signature', 'Adds one flat to the key signature', 'Removes one sharp', 'Changes major to minor'],
        ),
        ExerciseQuestion(
          question: 'How many positions are on the circle of fifths?',
          answer: '12',
          options: ['12', '7', '15', '8'],
        ),
        ExerciseQuestion(
          question: 'E major has how many sharps?',
          answer: '4',
          options: ['4', '3', '5', '2'],
        ),
        ExerciseQuestion(
          question: 'D♭ major has how many flats?',
          answer: '5',
          options: ['5', '4', '6', '3'],
        ),
        ExerciseQuestion(
          question: 'Enharmonic keys are…',
          answer: 'Keys that sound the same but are written differently',
          options: ['Keys that sound the same but are written differently', 'Keys with no sharps or flats', 'Only minor keys', 'Keys a semitone apart'],
        ),
        ExerciseQuestion(
          question: 'The relative minor of E♭ major is…',
          answer: 'C minor',
          options: ['C minor', 'D minor', 'G minor', 'B♭ minor'],
        ),
      ],
      matching: [
        MatchingPair(term: '1 sharp (F♯)', definition: 'G major'),
        MatchingPair(term: '1 flat (B♭)', definition: 'F major'),
        MatchingPair(term: '4 sharps', definition: 'E major'),
        MatchingPair(term: '4 flats', definition: 'A♭ major'),
        MatchingPair(term: 'F♯ major = G♭ major', definition: 'An enharmonic key pair'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'Moving clockwise on the circle of fifths adds one flat.', isTrue: false, explanation: 'Clockwise adds one SHARP; anti-clockwise adds one flat'),
        TrueFalseQuestion(statement: 'B major and C♭ major are enharmonic keys.', isTrue: true, explanation: 'They sound identical — B major has 5♯; C♭ major has 7♭'),
        TrueFalseQuestion(statement: 'E major has 4 sharps.', isTrue: true, explanation: 'E major: F♯, C♯, G♯, D♯'),
        TrueFalseQuestion(statement: 'A♭ major has 4 flats.', isTrue: true, explanation: 'A♭ major: B♭, E♭, A♭, D♭'),
        TrueFalseQuestion(statement: 'The circle of fifths has 12 unique positions.', isTrue: true, explanation: 'One for each of the 12 semitones (or pitch classes)'),
      ],
      flashcards: [
        FlashCard(front: 'What is the circle of fifths?', back: 'A diagram organising all 12 major keys a perfect 5th apart, moving clockwise'),
        FlashCard(front: 'Clockwise on the circle of fifths?', back: 'Each step clockwise adds one more sharp'),
        FlashCard(front: 'Anti-clockwise on the circle of fifths?', back: 'Each step anti-clockwise adds one more flat'),
        FlashCard(front: 'What are enharmonic key pairs?', back: 'Keys that sound the same but are written differently (e.g., F♯ major = G♭ major)'),
        FlashCard(front: 'How many sharps does A major have?', back: '3 sharps — F♯, C♯, G♯'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'CHROMATIC', hint: 'A scale using all 12 semitones'),
        AnagramChallenge(answer: 'ENHARMONIC', hint: 'Same pitch, different letter name'),
        AnagramChallenge(answer: 'TRANSPOSE', hint: 'To rewrite music in a different key'),
        AnagramChallenge(answer: 'FIFTHS', hint: 'The circle of ___ organises all 12 keys'),
      ],
    ),

    '1-13': const LessonExerciseSet(
      chapterNumber: 13,
      partNumber: 1,
      lessonTitle: 'Musical Terms and Signs',
      quiz: [
        ExerciseQuestion(
          question: 'What does "Allegro" mean?',
          answer: 'Fast and lively',
          options: ['Fast and lively', 'Slow', 'Very slow', 'At a walking pace'],
        ),
        ExerciseQuestion(
          question: 'The dynamic marking "ff" means…',
          answer: 'Very loud (fortissimo)',
          options: ['Very loud (fortissimo)', 'Loud (forte)', 'Very soft (pianissimo)', 'Moderately loud'],
        ),
        ExerciseQuestion(
          question: 'A crescendo means…',
          answer: 'Gradually get louder',
          options: ['Gradually get louder', 'Gradually get softer', 'Play suddenly loud', 'Hold the note'],
        ),
        ExerciseQuestion(
          question: 'A staccato dot above a note means…',
          answer: 'Play short and detached',
          options: ['Play short and detached', 'Play long and smooth', 'Accent the note', 'Hold longer than written'],
        ),
        ExerciseQuestion(
          question: 'The Italian word "piano" in music means…',
          answer: 'Soft',
          options: ['Soft', 'Fast', 'Slow', 'Smooth'],
        ),
        ExerciseQuestion(
          question: 'A fermata (𝄐) tells you to…',
          answer: 'Hold longer than written value',
          options: ['Hold longer than written value', 'Repeat from the beginning', 'Play staccato', 'Get softer'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Adagio', definition: 'Slow'),
        MatchingPair(term: 'Andante', definition: 'At a walking pace'),
        MatchingPair(term: 'Forte (f)', definition: 'Loud'),
        MatchingPair(term: 'Diminuendo', definition: 'Gradually getting softer'),
        MatchingPair(term: 'Staccato', definition: 'Short and detached — dot above/below note'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'Presto means very fast.', isTrue: true, explanation: 'Presto is the fastest standard tempo marking'),
        TrueFalseQuestion(statement: 'Piano (p) means loud.', isTrue: false, explanation: 'Piano means SOFT; forte (f) means loud'),
        TrueFalseQuestion(statement: 'A crescendo means getting gradually louder.', isTrue: true, explanation: 'Shown as < or the word cresc.'),
        TrueFalseQuestion(statement: 'Andante means slow.', isTrue: false, explanation: 'Andante means a walking pace — between slow (Adagio) and moderate (Moderato)'),
        TrueFalseQuestion(statement: 'Accent marks show which notes to emphasise.', isTrue: true, explanation: 'The > accent mark means give that note extra weight'),
      ],
      flashcards: [
        FlashCard(front: 'Slowest to fastest: Allegro, Andante, Adagio?', back: 'Adagio (slow) → Andante (walking) → Allegro (fast)'),
        FlashCard(front: 'What does "ff" mean?', back: 'Fortissimo — very loud'),
        FlashCard(front: 'What does "pp" mean?', back: 'Pianissimo — very soft'),
        FlashCard(front: 'What is a crescendo?', back: 'A gradual increase in volume — shown by < or cresc.'),
        FlashCard(front: 'What does diminuendo mean?', back: 'A gradual decrease in volume (also called decrescendo)'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'FORTISSIMO', hint: 'Very loud — ff'),
        AnagramChallenge(answer: 'ANDANTE', hint: 'At a walking pace'),
        AnagramChallenge(answer: 'STACCATO', hint: 'Short and detached'),
        AnagramChallenge(answer: 'CRESCENDO', hint: 'Gradually getting louder'),
      ],
    ),

    // ══════════════════════════════════════════════════════════════
    // PART II
    // ══════════════════════════════════════════════════════════════

    '2-1': const LessonExerciseSet(
      chapterNumber: 1,
      partNumber: 2,
      lessonTitle: 'Revision and Extension of Part I',
      quiz: [
        ExerciseQuestion(
          question: 'A semibreve rest…',
          answer: 'Hangs below the 4th line',
          options: ['Hangs below the 4th line', 'Sits on the 3rd line', 'Has a squiggly shape', 'Has one flag'],
        ),
        ExerciseQuestion(
          question: 'The minim rest…',
          answer: 'Sits on top of the 3rd line',
          options: ['Sits on top of the 3rd line', 'Hangs below the 4th line', 'Looks like a 7', 'Has a stem'],
        ),
        ExerciseQuestion(
          question: 'In simple time signatures, the beat divides into…',
          answer: 'Two equal parts',
          options: ['Two equal parts', 'Three equal parts', 'Four equal parts', 'Unequal parts'],
        ),
        ExerciseQuestion(
          question: 'The melodic minor descending uses which form?',
          answer: 'Natural minor',
          options: ['Natural minor', 'Harmonic minor', 'Chromatic minor', 'Melodic ascending'],
        ),
        ExerciseQuestion(
          question: 'The harmonic minor differs from natural minor because…',
          answer: 'The 7th degree is raised by a semitone',
          options: ['The 7th degree is raised by a semitone', 'The 6th degree is lowered', 'It has no sharps or flats', 'The 3rd degree is raised'],
        ),
        ExerciseQuestion(
          question: 'Which interval is between the 6th and 7th of a harmonic minor?',
          answer: 'Augmented 2nd (3 semitones)',
          options: ['Augmented 2nd (3 semitones)', 'Major 2nd (2 semitones)', 'Minor 3rd', 'Perfect 4th'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Semibreve rest', definition: 'Hangs below the 4th line'),
        MatchingPair(term: 'Minim rest', definition: 'Sits on top of the 3rd line'),
        MatchingPair(term: 'Harmonic minor', definition: 'Natural minor with raised 7th degree'),
        MatchingPair(term: 'Relative minor', definition: 'Shares key signature with its major; starts on 6th degree'),
        MatchingPair(term: 'Tonic triad', definition: '1st, 3rd, and 5th degrees of the scale'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'The minim rest hangs below the 4th line.', isTrue: false, explanation: 'The SEMIBREVE rest hangs below the 4th line; minim rest sits ON TOP of 3rd line'),
        TrueFalseQuestion(statement: 'Simple time signatures include 2/4, 3/4, and 4/4.', isTrue: true, explanation: 'All these beat units divide into two equal parts'),
        TrueFalseQuestion(statement: 'The melodic minor uses the same notes going up and down.', isTrue: false, explanation: 'It raises 6th and 7th ascending; returns to natural minor descending'),
        TrueFalseQuestion(statement: 'A tonic triad is built on the 1st, 3rd, and 5th degrees.', isTrue: true, explanation: 'In C major: C–E–G'),
        TrueFalseQuestion(statement: '4/4 is also called common time.', isTrue: true, explanation: 'It can be shown with the symbol C'),
      ],
      flashcards: [
        FlashCard(front: 'Minim rest vs semibreve rest?', back: 'Semibreve rest hangs below 4th line; minim rest sits on top of the 3rd line'),
        FlashCard(front: 'What is simple time?', back: 'Time signatures where the beat divides into 2 equal parts (2/4, 3/4, 4/4)'),
        FlashCard(front: 'Name the 7 degrees of a scale.', back: 'Tonic, Supertonic, Mediant, Subdominant, Dominant, Submediant, Leading note'),
        FlashCard(front: 'How many flats does E♭ major have?', back: '3 flats — B♭, E♭, A♭'),
        FlashCard(front: 'What is the relative minor of G major?', back: 'E minor — same key signature (1 sharp F♯); starts on 6th degree E'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'SUPERTONIC', hint: 'The 2nd degree of a scale'),
        AnagramChallenge(answer: 'SUBDOMINANT', hint: 'The 4th degree of a scale'),
        AnagramChallenge(answer: 'LEADING', hint: 'The 7th degree — wants to resolve to the tonic'),
        AnagramChallenge(answer: 'MEDIANT', hint: 'The 3rd degree of a scale'),
      ],
    ),

    '2-2': const LessonExerciseSet(
      chapterNumber: 2,
      partNumber: 2,
      lessonTitle: 'Compound Time',
      quiz: [
        ExerciseQuestion(
          question: 'In compound time, each beat divides into…',
          answer: 'Three equal parts',
          options: ['Three equal parts', 'Two equal parts', 'Four equal parts', 'Unequal parts'],
        ),
        ExerciseQuestion(
          question: 'In 6/8 time, how many main beats are in each bar?',
          answer: '2',
          options: ['2', '3', '4', '6'],
        ),
        ExerciseQuestion(
          question: 'The main beat unit in 6/8 time is a…',
          answer: 'Dotted crotchet',
          options: ['Dotted crotchet', 'Crotchet', 'Dotted quaver', 'Minim'],
        ),
        ExerciseQuestion(
          question: 'In 9/8 time, how many dotted-crotchet beats per bar?',
          answer: '3',
          options: ['3', '2', '4', '9'],
        ),
        ExerciseQuestion(
          question: '3/4 and 6/8 differ because…',
          answer: '3/4 has 3 crotchet beats; 6/8 has 2 dotted-crotchet beats',
          options: ['3/4 has 3 crotchet beats; 6/8 has 2 dotted-crotchet beats', 'They are identical', '6/8 is always faster', '3/4 has more quavers'],
        ),
        ExerciseQuestion(
          question: '12/8 has how many dotted-crotchet beats per bar?',
          answer: '4',
          options: ['4', '3', '6', '12'],
        ),
      ],
      matching: [
        MatchingPair(term: '6/8', definition: '2 dotted-crotchet beats per bar'),
        MatchingPair(term: '9/8', definition: '3 dotted-crotchet beats per bar'),
        MatchingPair(term: '12/8', definition: '4 dotted-crotchet beats per bar'),
        MatchingPair(term: 'Compound time', definition: 'Each beat divides into 3 equal parts'),
        MatchingPair(term: 'Simple time', definition: 'Each beat divides into 2 equal parts'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'In compound time the beat divides into three.', isTrue: true, explanation: 'This is the defining feature of compound time'),
        TrueFalseQuestion(statement: '6/8 and 3/4 feel and sound identical.', isTrue: false, explanation: '6/8 has 2 main beats (lilting); 3/4 has 3 beats (waltz)'),
        TrueFalseQuestion(statement: 'In 6/8, there are 6 actual main beats in the bar.', isTrue: false, explanation: 'There are only 2 dotted-crotchet beats; the 6 refers to quavers'),
        TrueFalseQuestion(statement: 'Compound time creates a lilting, jig-like feel.', isTrue: true, explanation: 'The triplet division of the beat gives music a flowing, swinging feel'),
        TrueFalseQuestion(statement: '12/8 has four dotted-crotchet beats per bar.', isTrue: true, explanation: '12 quavers ÷ 3 quavers per beat = 4 beats'),
      ],
      flashcards: [
        FlashCard(front: 'Simple vs compound time?', back: 'Simple: beat divides into 2; Compound: beat divides into 3'),
        FlashCard(front: 'What is the beat in 6/8 time?', back: 'A dotted crotchet (worth 3 quavers)'),
        FlashCard(front: 'Why does 6/8 feel different from 3/4?', back: '6/8 has 2 main beats (ONE-2-3-TWO-2-3); 3/4 has 3 main beats (ONE-2-THREE)'),
        FlashCard(front: 'What types of music use compound time?', back: 'Jigs, barcarolles, many folk songs, and lullabies'),
        FlashCard(front: 'How many quavers are in one bar of 6/8?', back: '6 quavers (2 dotted-crotchet beats × 3 quavers each)'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'COMPOUND', hint: 'Time where the beat divides into three'),
        AnagramChallenge(answer: 'TRIPLET', hint: 'Three notes in the time of two'),
        AnagramChallenge(answer: 'SIMPLE', hint: 'Time where the beat divides into two'),
        AnagramChallenge(answer: 'JIGTIME', hint: 'Lively dance often in 6/8 compound time'),
      ],
    ),

    '2-3': const LessonExerciseSet(
      chapterNumber: 3,
      partNumber: 2,
      lessonTitle: 'Keys and Scales — The Full Range',
      quiz: [
        ExerciseQuestion(
          question: 'C♯ major has how many sharps?',
          answer: '7',
          options: ['7', '5', '6', '4'],
        ),
        ExerciseQuestion(
          question: 'Which pair of major keys are enharmonic?',
          answer: 'F♯ major and G♭ major',
          options: ['F♯ major and G♭ major', 'C and D♭', 'B and A♯', 'E and F♭'],
        ),
        ExerciseQuestion(
          question: 'The chromatic scale uses…',
          answer: 'All 12 semitones within an octave',
          options: ['All 12 semitones within an octave', 'Only white keys', '8 notes following T T S T T T S', 'Only sharps, no flats'],
        ),
        ExerciseQuestion(
          question: 'The whole tone scale divides the octave into…',
          answer: '6 equal whole tones',
          options: ['6 equal whole tones', '7 equal tones', '12 equal semitones', '5 equal steps'],
        ),
        ExerciseQuestion(
          question: 'C♭ major has how many flats?',
          answer: '7',
          options: ['7', '5', '6', '4'],
        ),
        ExerciseQuestion(
          question: 'D♭ major has how many flats?',
          answer: '5',
          options: ['5', '4', '6', '7'],
        ),
      ],
      matching: [
        MatchingPair(term: '7 sharps', definition: 'C♯ major'),
        MatchingPair(term: '7 flats', definition: 'C♭ major'),
        MatchingPair(term: 'F♯ = G♭', definition: 'An enharmonic major key pair'),
        MatchingPair(term: 'Chromatic scale', definition: 'All 12 semitones within an octave'),
        MatchingPair(term: 'Whole tone scale', definition: '6 equal whole tones — dreamlike, ambiguous sound'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'There are 15 major key signatures including enharmonic pairs.', isTrue: true, explanation: '12 unique positions + 3 enharmonic pairs = 15 theoretical key signatures'),
        TrueFalseQuestion(statement: 'G♭ major and F♯ major sound different.', isTrue: false, explanation: 'They are enharmonic — identical pitch, just written differently'),
        TrueFalseQuestion(statement: 'The chromatic scale has 12 different pitches within an octave.', isTrue: true, explanation: 'All 12 semitones are included'),
        TrueFalseQuestion(statement: 'The whole tone scale has 7 notes.', isTrue: false, explanation: 'The whole tone scale has 6 notes (6 whole tones fit within an octave)'),
        TrueFalseQuestion(statement: 'C♯ major has 7 sharps.', isTrue: true, explanation: 'C♯ major is the most sharp-heavy key signature'),
      ],
      flashcards: [
        FlashCard(front: 'The three enharmonic major key pairs?', back: 'B = C♭, F♯ = G♭, C♯ = D♭'),
        FlashCard(front: 'What is a chromatic scale?', back: 'A scale using all 12 semitones within an octave'),
        FlashCard(front: 'What is the whole tone scale?', back: 'A scale of 6 equal whole tones — has a dreamlike, ambiguous quality (used by Debussy)'),
        FlashCard(front: 'How many sharps does B major have?', back: '5 sharps — F♯, C♯, G♯, D♯, A♯'),
        FlashCard(front: 'How many flats does A♭ major have?', back: '4 flats — B♭, E♭, A♭, D♭'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'CHROMATIC', hint: 'Scale using all 12 semitones'),
        AnagramChallenge(answer: 'ENHARMONIC', hint: 'Same sound, different written spelling'),
        AnagramChallenge(answer: 'TRANSPOSE', hint: 'To write music in a different key'),
        AnagramChallenge(answer: 'WHOLETONE', hint: 'Scale with 6 equal steps — used by Debussy'),
      ],
    ),

    '2-4': const LessonExerciseSet(
      chapterNumber: 4,
      partNumber: 2,
      lessonTitle: 'Intervals — Quality and Inversion',
      quiz: [
        ExerciseQuestion(
          question: 'A perfect 5th inverts to…',
          answer: 'A perfect 4th',
          options: ['A perfect 4th', 'A minor 4th', 'A major 4th', 'A diminished 5th'],
        ),
        ExerciseQuestion(
          question: 'When inverting, the two interval numbers add up to…',
          answer: '9',
          options: ['9', '8', '7', '10'],
        ),
        ExerciseQuestion(
          question: 'A major 3rd inverts to…',
          answer: 'A minor 6th',
          options: ['A minor 6th', 'A major 6th', 'A minor 3rd', 'A perfect 6th'],
        ),
        ExerciseQuestion(
          question: 'An augmented interval inverts to…',
          answer: 'A diminished interval',
          options: ['A diminished interval', 'Another augmented interval', 'A perfect interval', 'A minor interval'],
        ),
        ExerciseQuestion(
          question: 'A perfect 4th is how many semitones?',
          answer: '5',
          options: ['5', '4', '6', '3'],
        ),
        ExerciseQuestion(
          question: 'A major 6th is how many semitones?',
          answer: '9',
          options: ['9', '8', '10', '7'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Perfect intervals', definition: 'Unison, 4th, 5th, and octave'),
        MatchingPair(term: 'Major/minor intervals', definition: '2nds, 3rds, 6ths, and 7ths'),
        MatchingPair(term: 'Augmented', definition: 'One semitone wider than major or perfect'),
        MatchingPair(term: 'Diminished', definition: 'One semitone narrower than minor or perfect'),
        MatchingPair(term: 'Inversion rule', definition: 'Numbers add to 9; major ↔ minor; perfect stays perfect'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A perfect 5th inverts to a perfect 4th.', isTrue: true, explanation: '5 + 4 = 9; perfect inverts to perfect'),
        TrueFalseQuestion(statement: 'When you invert a major interval, it becomes augmented.', isTrue: false, explanation: 'A major interval inverts to MINOR; augmented inverts to diminished'),
        TrueFalseQuestion(statement: 'A major 3rd inverts to a minor 6th.', isTrue: true, explanation: '3 + 6 = 9; major ↔ minor'),
        TrueFalseQuestion(statement: 'An augmented interval inverts to another augmented interval.', isTrue: false, explanation: 'Augmented inverts to DIMINISHED'),
        TrueFalseQuestion(statement: 'All inversion pairs add up to 9.', isTrue: true, explanation: 'E.g., 2nd ↔ 7th; 3rd ↔ 6th; 4th ↔ 5th'),
      ],
      flashcards: [
        FlashCard(front: 'How do you invert an interval?', back: 'Take the lower note and place it an octave higher (or move the upper note an octave lower)'),
        FlashCard(front: 'Interval number rule for inversion?', back: 'Original number + inversion number = 9 (e.g., 3rd inverts to a 6th)'),
        FlashCard(front: 'What is an augmented interval?', back: 'One semitone wider than the equivalent major or perfect interval'),
        FlashCard(front: 'What is a diminished interval?', back: 'One semitone narrower than the equivalent minor or perfect interval'),
        FlashCard(front: 'A major 3rd inverts to…', back: 'A minor 6th (3 + 6 = 9; major ↔ minor on inversion)'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'INVERSION', hint: 'Flipping an interval — lower note goes up an octave'),
        AnagramChallenge(answer: 'AUGMENTED', hint: 'One semitone more than perfect or major'),
        AnagramChallenge(answer: 'DIMINISHED', hint: 'One semitone less than perfect or minor'),
        AnagramChallenge(answer: 'PERFECT', hint: 'Quality of unisons, 4ths, 5ths, and octaves'),
      ],
    ),

    '2-5': const LessonExerciseSet(
      chapterNumber: 5,
      partNumber: 2,
      lessonTitle: 'Chords and Harmony',
      quiz: [
        ExerciseQuestion(
          question: 'A perfect cadence moves from…',
          answer: 'Chord V to chord I',
          options: ['Chord V to chord I', 'Chord I to chord V', 'Chord IV to chord I', 'Chord V to chord VI'],
        ),
        ExerciseQuestion(
          question: 'The "Amen" cadence is called…',
          answer: 'Plagal cadence (IV → I)',
          options: ['Plagal cadence (IV → I)', 'Perfect cadence (V → I)', 'Imperfect cadence (I → V)', 'Interrupted cadence (V → VI)'],
        ),
        ExerciseQuestion(
          question: 'An interrupted cadence ends on…',
          answer: 'Chord VI (a surprise)',
          options: ['Chord VI (a surprise)', 'Chord I (tonic)', 'Chord IV', 'Chord V'],
        ),
        ExerciseQuestion(
          question: 'In first inversion, which note is in the bass?',
          answer: 'The 3rd',
          options: ['The 3rd', 'The root', 'The 5th', 'The 7th'],
        ),
        ExerciseQuestion(
          question: 'In a major key, which triads are major?',
          answer: 'I, IV, and V',
          options: ['I, IV, and V', 'II, III, and VI', 'All of them', 'Only I'],
        ),
        ExerciseQuestion(
          question: 'An imperfect cadence ends on…',
          answer: 'Chord V (unresolved)',
          options: ['Chord V (unresolved)', 'Chord I (resolved)', 'Chord IV', 'Chord VI'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Perfect cadence', definition: 'V → I — conclusive and final'),
        MatchingPair(term: 'Imperfect cadence', definition: 'Ends on V — unresolved, like a question'),
        MatchingPair(term: 'Plagal cadence', definition: 'IV → I — the "Amen" cadence'),
        MatchingPair(term: 'Interrupted cadence', definition: 'V → VI — a surprise, avoids the expected I'),
        MatchingPair(term: 'First inversion', definition: 'The 3rd of the chord is the lowest (bass) note'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A perfect cadence resolves from V to I.', isTrue: true, explanation: 'The dominant resolves to the tonic — the most conclusive ending'),
        TrueFalseQuestion(statement: 'The plagal cadence is called the "Amen" cadence.', isTrue: true, explanation: 'IV → I — used in many hymns on the word "Amen"'),
        TrueFalseQuestion(statement: 'An interrupted cadence ends on the tonic chord.', isTrue: false, explanation: 'It ends on chord VI — a surprise instead of the expected I'),
        TrueFalseQuestion(statement: 'In second inversion, the 3rd is in the bass.', isTrue: false, explanation: 'In second inversion the 5th is in the bass; in first inversion the 3rd is in the bass'),
        TrueFalseQuestion(statement: 'In a major key, chords I, IV, and V are major triads.', isTrue: true, explanation: 'The other triads (II, III, VI) are minor; VII is diminished'),
      ],
      flashcards: [
        FlashCard(front: 'What is a perfect cadence?', back: 'Chord V → Chord I — sounds conclusive and final'),
        FlashCard(front: 'What is a plagal cadence?', back: 'Chord IV → Chord I — the "Amen" cadence'),
        FlashCard(front: 'What is an imperfect cadence?', back: 'Any cadence ending on chord V — sounds unresolved, like a question mark'),
        FlashCard(front: 'What is an interrupted cadence?', back: 'Chord V → Chord VI — a surprise that avoids the expected resolution to I'),
        FlashCard(front: 'Root position, 1st inversion, 2nd inversion?', back: 'Root in bass; 3rd in bass; 5th in bass'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'CADENCE', hint: 'A harmonic ending — how a phrase concludes'),
        AnagramChallenge(answer: 'PLAGAL', hint: 'IV to I cadence — often used for "Amen"'),
        AnagramChallenge(answer: 'DOMINANT', hint: 'Chord V — the most important chord after the tonic'),
        AnagramChallenge(answer: 'HARMONY', hint: 'How chords are built and progress'),
      ],
    ),

    '2-6': const LessonExerciseSet(
      chapterNumber: 6,
      partNumber: 2,
      lessonTitle: 'Ornaments and Decorations',
      quiz: [
        ExerciseQuestion(
          question: 'A trill is…',
          answer: 'Rapid alternation between a note and the one above',
          options: ['Rapid alternation between a note and the one above', 'Four notes: upper, main, lower, main', 'A crushed note before the beat', 'An on-beat ornamental note'],
        ),
        ExerciseQuestion(
          question: 'An acciaccatura is written as…',
          answer: 'A small note with a slash through its stem',
          options: ['A small note with a slash through its stem', 'A small note without a slash', 'A wavy line above the note', 'A symbol written above the note'],
        ),
        ExerciseQuestion(
          question: 'A turn ornament has how many notes?',
          answer: '4 notes',
          options: ['4 notes', '2 notes', '3 notes', '5 notes'],
        ),
        ExerciseQuestion(
          question: 'An appoggiatura takes how much of the main note\'s value?',
          answer: 'Half',
          options: ['Half', 'A quarter', 'A third', 'All of it'],
        ),
        ExerciseQuestion(
          question: 'A mordent is…',
          answer: 'A quick flick to the lower or upper neighbour',
          options: ['A quick flick to the lower or upper neighbour', 'Four notes in sequence', 'A slow alternation', 'A crushed note'],
        ),
        ExerciseQuestion(
          question: 'In Baroque music, a trill typically starts on…',
          answer: 'The upper note',
          options: ['The upper note', 'The main note', 'The lower note', 'The octave above'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Trill (tr)', definition: 'Rapid alternation between written note and upper neighbour'),
        MatchingPair(term: 'Turn', definition: 'Upper – main – lower – main (four-note ornament)'),
        MatchingPair(term: 'Acciaccatura', definition: 'Crushed grace note before the beat (has a slash through stem)'),
        MatchingPair(term: 'Appoggiatura', definition: 'On-beat ornamental note taking half the main note\'s value'),
        MatchingPair(term: 'Mordent', definition: 'Quick flick to lower (or upper) neighbour note'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'A trill involves rapid alternation with the note above.', isTrue: true, explanation: 'Shown as "tr" — alternates with the diatonic note above'),
        TrueFalseQuestion(statement: 'An acciaccatura is played on the beat.', isTrue: false, explanation: 'The acciaccatura is played as fast as possible BEFORE the main beat'),
        TrueFalseQuestion(statement: 'An appoggiatura takes half the value of the main note.', isTrue: true, explanation: 'A dotted main note gives the appoggiatura two-thirds'),
        TrueFalseQuestion(statement: 'A turn always has three notes.', isTrue: false, explanation: 'A turn has FOUR notes: upper, main, lower, main'),
        TrueFalseQuestion(statement: 'Ornaments change the underlying harmony of a piece.', isTrue: false, explanation: 'Ornaments decorate the melody without changing the harmony'),
      ],
      flashcards: [
        FlashCard(front: 'What is a trill?', back: 'Rapid alternation between the written note and the note one step above (shown as "tr")'),
        FlashCard(front: 'What is an acciaccatura?', back: 'A "crushed note" — a very short grace note played just before the main note (has a slash through its stem)'),
        FlashCard(front: 'What is an appoggiatura?', back: 'An ornamental note on the beat that takes half the main note\'s value'),
        FlashCard(front: 'What is a turn?', back: 'A four-note ornament: upper note → main note → lower note → main note'),
        FlashCard(front: 'What is a mordent?', back: 'A quick alternation with the lower neighbour (lower mordent) or upper neighbour (upper mordent)'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'ORNAMENT', hint: 'A decoration added to the melody'),
        AnagramChallenge(answer: 'TRILL', hint: 'Rapid alternation with the upper note (tr)'),
        AnagramChallenge(answer: 'MORDENT', hint: 'Quick flick to a neighbouring note'),
        AnagramChallenge(answer: 'GRACE', hint: '___ note — small decorative note before the main note'),
      ],
    ),

    '2-7': const LessonExerciseSet(
      chapterNumber: 7,
      partNumber: 2,
      lessonTitle: 'Voice, Instrument and Score Reading',
      quiz: [
        ExerciseQuestion(
          question: 'Which is the HIGHEST female voice type?',
          answer: 'Soprano',
          options: ['Soprano', 'Mezzo-soprano', 'Alto', 'Contralto'],
        ),
        ExerciseQuestion(
          question: 'A B♭ clarinet sounds…',
          answer: 'A tone lower than written',
          options: ['A tone lower than written', 'A tone higher than written', 'At the same pitch', 'A perfect 5th higher'],
        ),
        ExerciseQuestion(
          question: 'The alto clef places middle C on which line?',
          answer: '3rd line',
          options: ['3rd line', '2nd line', '4th line', '1st line'],
        ),
        ExerciseQuestion(
          question: 'Which instrument traditionally reads from the alto clef?',
          answer: 'Viola',
          options: ['Viola', 'Violin', 'Cello', 'Bass'],
        ),
        ExerciseQuestion(
          question: 'A horn in F sounds…',
          answer: 'A perfect 5th lower than written',
          options: ['A perfect 5th lower than written', 'A perfect 5th higher', 'A tone lower', 'At the same pitch'],
        ),
        ExerciseQuestion(
          question: 'A full score shows…',
          answer: 'All parts simultaneously',
          options: ['All parts simultaneously', 'Only the melody line', 'Only the bass line', 'The conductor\'s notes only'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Soprano', definition: 'Highest female voice — approximately C4 to C6'),
        MatchingPair(term: 'Bass', definition: 'Lowest male voice — approximately E2 to E4'),
        MatchingPair(term: 'Alto clef', definition: 'C clef on the 3rd line — used for viola'),
        MatchingPair(term: 'Transposing instrument', definition: 'Sounds a different pitch than the written note'),
        MatchingPair(term: 'B♭ clarinet', definition: 'Sounds a tone lower than written'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'The soprano is the highest female voice.', isTrue: true, explanation: 'Soprano > Mezzo-soprano > Alto in descending pitch'),
        TrueFalseQuestion(statement: 'The tenor voice sounds at the same pitch as written in treble clef.', isTrue: false, explanation: 'Tenors use treble clef but sound an octave LOWER than written'),
        TrueFalseQuestion(statement: 'A viola reads from the alto clef.', isTrue: true, explanation: 'The alto clef positions middle C on the 3rd line, ideal for viola range'),
        TrueFalseQuestion(statement: 'A horn in F sounds a perfect 5th higher than written.', isTrue: false, explanation: 'A horn in F sounds a perfect 5th LOWER than written'),
        TrueFalseQuestion(statement: 'A score shows all parts; players read from individual parts.', isTrue: true, explanation: 'The conductor reads the full score; each player reads their own part'),
      ],
      flashcards: [
        FlashCard(front: 'Four main voice types, high to low?', back: 'Soprano, Alto (female); Tenor, Bass (male)'),
        FlashCard(front: 'What is a transposing instrument?', back: 'One that sounds a different pitch than written (e.g., B♭ clarinet sounds a tone lower)'),
        FlashCard(front: 'What is the alto clef?', back: 'A C clef placing middle C on the 3rd line — used for viola'),
        FlashCard(front: 'What is a score?', back: 'A full layout showing all musical parts simultaneously, one above the other'),
        FlashCard(front: 'Why do tenors read treble clef?', back: 'They use treble clef but the sound is an octave lower than written'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'SOPRANO', hint: 'The highest female singing voice'),
        AnagramChallenge(answer: 'TENOR', hint: 'The highest male singing voice'),
        AnagramChallenge(answer: 'SCORE', hint: 'Full document showing all musical parts'),
        AnagramChallenge(answer: 'TREBLE', hint: 'Clef used for high-pitched music'),
      ],
    ),

    '2-8': const LessonExerciseSet(
      chapterNumber: 8,
      partNumber: 2,
      lessonTitle: 'Form and Structure',
      quiz: [
        ExerciseQuestion(
          question: 'Binary form has how many main sections?',
          answer: '2',
          options: ['2', '3', '4', '1'],
        ),
        ExerciseQuestion(
          question: 'Which form follows the pattern ABA?',
          answer: 'Ternary form',
          options: ['Ternary form', 'Binary form', 'Rondo form', 'Sonata form'],
        ),
        ExerciseQuestion(
          question: 'In rondo form, the returning "A" section is called…',
          answer: 'The main theme (refrain)',
          options: ['The main theme (refrain)', 'An episode', 'The exposition', 'The development'],
        ),
        ExerciseQuestion(
          question: 'In sonata form, where are the main themes introduced?',
          answer: 'The exposition',
          options: ['The exposition', 'The development', 'The recapitulation', 'The coda'],
        ),
        ExerciseQuestion(
          question: 'In "Theme and Variations," the theme is…',
          answer: 'Restated repeatedly with modifications',
          options: ['Restated repeatedly with modifications', 'Played only once', 'Replaced by new themes', 'Played in multiple keys'],
        ),
        ExerciseQuestion(
          question: 'In sonata form, the development section…',
          answer: 'Fragments and develops themes from the exposition',
          options: ['Fragments and develops themes from the exposition', 'Introduces new themes', 'Repeats the exposition exactly', 'Ends the piece'],
        ),
      ],
      matching: [
        MatchingPair(term: 'Binary form (AB)', definition: 'Two contrasting sections — common in Baroque dances'),
        MatchingPair(term: 'Ternary form (ABA)', definition: 'Three sections with a return — very common in the Classical era'),
        MatchingPair(term: 'Rondo (ABACA)', definition: 'Main theme returns between contrasting episodes'),
        MatchingPair(term: 'Sonata form', definition: 'Exposition → Development → Recapitulation'),
        MatchingPair(term: 'Theme and Variations', definition: 'A theme restated with progressively altered repetitions'),
      ],
      trueFalse: [
        TrueFalseQuestion(statement: 'Ternary form has the structure ABA.', isTrue: true, explanation: 'Opening section A, contrasting B, return of A'),
        TrueFalseQuestion(statement: 'Binary form has three main sections.', isTrue: false, explanation: 'Binary means TWO sections — AB'),
        TrueFalseQuestion(statement: 'In rondo form, the "A" section never returns.', isTrue: false, explanation: 'The "A" section KEEPS returning — that is the point of rondo'),
        TrueFalseQuestion(statement: 'The exposition in sonata form introduces the main themes.', isTrue: true, explanation: 'Often in two contrasting keys — tonic and dominant'),
        TrueFalseQuestion(statement: 'Theme and Variations always keeps the melody exactly the same.', isTrue: false, explanation: 'The theme is progressively altered in each variation'),
      ],
      flashcards: [
        FlashCard(front: 'What is binary form?', back: 'Two contrasting sections (AB), each usually repeated — common in Baroque dances'),
        FlashCard(front: 'What is ternary form?', back: 'Three sections (ABA) — opening theme, contrasting middle, return of opening'),
        FlashCard(front: 'What is rondo form?', back: 'A main theme (A) that keeps returning between contrasting episodes (ABACA...)'),
        FlashCard(front: 'Three sections of sonata form?', back: 'Exposition (introduce themes) → Development (develop them) → Recapitulation (return in tonic key)'),
        FlashCard(front: 'What is "Theme and Variations"?', back: 'A theme restated repeatedly, each time altered in melody, rhythm, harmony, or texture'),
      ],
      anagrams: [
        AnagramChallenge(answer: 'SONATA', hint: 'Form with exposition, development, and recapitulation'),
        AnagramChallenge(answer: 'TERNARY', hint: 'ABA form — three sections with a return'),
        AnagramChallenge(answer: 'BINARY', hint: 'AB form — two contrasting sections'),
        AnagramChallenge(answer: 'RONDO', hint: 'Form where the main theme keeps returning'),
      ],
    ),
  };
}
