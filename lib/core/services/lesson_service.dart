import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';
import '../constants/app_constants.dart';

class LessonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Fetch lessons ────────────────────────────────────────────────────────

  Future<List<LessonModel>> getLessonsForPart(int partNumber) async {
    final snap = await _db
        .collection(AppConstants.lessonsCollection)
        .where('partNumber', isEqualTo: partNumber)
        .get();
    final lessons = snap.docs.map((d) => LessonModel.fromFirestore(d)).toList();
    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  Stream<List<LessonModel>> watchLessonsForPart(int partNumber) {
    return _db
        .collection(AppConstants.lessonsCollection)
        .where('partNumber', isEqualTo: partNumber)
        .snapshots()
        .map((snap) {
          final lessons =
              snap.docs.map((d) => LessonModel.fromFirestore(d)).toList();
          lessons.sort((a, b) => a.order.compareTo(b.order));
          return lessons;
        });
  }

  Future<LessonModel?> getLesson(String lessonId) async {
    final doc = await _db
        .collection(AppConstants.lessonsCollection)
        .doc(lessonId)
        .get();
    if (!doc.exists) return null;
    return LessonModel.fromFirestore(doc);
  }

  // ─── Progress ─────────────────────────────────────────────────────────────

  Future<Map<String, LessonProgress>> getLessonProgressForUser(
      String uid) async {
    final snap = await _db
        .collection(AppConstants.lessonProgressCollection)
        .doc(uid)
        .collection('lessons')
        .get();
    return {
      for (final doc in snap.docs)
        doc.id: LessonProgress.fromFirestore(doc)
    };
  }

  Stream<Map<String, LessonProgress>> watchLessonProgressForUser(String uid) {
    return _db
        .collection(AppConstants.lessonProgressCollection)
        .doc(uid)
        .collection('lessons')
        .snapshots()
        .map((snap) => {
              for (final doc in snap.docs)
                doc.id: LessonProgress.fromFirestore(doc)
            });
  }

  Future<void> markLessonComplete(String uid, String lessonId) async {
    await _db
        .collection(AppConstants.lessonProgressCollection)
        .doc(uid)
        .collection('lessons')
        .doc(lessonId)
        .set(LessonProgress(
          lessonId: lessonId,
          completed: true,
          completedAt: DateTime.now(),
        ).toFirestore());
  }

  Future<bool> isLessonCompleted(String uid, String lessonId) async {
    final doc = await _db
        .collection(AppConstants.lessonProgressCollection)
        .doc(uid)
        .collection('lessons')
        .doc(lessonId)
        .get();
    return doc.exists && (doc.data()?['completed'] == true);
  }

  // ─── Count completed lessons ──────────────────────────────────────────────

  Future<int> countCompletedLessons(String uid) async {
    final snap = await _db
        .collection(AppConstants.lessonProgressCollection)
        .doc(uid)
        .collection('lessons')
        .where('completed', isEqualTo: true)
        .get();
    return snap.docs.length;
  }

  // ─── Seed lessons (call once from teacher account to populate Firestore) ──

  Future<void> seedLessons() async {
    // Clear existing to avoid duplicates
    final existing =
        await _db.collection(AppConstants.lessonsCollection).get();
    final deleteBatch = _db.batch();
    for (final doc in existing.docs) deleteBatch.delete(doc.reference);
    await deleteBatch.commit();

    // Write in batches of 20
    const batchSize = 20;
    for (int i = 0; i < _seedLessons.length; i += batchSize) {
      final batch = _db.batch();
      final end = (i + batchSize > _seedLessons.length)
          ? _seedLessons.length
          : i + batchSize;
      for (final lesson in _seedLessons.sublist(i, end)) {
        final ref = _db.collection(AppConstants.lessonsCollection).doc();
        batch.set(ref, lesson);
      }
      await batch.commit();
    }
  }

  // ─── Seed data ────────────────────────────────────────────────────────────
  // Based on AB Guide to Music Theory — Eric Taylor (Parts I & II)
  static final List<Map<String, dynamic>> _seedLessons = [
    // ════════════════════ PART I ════════════════════════════════════════════
    {
      'title': 'Sounds and Notes',
      'chapterNumber': 1,
      'partNumber': 1,
      'order': 1,
      'iconName': 'music_note',
      'content': {
        'text':
            'Music begins with sound — vibrations in the air that our ears interpret as pitch, rhythm, and tone. '
            'When a sound has a definite, recognisable pitch, we call it a musical note.\n\n'
            'Notes are named using the first seven letters of the alphabet: A B C D E F G. '
            'After G, the sequence repeats: A B C D E F G A B C... and so on. '
            'When the same letter name repeats, the note sounds higher but has the same musical character — '
            'this distance is called an octave.\n\n'
            'On a piano keyboard you can clearly see the pattern of notes. The white keys are named A–G, '
            'and the black keys are sharps or flats of the notes beside them. '
            'Middle C (C4) is the C nearest the centre of a standard piano — it is an important reference point for all musicians.\n\n'
            'Written music uses symbols called notes placed on a grid of lines to show both the pitch (how high or low) '
            'and the duration (how long) of each sound.',
        'imageUrls': [],
        'keyPoints': [
          'Musical notes are sounds with a definite pitch',
          'Notes are named A B C D E F G, then the pattern repeats',
          'An octave is the interval between one note and the next note of the same name',
          'Middle C is a central reference point for all musicians',
          'Written notes show both pitch and duration',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'The Stave, Clefs and Notes',
      'chapterNumber': 2,
      'partNumber': 1,
      'order': 2,
      'iconName': 'queue_music',
      'content': {
        'text':
            'Music is written on a set of five horizontal lines called a stave (or staff). '
            'Notes are placed on the lines or in the spaces between them. '
            'The higher a note is placed on the stave, the higher its pitch.\n\n'
            'A clef is a symbol placed at the very beginning of the stave. '
            'It fixes the exact pitch of all notes on that stave.\n\n'
            'The Treble Clef (𝄞) curls around the second line from the bottom, '
            'making that line G above middle C (G4). It is used for higher-pitched parts — '
            'violin, flute, oboe, trumpet, and the right hand of piano music.\n\n'
            'The Bass Clef (𝄢) has two dots that surround the fourth line from the bottom, '
            'making it F below middle C (F3). It is used for lower-pitched parts — '
            'cello, double bass, tuba, bassoon, and the left hand of piano music.\n\n'
            'When notes go beyond the five lines of the stave, short extra lines called ledger lines are added above or below.',
        'imageUrls': [],
        'keyPoints': [
          'A stave has 5 lines and 4 spaces',
          'Treble clef fixes the 2nd line as G4 (above middle C)',
          'Bass clef fixes the 4th line as F3 (below middle C)',
          'Notes sit on lines or in spaces — higher placement = higher pitch',
          'Ledger lines extend the stave above or below when needed',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Note Values',
      'chapterNumber': 3,
      'partNumber': 1,
      'order': 3,
      'iconName': 'timer',
      'content': {
        'text':
            'Every note has a shape that tells us its duration — how long to hold the sound. '
            'Note values are relative: each one is exactly half the length of the one above it.\n\n'
            '• Semibreve (whole note) — an open oval with no stem; lasts 4 crotchet beats\n'
            '• Minim (half note) — an open oval with a stem; lasts 2 crotchet beats\n'
            '• Crotchet (quarter note) — a filled oval with a stem; lasts 1 beat\n'
            '• Quaver (eighth note) — a filled oval with a stem and one flag; lasts ½ beat\n'
            '• Semiquaver (sixteenth note) — a filled oval with a stem and two flags; lasts ¼ beat\n\n'
            'Quavers and semiquavers can be joined together with beams (thick horizontal lines) '
            'instead of individual flags, making music easier to read.\n\n'
            'The crotchet is the standard unit of beat in most music. '
            'When we count "1 2 3 4" in a bar, each count usually equals one crotchet.',
        'imageUrls': [],
        'keyPoints': [
          'Semibreve = 4 beats (open oval, no stem)',
          'Minim = 2 beats (open oval with stem)',
          'Crotchet = 1 beat (filled oval with stem)',
          'Quaver = ½ beat (1 flag); Semiquaver = ¼ beat (2 flags)',
          'Each note value is exactly half the duration of the one above it',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Time Signatures and Bar Lines',
      'chapterNumber': 4,
      'partNumber': 1,
      'order': 4,
      'iconName': 'format_list_numbered',
      'content': {
        'text':
            'Music is divided into equal units of time called bars (or measures) by vertical bar lines drawn across the stave.\n\n'
            'At the beginning of a piece, after the clef and key signature, we find the time signature — '
            'two numbers stacked on top of each other.\n\n'
            'The TOP number tells us how many beats are in each bar.\n'
            'The BOTTOM number tells us what type of note equals one beat '
            '(4 = crotchet, 2 = minim, 8 = quaver).\n\n'
            'Common time signatures:\n'
            '• 4/4 — four crotchet beats per bar (very common; also shown as 𝄴)\n'
            '• 3/4 — three crotchet beats per bar (waltz feel; ONE-two-three, ONE-two-three)\n'
            '• 2/4 — two crotchet beats per bar (march feel; ONE-two, ONE-two)\n'
            '• 2/2 — two minim beats per bar (also called alla breve or cut common time 𝄵)\n\n'
            'A double bar line (two thin lines) marks the end of a section. '
            'A final bar line (one thin + one thick line) marks the very end of a piece.',
        'imageUrls': [],
        'keyPoints': [
          'Bar lines divide music into equal groups of beats (bars)',
          'Top number of time signature = beats per bar',
          'Bottom number = note value receiving one beat (4 = crotchet)',
          '4/4 and 3/4 are the most common time signatures',
          'A double bar line ends a section; a final bar line ends the piece',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Dotted Notes and Ties',
      'chapterNumber': 5,
      'partNumber': 1,
      'order': 5,
      'iconName': 'radio_button_checked',
      'content': {
        'text':
            'A dot placed immediately after a note adds half of that note\'s value to it.\n'
            '• Dotted semibreve = 4 + 2 = 6 beats\n'
            '• Dotted minim = 2 + 1 = 3 beats\n'
            '• Dotted crotchet = 1 + ½ = 1½ beats\n'
            '• Dotted quaver = ½ + ¼ = ¾ beat\n\n'
            'A tie is a curved line that connects two notes of exactly the SAME pitch. '
            'The second note is not struck again — you simply hold the first note for the combined total duration. '
            'Ties are used to extend a note across a bar line, or to create durations that a single note value cannot express.\n\n'
            'It is important not to confuse a tie with a slur. A slur also looks like a curved line, '
            'but it connects notes of DIFFERENT pitches and means "play smoothly" (legato). '
            'Ties are about duration; slurs are about articulation.',
        'imageUrls': [],
        'keyPoints': [
          'A dot after a note adds half its value (dotted minim = 3 beats)',
          'Dotted crotchet = 1½ beats; dotted quaver = ¾ beat',
          'A tie connects two notes of the SAME pitch — hold, do not restrike',
          'Ties are used to extend notes across bar lines',
          'Slur = different pitches, means legato (smooth); tie = same pitch, extends duration',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Scales and Keys — The Major Scale',
      'chapterNumber': 6,
      'partNumber': 1,
      'order': 6,
      'iconName': 'piano',
      'content': {
        'text':
            'A scale is an ordered sequence of notes rising (or falling) stepwise from one note to the same note an octave higher. '
            'The word "scale" comes from the Italian "scala" meaning ladder.\n\n'
            'Every major scale follows the same pattern of tones (T) and semitones (S):\n'
            'T – T – S – T – T – T – S\n\n'
            'A semitone is the smallest step in Western music — the distance between two adjacent keys on a piano '
            '(e.g., E to F, or B to C, or C to C♯). A tone equals two semitones.\n\n'
            'The C major scale: C D E F G A B C\n'
            'It uses only the white keys and perfectly demonstrates the T-T-S-T-T-T-S pattern.\n\n'
            'The key of a piece of music refers to which scale it is based on. '
            'A piece "in C major" uses the notes of the C major scale and feels centred on C (the tonic).\n\n'
            'Other major scales require sharps or flats to maintain the correct pattern of tones and semitones.',
        'imageUrls': [],
        'keyPoints': [
          'Major scale pattern: T T S T T T S (where T = tone, S = semitone)',
          'Semitone = smallest interval (adjacent piano keys)',
          'Tone = 2 semitones',
          'C major: C D E F G A B C — no sharps or flats',
          'The key is the scale a piece is based on; the tonic is its home note',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Sharps, Flats and Naturals',
      'chapterNumber': 7,
      'partNumber': 1,
      'order': 7,
      'iconName': 'tune',
      'content': {
        'text':
            'Accidentals are symbols that alter the pitch of a note by a semitone.\n\n'
            '• Sharp (♯) — raises a note by one semitone. F♯ is one semitone higher than F.\n'
            '• Flat (♭) — lowers a note by one semitone. B♭ is one semitone lower than B.\n'
            '• Natural (♮) — cancels a previous sharp or flat and returns the note to its unaltered pitch.\n\n'
            'An accidental placed before a note applies to every note on that same line or space '
            'for the remainder of the bar — unless cancelled earlier by a natural sign. '
            'The accidental does NOT carry over into the next bar.\n\n'
            'Enharmonic equivalents are two notes that sound identical but are written differently: '
            'F♯ and G♭ are the same pitch on a piano, but they have different names in different musical contexts.\n\n'
            'A double sharp (𝄪) raises a note by two semitones. A double flat (𝄫) lowers by two semitones.',
        'imageUrls': [],
        'keyPoints': [
          'Sharp ♯ raises a note one semitone; flat ♭ lowers one semitone',
          'Natural ♮ cancels a sharp or flat within the bar',
          'An accidental applies to all notes on that pitch for the rest of the bar',
          'Enharmonic equivalents: same sound, different name (e.g., F♯ = G♭)',
          'Double sharp 𝄪 = +2 semitones; double flat 𝄫 = −2 semitones',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Tones and Semitones — More Major Scales',
      'chapterNumber': 8,
      'partNumber': 1,
      'order': 8,
      'iconName': 'equalizer',
      'content': {
        'text':
            'We can build a major scale starting on any note, as long as we follow the T-T-S-T-T-T-S pattern. '
            'To maintain this pattern on scales other than C major, we need sharps or flats.\n\n'
            'G Major Scale: G A B C D E F♯ G\n'
            'Starting on G and applying the pattern forces us to raise F to F♯.\n'
            'G major has ONE sharp: F♯\n\n'
            'D Major Scale: D E F♯ G A B C♯ D\n'
            'D major has TWO sharps: F♯ and C♯\n\n'
            'F Major Scale: F G A B♭ C D E F\n'
            'F major has ONE flat: B♭\n\n'
            'The key signature — written at the beginning of each stave — tells us which notes '
            'are always sharp or flat in a piece, saving us from writing accidentals on every single note.\n\n'
            'The order in which sharps are added: F♯, C♯, G♯, D♯, A♯, E♯, B♯\n'
            'The order in which flats are added: B♭, E♭, A♭, D♭, G♭, C♭, F♭',
        'imageUrls': [],
        'keyPoints': [
          'Any major scale follows T T S T T T S — sharps/flats are added as needed',
          'G major = 1 sharp (F♯); D major = 2 sharps (F♯, C♯)',
          'F major = 1 flat (B♭); B♭ major = 2 flats (B♭, E♭)',
          'Key signature at the start of a stave shows which notes are always altered',
          'Sharps order: F C G D A E B; Flats order: B E A D G C F',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Minor Scales',
      'chapterNumber': 9,
      'partNumber': 1,
      'order': 9,
      'iconName': 'graphic_eq',
      'content': {
        'text':
            'While major scales have a bright, happy sound, minor scales have a darker, more expressive quality. '
            'There are three forms of the minor scale.\n\n'
            'The Natural Minor Scale follows the pattern: T S T T S T T\n'
            'A natural minor: A B C D E F G A (same notes as C major, but starting and ending on A)\n\n'
            'The Harmonic Minor Scale raises the 7th degree by one semitone. '
            'This creates a characteristic interval of an augmented 2nd (3 semitones) '
            'between the 6th and 7th degrees, giving the scale its distinctive exotic sound.\n'
            'A harmonic minor: A B C D E F G♯ A\n\n'
            'The Melodic Minor Scale raises both the 6th and 7th degrees when ascending, '
            'then returns to the natural minor when descending.\n'
            'A melodic minor ascending: A B C D E F♯ G♯ A\n'
            'A melodic minor descending: A G F E D C B A\n\n'
            'Every major key has a relative minor key that shares the same key signature. '
            'The relative minor starts on the 6th degree of the major scale (a minor 3rd below the tonic).',
        'imageUrls': [],
        'keyPoints': [
          'Natural minor pattern: T S T T S T T',
          'Harmonic minor: raise the 7th degree by a semitone (creates augmented 2nd)',
          'Melodic minor: raise 6th and 7th ascending; use natural minor descending',
          'Relative minor starts on the 6th degree of its relative major',
          'A minor is the relative minor of C major (both have no sharps/flats)',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Intervals',
      'chapterNumber': 10,
      'partNumber': 1,
      'order': 10,
      'iconName': 'swap_vert',
      'content': {
        'text':
            'An interval is the distance in pitch between two notes. '
            'We measure intervals by counting the letter names of all the notes from the lower to the higher note, '
            'including both the starting note and the ending note.\n\n'
            '• Unison — same note (1st)\n'
            '• Major/Minor 2nd — e.g., C to D (2 letter names: C, D)\n'
            '• Major/Minor 3rd — e.g., C to E (3 letter names: C, D, E)\n'
            '• Perfect 4th — e.g., C to F\n'
            '• Perfect 5th — e.g., C to G\n'
            '• Major/Minor 6th — e.g., C to A\n'
            '• Major/Minor 7th — e.g., C to B\n'
            '• Octave (8th) — e.g., C to C\n\n'
            'Intervals have two properties: their number (how many letter names are spanned) '
            'and their quality (major, minor, perfect, augmented, or diminished).\n\n'
            'A melodic interval is when two notes are played one after another. '
            'A harmonic interval is when two notes are played simultaneously.',
        'imageUrls': [],
        'keyPoints': [
          'Count BOTH the lower and upper notes when naming an interval',
          'C to E = a 3rd (C–D–E = three letter names)',
          'Melodic = notes in sequence; Harmonic = notes together',
          'Perfect intervals: unison, 4th, 5th, octave',
          'Major/minor intervals: 2nds, 3rds, 6ths, 7ths',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Triads and Chords',
      'chapterNumber': 11,
      'partNumber': 1,
      'order': 11,
      'iconName': 'library_music',
      'content': {
        'text':
            'A chord is when three or more notes are sounded together. '
            'The simplest and most important chord is the triad — a chord of three notes built by stacking intervals of a 3rd.\n\n'
            'The Tonic Triad is built on the 1st degree (tonic) of a scale: 1st + 3rd + 5th.\n'
            '• C major tonic triad: C – E – G\n'
            '• A minor tonic triad: A – C – E\n\n'
            'A major triad has a major 3rd on the bottom and a minor 3rd on top: e.g., C–E (major 3rd) + E–G (minor 3rd).\n'
            'A minor triad has a minor 3rd on the bottom and a major 3rd on top: e.g., A–C (minor 3rd) + C–E (major 3rd).\n\n'
            'Each degree of a scale has its own triad. The triads built on the 1st (Tonic), '
            '4th (Subdominant), and 5th (Dominant) degrees are the most important — '
            'they form the harmonic foundation of most Western music.\n\n'
            'A chord can be played as a block chord (all notes together) or as a broken chord / arpeggio '
            '(notes played one after another).',
        'imageUrls': [],
        'keyPoints': [
          'Triad = 3 notes, built by stacking 3rds (1st + 3rd + 5th of the scale)',
          'Major triad: major 3rd + minor 3rd (e.g., C–E–G)',
          'Minor triad: minor 3rd + major 3rd (e.g., A–C–E)',
          'Most important triads: I (Tonic), IV (Subdominant), V (Dominant)',
          'Block chord = notes together; broken chord/arpeggio = notes in sequence',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'More About Keys — The Circle of Fifths',
      'chapterNumber': 12,
      'partNumber': 1,
      'order': 12,
      'iconName': 'loop',
      'content': {
        'text':
            'The circle of fifths is a diagram that organises all 12 major keys (and their relative minors) '
            'in a clockwise arrangement, each a perfect 5th apart.\n\n'
            'Moving clockwise (adding sharps): C → G → D → A → E → B → F♯/G♭\n'
            'Moving anti-clockwise (adding flats): C → F → B♭ → E♭ → A♭ → D♭ → G♭/F♯\n\n'
            'Key signatures with sharps (up to 4):\n'
            '1♯ = G major / E minor\n'
            '2♯ = D major / B minor\n'
            '3♯ = A major / F♯ minor\n'
            '4♯ = E major / C♯ minor\n\n'
            'Key signatures with flats (up to 4):\n'
            '1♭ = F major / D minor\n'
            '2♭ = B♭ major / G minor\n'
            '3♭ = E♭ major / C minor\n'
            '4♭ = A♭ major / F minor\n\n'
            'The circle of fifths is an essential tool for understanding how all keys relate to each other '
            'and for transposing music from one key to another.',
        'imageUrls': [],
        'keyPoints': [
          'Circle of fifths arranges all 12 keys a perfect 5th apart',
          'Clockwise = add a sharp; anti-clockwise = add a flat',
          'Quick rule: the last sharp = leading note; the tonic is one semitone up',
          'Quick rule: the last flat = the subdominant (4th degree); count back one flat for the tonic',
          'Relative minor is always 3 semitones below (or a major 6th above) the major tonic',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Musical Terms and Signs',
      'chapterNumber': 13,
      'partNumber': 1,
      'order': 13,
      'iconName': 'book',
      'content': {
        'text':
            'Music uses a rich vocabulary of Italian, French, and German terms to describe how a piece should be performed. '
            'Understanding these terms is essential for reading and interpreting music correctly.\n\n'
            'Tempo (speed) markings:\n'
            '• Largo — very slow and broad\n'
            '• Adagio — slow\n'
            '• Andante — at a walking pace\n'
            '• Moderato — at a moderate speed\n'
            '• Allegro — fast and lively\n'
            '• Presto — very fast\n\n'
            'Dynamic (volume) markings:\n'
            '• pp (pianissimo) — very soft\n'
            '• p (piano) — soft\n'
            '• mp (mezzo-piano) — moderately soft\n'
            '• mf (mezzo-forte) — moderately loud\n'
            '• f (forte) — loud\n'
            '• ff (fortissimo) — very loud\n'
            '• crescendo (cresc. or <) — gradually get louder\n'
            '• diminuendo / decrescendo (dim. or >) — gradually get softer\n\n'
            'Articulation signs:\n'
            '• Staccato (dot above/below note) — short and detached\n'
            '• Accent (> marking) — emphasise this note\n'
            '• Fermata (𝄐) — hold the note longer than its written value\n\n'
            'Repeat signs: || :| means go back to |: and repeat that section.',
        'imageUrls': [],
        'keyPoints': [
          'Tempo markings describe speed: Largo (slowest) → Presto (fastest)',
          'Dynamic markings: pp = very soft, ff = very loud',
          'Crescendo = grow louder; diminuendo = grow softer',
          'Staccato = short/detached; fermata = hold longer',
          'Repeat signs |: :| indicate a section to be played twice',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },

    // ════════════════════ PART II ═══════════════════════════════════════════
    {
      'title': 'Revision and Extension of Part I',
      'chapterNumber': 1,
      'partNumber': 2,
      'order': 1,
      'iconName': 'refresh',
      'content': {
        'text':
            'Part II builds directly on the foundations of Part I. Before continuing, '
            'it is worth consolidating the key concepts already covered.\n\n'
            'Note values: semibreve, minim, crotchet, quaver, semiquaver and their dotted equivalents. '
            'All rests: semibreve rest (hangs below line 4), minim rest (sits on line 3), crotchet rest, quaver rest, semiquaver rest.\n\n'
            'Time signatures: simple time (2/4, 3/4, 4/4) where the beat divides into 2 equal parts. '
            'The top number gives the number of beats; the bottom number gives the beat unit.\n\n'
            'Scales: major scales with up to 4 sharps (G, D, A, E) and 4 flats (F, B♭, E♭, A♭); '
            'natural, harmonic, and melodic minor scales; relative and tonic minor relationships.\n\n'
            'Intervals up to an octave; simple triad construction on any degree of a scale. '
            'Part II will now extend all of these areas and introduce compound time, more complex harmonics, '
            'and the full range of keys.',
        'imageUrls': [],
        'keyPoints': [
          'Review all note values, rests, and dotted note values from Part I',
          'Confirm all major scales with up to 4 sharps and 4 flats',
          'Know natural, harmonic, and melodic minor scales',
          'Understand simple time signatures (2/4, 3/4, 4/4)',
          'Part II extends into compound time, more keys, and advanced harmony',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Compound Time',
      'chapterNumber': 2,
      'partNumber': 2,
      'order': 2,
      'iconName': 'more_time',
      'content': {
        'text':
            'In simple time, each beat divides into two equal parts (e.g., a crotchet divides into two quavers). '
            'In compound time, each beat divides into THREE equal parts.\n\n'
            'The most common compound time signatures are:\n'
            '• 6/8 — two dotted crotchet beats per bar, each dividing into three quavers\n'
            '• 9/8 — three dotted crotchet beats per bar\n'
            '• 12/8 — four dotted crotchet beats per bar\n\n'
            'In compound time, the bottom number (8) refers to quavers, but the actual beat '
            'is a dotted crotchet (worth 3 quavers). Think of 6/8 as "ONE-and-a TWO-and-a".\n\n'
            'The difference between 3/4 and 6/8:\n'
            '• 3/4 has THREE crotchet beats — emphasis is ONE-two-three\n'
            '• 6/8 has TWO dotted-crotchet beats — emphasis is ONE-two-three-FOUR-five-six\n\n'
            'Compound time gives music a lilting, flowing, "triplet" feel, '
            'common in jigs, barcarolles, and many folk songs.',
        'imageUrls': [],
        'keyPoints': [
          'Simple time: beat divides into 2; compound time: beat divides into 3',
          '6/8 = 2 dotted-crotchet beats; 9/8 = 3 dotted-crotchet beats; 12/8 = 4',
          'In compound time, the beat unit is a dotted note',
          '3/4 vs 6/8: same note count but different grouping and feel',
          'Compound time creates a lilting, triplet feel (jigs, barcarolles)',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Keys and Scales — The Full Range',
      'chapterNumber': 3,
      'partNumber': 2,
      'order': 3,
      'iconName': 'piano',
      'content': {
        'text':
            'Part II extends the study of keys to include all major and minor keys up to seven sharps and seven flats, '
            'completing the full circle of fifths.\n\n'
            'Major keys with sharps:\n'
            '5♯ = B major | 6♯ = F♯ major | 7♯ = C♯ major\n\n'
            'Major keys with flats:\n'
            '5♭ = D♭ major | 6♭ = G♭ major | 7♭ = C♭ major\n\n'
            'Enharmonic key pairs — same pitch, different notation:\n'
            'B major (5♯) = C♭ major (7♭)\n'
            'F♯ major (6♯) = G♭ major (6♭)\n'
            'C♯ major (7♯) = D♭ major (5♭)\n\n'
            'The chromatic scale includes all twelve semitones within an octave. '
            'It can be written with sharps (ascending) or flats (descending). '
            'The chromatic scale forms the complete "palette" of pitches in Western music.\n\n'
            'The whole tone scale divides the octave into six equal whole tones. '
            'It has a dreamlike, ambiguous quality used by composers like Debussy.',
        'imageUrls': [],
        'keyPoints': [
          'The circle of fifths extends to 7 sharps (C♯ major) and 7 flats (C♭ major)',
          'Enharmonic keys sound identical but are written differently',
          'Chromatic scale = all 12 semitones within an octave',
          'Whole tone scale = 6 equal whole tones; ambiguous, dreamlike sound',
          'Knowing all 15 major key signatures (including 3 enharmonic pairs) is essential at advanced levels',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Intervals — Quality and Inversion',
      'chapterNumber': 4,
      'partNumber': 2,
      'order': 4,
      'iconName': 'swap_vert',
      'content': {
        'text':
            'In Part I we named intervals by number (2nd, 3rd, 4th, etc.). '
            'In Part II we also describe their quality: perfect, major, minor, augmented, or diminished.\n\n'
            'Perfect intervals (4ths, 5ths, octaves, unisons):\n'
            '• Augmented = perfect + 1 semitone\n'
            '• Diminished = perfect − 1 semitone\n\n'
            'Major intervals (2nds, 3rds, 6ths, 7ths):\n'
            '• Minor = major − 1 semitone\n'
            '• Augmented = major + 1 semitone\n'
            '• Diminished = minor − 1 semitone\n\n'
            'Inversion: to invert an interval, take the lower note and place it an octave higher '
            '(or the upper note an octave lower). The rule for inversions:\n'
            '• The numbers add up to 9 (e.g., a 3rd inverts to a 6th)\n'
            '• Major inverts to minor (and vice versa)\n'
            '• Perfect inverts to perfect\n'
            '• Augmented inverts to diminished (and vice versa)',
        'imageUrls': [],
        'keyPoints': [
          'Interval quality: perfect, major, minor, augmented, diminished',
          'Perfect intervals: unison, 4th, 5th, octave',
          'Major/minor intervals: 2nds, 3rds, 6ths, 7ths',
          'To invert: move lower note up an octave; inversion numbers add to 9',
          'Major ↔ minor on inversion; perfect stays perfect; augmented ↔ diminished',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Chords and Harmony',
      'chapterNumber': 5,
      'partNumber': 2,
      'order': 5,
      'iconName': 'library_music',
      'content': {
        'text':
            'Harmony is the study of how chords are constructed and how they move from one to another. '
            'Understanding harmony helps you make sense of the music you play and compose.\n\n'
            'Diatonic triads are triads built on each degree of a scale using only the notes of that scale. '
            'In a major key:\n'
            '• I, IV, V = major triads (bright)\n'
            '• II, III, VI = minor triads (darker)\n'
            '• VII = diminished triad (tense)\n\n'
            'The most important harmonic progressions are:\n'
            '• Perfect cadence: V → I (feels final and conclusive)\n'
            '• Imperfect cadence: I → V or IV → V (feels incomplete, like a question)\n'
            '• Plagal cadence: IV → I (the "Amen" cadence)\n'
            '• Interrupted cadence: V → VI (a surprise — avoids the expected I)\n\n'
            'Chord inversions: a triad is in root position when the root is the lowest note. '
            'First inversion: the 3rd is in the bass. Second inversion: the 5th is in the bass.',
        'imageUrls': [],
        'keyPoints': [
          'Diatonic triads use only scale notes; I IV V are major, II III VI are minor',
          'Perfect cadence V→I = conclusive; imperfect I→V or IV→V = unresolved',
          'Plagal cadence IV→I ("Amen"); interrupted cadence V→VI (surprise)',
          'Root position: root in bass; 1st inversion: 3rd in bass; 2nd inversion: 5th in bass',
          'Chord progressions create tension and resolution — the engine of Western music',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Ornaments and Decorations',
      'chapterNumber': 6,
      'partNumber': 2,
      'order': 6,
      'iconName': 'auto_awesome',
      'content': {
        'text':
            'Ornaments are decorative notes that embellish a melody. '
            'They add character and expression without changing the underlying harmonic structure.\n\n'
            '• Trill (tr) — rapid alternation between the written note and the note one step above. '
            'In Baroque music, trills often start on the upper note.\n\n'
            '• Turn (𝄆) — a four-note figure: upper note, main note, lower note, main note. '
            'A turned note can be written above or after the note head.\n\n'
            '• Mordent — a brief alternation with the lower note (lower mordent) '
            'or upper note (upper mordent / inverted mordent).\n\n'
            '• Appoggiatura — an ornamental note (usually a step above or below) '
            'that falls on the beat and takes half the value of the main note.\n\n'
            '• Acciaccatura ("crushed note") — a very short grace note played as quickly as possible '
            'just before the main note; written as a small note with a slash through its stem.\n\n'
            'The exact realisation of ornaments varied by period and national style. '
            'Performance practice guides and original treatises give authoritative guidance.',
        'imageUrls': [],
        'keyPoints': [
          'Trill (tr): rapid alternation with upper neighbour note',
          'Turn: upper–main–lower–main note sequence',
          'Mordent: quick flick to the lower (or upper) neighbour',
          'Appoggiatura: on-beat ornamental note, takes half the main note value',
          'Acciaccatura: crushed note before the beat — as fast as possible',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Voice, Instrument and Score Reading',
      'chapterNumber': 7,
      'partNumber': 2,
      'order': 7,
      'iconName': 'mic',
      'content': {
        'text':
            'Music is written for voices and instruments in a variety of clefs and ranges. '
            'Understanding how different parts are written is essential for reading scores and arranging music.\n\n'
            'Vocal ranges (approximately):\n'
            '• Soprano — highest female voice (C4–C6)\n'
            '• Mezzo-soprano — middle female voice (A3–A5)\n'
            '• Alto (Contralto) — lowest female voice (F3–E5)\n'
            '• Tenor — highest male voice (C3–C5); written in treble clef, sounds an octave lower\n'
            '• Baritone — middle male voice (G2–G4)\n'
            '• Bass — lowest male voice (E2–E4)\n\n'
            'The Alto and Tenor clef (C clef) places middle C on a different line — '
            'it is used for viola, cello (in higher passages), and trombone.\n\n'
            'A score shows all parts simultaneously, one above the other. '
            'Instruments of the same family are bracketed together. '
            'The conductor and pianist read from the full score; individual players read their own part (a "part").\n\n'
            'Transposing instruments sound a different pitch than written — '
            'e.g., a B♭ clarinet sounds a tone lower than written; a horn in F sounds a perfect 5th lower.',
        'imageUrls': [],
        'keyPoints': [
          'Soprano, mezzo, alto = female voices; tenor, baritone, bass = male voices',
          'Alto clef (C clef on 3rd line): used for viola',
          'Tenor clef (C clef on 4th line): used for cello, trombone in high passages',
          'A score shows all parts simultaneously; players read individual parts',
          'Transposing instruments (B♭ clarinet, F horn) sound different from written pitch',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
    {
      'title': 'Form and Structure',
      'chapterNumber': 8,
      'partNumber': 2,
      'order': 8,
      'iconName': 'account_tree',
      'content': {
        'text':
            'Musical form describes how a piece of music is organised over time. '
            'Recognising form helps listeners and performers understand the shape and logic of a composition.\n\n'
            'Binary form (AB): a piece in two contrasting sections, each usually repeated (|| :A: || :B: ||). '
            'Common in Baroque dances like the minuet and sarabande.\n\n'
            'Ternary form (ABA): three sections — an opening section A, a contrasting middle section B, '
            'and a return to A. Very common in Classical and Romantic music.\n\n'
            'Rondo form (ABACA or ABACABA): a main theme (A) keeps returning between contrasting episodes. '
            'Many final movements of Classical sonatas and concertos use rondo form.\n\n'
            'Theme and Variations: an opening theme is stated and then repeated in a series of variations '
            'that alter the melody, rhythm, harmony, or texture while retaining the underlying structure.\n\n'
            'Sonata form: an extended structure with three main sections:\n'
            '1. Exposition — themes are introduced (often in two contrasting keys)\n'
            '2. Development — themes are fragmented and developed\n'
            '3. Recapitulation — themes return, both now in the tonic key',
        'imageUrls': [],
        'keyPoints': [
          'Binary (AB): two contrasting sections, each repeated — common in Baroque dances',
          'Ternary (ABA): three sections with a return — very common in Classical era',
          'Rondo (ABACA): main theme returns between contrasting episodes',
          'Theme and Variations: theme restated with progressively altered repetitions',
          'Sonata form: Exposition → Development → Recapitulation (three main sections)',
        ],
      },
      'linkedExerciseIds': [],
      'thumbnailUrl': null,
    },
  ];
}
