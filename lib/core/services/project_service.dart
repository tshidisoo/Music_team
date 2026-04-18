import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../constants/app_constants.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─── Projects ─────────────────────────────────────────────────────────────

  Stream<List<ProjectModel>> watchActiveProjects() {
    return _db
        .collection(AppConstants.projectsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ProjectModel.fromFirestore(d))
              .toList();
          list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return list;
        });
  }

  Stream<List<ProjectModel>> watchAllProjects() {
    return _db
        .collection(AppConstants.projectsCollection)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ProjectModel.fromFirestore(d))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _db
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .get();
    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }

  Future<String> createProject({
    required String title,
    required String description,
    required DateTime dueDate,
    required String teacherId,
    List<String> mediaAllowed = const ['image', 'pdf', 'video', 'audio'],
  }) async {
    final ref = _db.collection(AppConstants.projectsCollection).doc();
    await ref.set({
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'assignedBy': teacherId,
      'mediaAllowed': mediaAllowed,
      'isActive': true,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    return ref.id;
  }

  Future<void> toggleProjectActive(String projectId, bool isActive) async {
    await _db
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .update({'isActive': isActive});
  }

  // ─── Submissions ──────────────────────────────────────────────────────────

  Stream<List<SubmissionModel>> watchSubmissionsForProject(String projectId) {
    return _db
        .collection(AppConstants.submissionsCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => SubmissionModel.fromFirestore(d))
              .toList();
          list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          return list;
        });
  }

  Stream<List<SubmissionModel>> watchAllSubmissions() {
    return _db
        .collection(AppConstants.submissionsCollection)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => SubmissionModel.fromFirestore(d))
              .toList();
          list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          return list;
        });
  }

  Future<SubmissionModel?> getStudentSubmission(
      String projectId, String studentId) async {
    final snap = await _db
        .collection(AppConstants.submissionsCollection)
        .where('projectId', isEqualTo: projectId)
        .where('studentId', isEqualTo: studentId)
        .get();
    if (snap.docs.isEmpty) return null;
    return SubmissionModel.fromFirestore(snap.docs.first);
  }

  /// Real-time stream of a single student's submission — updates instantly
  /// when the teacher saves feedback or a grade.
  Stream<SubmissionModel?> watchStudentSubmission(
      String projectId, String studentId) {
    return _db
        .collection(AppConstants.submissionsCollection)
        .where('projectId', isEqualTo: projectId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : SubmissionModel.fromFirestore(snap.docs.first));
  }

  /// Auto-deactivate all projects whose deadline has passed.
  /// Call this when the teacher opens the projects screen.
  Future<void> checkAndDeactivateExpiredProjects() async {
    final now = DateTime.now();
    final snap = await _db
        .collection(AppConstants.projectsCollection)
        .where('isActive', isEqualTo: true)
        .get();
    final batch = _db.batch();
    int count = 0;
    for (final doc in snap.docs) {
      final dueDate =
          (doc.data()['dueDate'] as Timestamp).toDate();
      if (now.isAfter(dueDate)) {
        batch.update(doc.reference, {'isActive': false});
        count++;
      }
    }
    if (count > 0) await batch.commit();
  }

  /// Update the due date of a project. If the new date is in the future
  /// and the project was auto-deactivated, the teacher can re-activate it
  /// manually via [toggleProjectActive].
  Future<void> updateProjectDueDate(
      String projectId, DateTime newDate) async {
    await _db
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .update({'dueDate': Timestamp.fromDate(newDate)});
  }

  /// Upload a file to Firebase Storage and return the download URL.
  Future<MediaFile> uploadFile({
    required String studentId,
    required String submissionId,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    final ext = fileName.split('.').last.toLowerCase();
    final path =
        '${AppConstants.submissionsStoragePath}/$studentId/$submissionId/$fileName';
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: mimeType);
    final task = ref.putData(bytes, metadata);

    task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0 && onProgress != null) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });

    final snapshot = await task;
    final url = await snapshot.ref.getDownloadURL();

    String type = 'image';
    if (['mp4', 'mov', 'avi'].contains(ext)) type = 'video';
    if (['mp3', 'wav', 'm4a', 'aac'].contains(ext)) type = 'audio';
    if (ext == 'pdf') type = 'pdf';

    return MediaFile(url: url, type: type, fileName: fileName, size: bytes.length);
  }

  Future<String> submitProject({
    required String projectId,
    required String studentId,
    required String studentName,
    String? notes,
    required List<MediaFile> mediaFiles,
  }) async {
    final existing = await getStudentSubmission(projectId, studentId);
    if (existing != null) {
      // Merge new files with existing files
      final mergedFiles = [
        ...existing.mediaFiles,
        ...mediaFiles,
      ];
      await _db
          .collection(AppConstants.submissionsCollection)
          .doc(existing.id)
          .update({
        'notes': notes ?? existing.notes ?? '',
        'mediaFiles': mergedFiles.map((f) => f.toMap()).toList(),
        'submittedAt': Timestamp.fromDate(DateTime.now()),
      });
      return existing.id;
    }
    final ref = _db.collection(AppConstants.submissionsCollection).doc();
    await ref.set({
      'projectId': projectId,
      'studentId': studentId,
      'studentName': studentName,
      'notes': notes ?? '',
      'mediaFiles': mediaFiles.map((f) => f.toMap()).toList(),
      'submittedAt': Timestamp.fromDate(DateTime.now()),
      'grade': null,
      'feedback': null,
      'gradedAt': null,
      'gradedBy': null,
    });
    return ref.id;
  }

  Future<void> gradeSubmission({
    required String submissionId,
    String? grade,
    String? feedback,
    required String gradedBy,
  }) async {
    await _db
        .collection(AppConstants.submissionsCollection)
        .doc(submissionId)
        .update({
      if (grade != null) 'grade': grade,
      if (feedback != null) 'feedback': feedback,
      'gradedAt': Timestamp.fromDate(DateTime.now()),
      'gradedBy': gradedBy,
    });
  }

  // ─── Seed pre-built projects ──────────────────────────────────────────────

  Future<void> seedProjects(String teacherId) async {
    final now = DateTime.now();

    // Clear existing seeded projects first
    final existing = await _db
        .collection(AppConstants.projectsCollection)
        .where('assignedBy', isEqualTo: teacherId)
        .get();
    final batch0 = _db.batch();
    for (final doc in existing.docs) batch0.delete(doc.reference);
    await batch0.commit();

    final projects = _buildSeedProjects(teacherId, now);

    const batchSize = 10;
    for (int i = 0; i < projects.length; i += batchSize) {
      final batch = _db.batch();
      final end =
          (i + batchSize > projects.length) ? projects.length : i + batchSize;
      for (final p in projects.sublist(i, end)) {
        final ref = _db.collection(AppConstants.projectsCollection).doc();
        batch.set(ref, p);
      }
      await batch.commit();
    }
  }

  // ─── Seed data ─────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _buildSeedProjects(
      String teacherId, DateTime now) {
    Map<String, dynamic> proj(
      String title,
      String description,
      int dueDays,
    ) =>
        {
          'title': title,
          'description': description,
          'dueDate': Timestamp.fromDate(now.add(Duration(days: dueDays))),
          'assignedBy': teacherId,
          'mediaAllowed': ['image', 'pdf'],
          'isActive': true,
          'createdAt': Timestamp.fromDate(now),
        };

    return [
      // ── Project 1 ──────────────────────────────────────────────────────────
      proj(
        'Project 1: Staff, Clefs & Note Names',
        '''📖 LESSONS COVERED: Part I — Chapter 2 (The Stave, Clefs and Notes)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS
Answer ALL of the following in the Notes box below:

1. How many lines and spaces does a stave have? Name them from bottom to top.
2. What note is fixed on the 2nd line of the treble clef? What note is on the 4th line of the bass clef?
3. Name TWO instruments that use the treble clef and TWO that use the bass clef.
4. What are ledger lines, and when are they needed? Give one example.
5. Where does middle C appear in the treble clef? Describe its position.
6. If a note is placed higher on the stave, is its pitch higher or lower?

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open the Maestro – Music Score app on your Android device.

STEP 1 → Create a new score. Title it "Staff & Clefs Practice – [Your Name]". Choose Treble Clef + Bass Clef (grand staff / piano layout).

STEP 2 → In the TREBLE CLEF, write these 8 notes as a rising sequence:
  C  D  E  F  G  A  B  C
  (This is the C major scale — all white keys, no sharps or flats)
  Make sure each note sits on the correct line or space.

STEP 3 → In the BASS CLEF, write these 8 notes as a descending sequence:
  C  B  A  G  F  E  D  C
  (Same C major scale, going down)

STEP 4 → Include at least 2 ledger-line notes (e.g., middle C in treble clef, high C in bass clef).

STEP 5 → Take a clear screenshot showing BOTH the treble and bass clef passages. Make sure the notes are clearly visible.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro (upload as image)
✅ Theory answers typed in the Notes box below''',
        14,
      ),

      // ── Project 2 ──────────────────────────────────────────────────────────
      proj(
        'Project 2: Note Values, Rests & Time Signatures',
        '''📖 LESSONS COVERED: Part I — Chapters 3 & 4 (Note Values · Time Signatures)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. List all 5 note values from longest to shortest and give the British and American name for each.
2. How many crotchet beats does a semibreve last? A minim? A quaver?
3. In 4/4 time, what does the top "4" mean? What does the bottom "4" mean?
4. What is the difference between 3/4 and 6/8? (Hint — you will study 6/8 in Part II, but try to explain the feel of 3/4.)
5. What does a double bar line signify? What about a final bar line?
6. Write out 1 complete bar of 4/4 using only crotchets (4 crotchets). Now write 1 bar of 3/4 using a minim + crotchet.

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Rhythm Study – [Your Name]". Choose 4/4 time signature, treble clef.

STEP 2 → BARS 1–2: Write a rhythm using ONLY semibreves and minims.
  (e.g., Bar 1: one semibreve | Bar 2: two minims)

STEP 3 → BARS 3–4: Write a rhythm using ONLY crotchets and quavers.
  (e.g., Bar 3: four crotchets | Bar 4: two crotchets + four quavers)

STEP 4 → BARS 5–6: Write a rhythm using DOTTED NOTES.
  Include at least one dotted minim and one dotted crotchet.

STEP 5 → BARS 7–8: Write a rhythm that includes at least TWO rests
  (semibreve rest, minim rest, or crotchet rest).

STEP 6 → Add a final bar line at the end.

STEP 7 → Screenshot your 8-bar rhythm piece.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro (8-bar rhythm piece)
✅ Theory answers in the Notes box''',
        14,
      ),

      // ── Project 3 ──────────────────────────────────────────────────────────
      proj(
        'Project 3: Major Scales & Key Signatures',
        '''📖 LESSONS COVERED: Part I — Chapters 6, 7 & 8 (Major Scale · Sharps/Flats · Key Signatures)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. What is the tone-semitone pattern of EVERY major scale? Write it out (T T S T T T S).
2. Why does C major have no sharps or flats while G major has one sharp?
3. List the notes of G major and D major. Which notes are sharpened?
4. What is the order in which sharps are added to key signatures? (Give the first 4)
5. What is the order in which flats are added? (Give the first 4)
6. How does a key signature save time for the composer?
7. What is the interval from E to F? From B to C? (Tone or semitone?)

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Major Scales – [Your Name]".

STEP 2 → WRITE C MAJOR SCALE (bars 1–2):
  Set the key signature to C major (no sharps/flats).
  Write C D E F G A B C going up in the treble clef.

STEP 3 → WRITE G MAJOR SCALE (bars 3–4):
  Change the key signature to G major (1 sharp — F♯).
  Write G A B C D E F♯ G going up.
  Make sure F is written as F♯ (either via key signature or accidental).

STEP 4 → WRITE D MAJOR SCALE (bars 5–6):
  Change the key signature to D major (2 sharps — F♯, C♯).
  Write D E F♯ G A B C♯ D going up.

STEP 5 → WRITE F MAJOR SCALE (bars 7–8):
  Change the key signature to F major (1 flat — B♭).
  Write F G A B♭ C D E F going up.

STEP 6 → Screenshot your full score showing all 4 scales with their key signatures visible.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro showing all 4 scales
✅ Theory answers in the Notes box''',
        14,
      ),

      // ── Project 4 ──────────────────────────────────────────────────────────
      proj(
        'Project 4: The World of Minor Scales',
        '''📖 LESSONS COVERED: Part I — Chapter 9 (Minor Scales)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. What is the tone-semitone pattern of the NATURAL minor scale?
2. How does the HARMONIC minor scale differ from the natural minor? Which degree is altered?
3. What is the "augmented 2nd" interval in the harmonic minor? Between which two degrees does it occur?
4. How does the MELODIC minor scale work ascending vs descending?
5. A minor is the relative minor of C major. What does "relative minor" mean?
6. Write out the notes of A natural minor, A harmonic minor, and A melodic minor (ascending).
7. Which of the three minor forms has the most "exotic" or "Middle-Eastern" sound? Why?

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Minor Scales – [Your Name]".
  Use the key signature of A minor / C major (no sharps or flats).

STEP 2 → BARS 1–2: Write A NATURAL MINOR ascending:
  A  B  C  D  E  F  G  A  (all natural — no accidentals needed)

STEP 3 → BARS 3–4: Write A HARMONIC MINOR ascending:
  A  B  C  D  E  F  G♯  A
  (Raise the G to G♯ using an accidental — this is the key difference!)

STEP 4 → BARS 5–6: Write A MELODIC MINOR:
  Ascending:  A  B  C  D  E  F♯  G♯  A  (raise 6th and 7th)
  Descending: A  G  F  E  D  C  B  A   (return to natural minor)
  Write both directions as a continuous phrase.

STEP 5 → Screenshot your completed score showing all three minor scales.
  Add a note or text label (if Maestro allows) labelling each scale.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro showing all 3 minor scales
✅ Theory answers + note of which scale sounds most exotic and why''',
        14,
      ),

      // ── Project 5 ──────────────────────────────────────────────────────────
      proj(
        'Project 5: Interval Detective',
        '''📖 LESSONS COVERED: Part I — Chapter 10 (Intervals)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. What is an interval? How do you calculate the number of an interval?
2. What is the difference between a melodic interval and a harmonic interval?
3. Name the interval formed by each of these note pairs (count both notes):
   a) C to E    b) C to G    c) C to A    d) D to A    e) G to D (above)
4. How many semitones are in a perfect 4th? A perfect 5th? An octave?
5. Why is it important to count BOTH notes when naming an interval?
6. C to B spans how many letter names? What is this interval called?

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Intervals – [Your Name]". Use C major (no key signature).

STEP 2 → Write the following MELODIC intervals above the note C (one after another):
  • C + D (a 2nd)
  • C + E (a 3rd)
  • C + F (a 4th)
  • C + G (a 5th)
  • C + A (a 6th)
  • C + B (a 7th)
  • C + C (an octave)

Write each pair as two separate notes in sequence (melodic).

STEP 3 → Now write the SAME intervals as HARMONIC intervals (both notes at the same time — stacked):
  Write C + D together, C + E together, C + F together, C + G together, C + A together, C + B together, C + C together.

STEP 4 → Screenshot your score showing both the melodic and harmonic versions.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot showing melodic and harmonic intervals
✅ Theory answers (including question 3: name all 6 intervals)''',
        14,
      ),

      // ── Project 6 ──────────────────────────────────────────────────────────
      proj(
        'Project 6: Chord Building & The Circle of Fifths',
        '''📖 LESSONS COVERED: Part I — Chapters 11 & 12 (Triads · Circle of Fifths)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. What is a triad? How is it constructed (which degrees of the scale)?
2. What is the difference between a MAJOR triad and a MINOR triad? (hint: the intervals from the root)
3. Write out the notes of the tonic triad (I) for: C major, G major, F major, D major, and A minor.
4. What is an arpeggio? How does it differ from a block chord?
5. Which three triads in a major key are major chords (I, IV, V)? Which are minor (II, III, VI)?
6. Moving CLOCKWISE on the circle of fifths adds a ___? Moving ANTI-CLOCKWISE adds a ___?
7. What is an enharmonic key pair? Give one example.

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Chords & Arpeggios – [Your Name]". Use C major key signature.

STEP 2 → BLOCK CHORDS (bars 1–3): Write the following chords as BLOCK CHORDS (all notes together):
  Bar 1: I chord in C major  = C + E + G (stacked)
  Bar 2: IV chord in C major = F + A + C (stacked)
  Bar 3: V chord in C major  = G + B + D (stacked)

STEP 3 → ARPEGGIOS (bars 4–6): Write the SAME chords as ARPEGGIOS (notes one after another):
  Bar 4: C  E  G  (broken/arpeggiated C major chord)
  Bar 5: F  A  C  (broken F major chord)
  Bar 6: G  B  D  (broken G major chord)

STEP 4 → CHALLENGE (bar 7): End with a final I chord block: C + E + G.

STEP 5 → Screenshot your completed score.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot showing block chords AND arpeggios
✅ Theory answers (including writing out the 5 tonic triads from Question 3)''',
        14,
      ),

      // ── Project 7 ──────────────────────────────────────────────────────────
      proj(
        'Project 7: Musical Expression & Terms',
        '''📖 LESSONS COVERED: Part I — Chapter 13 (Musical Terms and Signs)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. Arrange these tempo markings from SLOWEST to FASTEST:
   Allegro, Presto, Adagio, Andante, Moderato, Largo
2. What do these dynamics mean? pp, p, mp, mf, f, ff
3. What is the difference between a crescendo and a diminuendo?
4. What does staccato mean? How is it written on a score?
5. What does a fermata (𝄐) tell a performer to do?
6. If a piece is marked "Allegro, ff" at the start, then "Adagio, pp" at bar 8 — describe how the music would change.
7. What does "legato" mean in performance? How does it differ from staccato?

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Expression – [Your Name]". Choose 4/4 time, C major.

STEP 2 → Write 8 bars of a simple melody using only these notes: C D E F G A (any rhythm you like — make it musical!).

STEP 3 → Add the following EXPRESSION MARKINGS to your melody:
  • Bars 1–2: Mark as "Andante" (tempo) and "p" (soft)
  • Bar 3: Add a crescendo (growing louder) leading into bar 4
  • Bars 4–5: Mark as "f" (loud)
  • Bar 6: Add a diminuendo (getting softer)
  • Bars 7–8: Mark as "pp" (very soft) and add a fermata on the final note

STEP 4 → Add at least 3 STACCATO dots to notes in bars 3–4.

STEP 5 → Screenshot your completed expressive score showing all markings clearly.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro showing your melody with all expression markings
✅ Theory answers in the Notes box''',
        14,
      ),

      // ── Project 8 ──────────────────────────────────────────────────────────
      proj(
        'Project 8: Compound Time Composition',
        '''📖 LESSONS COVERED: Part II — Chapter 2 (Compound Time)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. What is the difference between SIMPLE time and COMPOUND time? (How does the beat divide?)
2. In 6/8 time, what is the main beat unit? How many of these beats are in each bar?
3. How many quavers are in one bar of 6/8? Show the calculation.
4. Why does 6/8 feel different from 3/4 even though both have 6 quavers possible?
5. What does 9/8 mean? How many beats and what type?
6. What types of music often use compound time? Name at least two genres or dance forms.
7. What is a "lilting" quality? Try to describe what compound time sounds like.

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "6/8 Composition – [Your Name]".
  Set the TIME SIGNATURE to 6/8.
  Choose a key you are comfortable with (C major recommended).

STEP 2 → BARS 1–2: Use DOTTED CROTCHETS as your main beat (one dotted crotchet = 3 quavers):
  Write patterns that clearly show 2 dotted-crotchet beats per bar.
  Example: dotted crotchet + dotted crotchet per bar.

STEP 3 → BARS 3–4: Use QUAVER GROUPINGS — fill each bar with 6 quavers, grouped 3+3:
  Example: three quavers | three quavers (beamed in groups of 3).

STEP 4 → BARS 5–6: Mix dotted notes AND quavers to create a flowing melody.
  Think of the feel of a lullaby or a jig!

STEP 5 → BARS 7–8: Bring your melody to a close. End on the tonic note (C if in C major).

STEP 6 → Screenshot your completed 8-bar 6/8 composition.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro (8-bar composition in 6/8)
✅ Theory answers in the Notes box''',
        14,
      ),

      // ── Project 9 ──────────────────────────────────────────────────────────
      proj(
        'Project 9: Harmony & Cadences',
        '''📖 LESSONS COVERED: Part II — Chapter 5 (Chords and Harmony)

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. What is a PERFECT CADENCE? Write the chord progression (use Roman numerals) and describe how it sounds.
2. What is an IMPERFECT CADENCE? What chord does it end on? Does it feel resolved or unresolved?
3. What is a PLAGAL CADENCE? What is its nickname and why?
4. What is an INTERRUPTED CADENCE? What makes it a "surprise"?
5. Which triads are MAJOR in a major key? Which are MINOR? Which is DIMINISHED?
6. Describe ROOT POSITION, FIRST INVERSION, and SECOND INVERSION of a triad.
7. If the C major tonic triad is C–E–G, write it in first inversion and second inversion.

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK

Open Maestro on your Android device.

STEP 1 → Create a new score titled "Cadences – [Your Name]".
  Use C major key signature, 4/4 time.

STEP 2 → IMPERFECT CADENCE (bars 1–2):
  Bar 1: Write chord I (C + E + G) as a block chord
  Bar 2: Write chord V (G + B + D) as a block chord
  This feels like a musical "question" — unresolved.

STEP 3 → PERFECT CADENCE (bars 3–4):
  Bar 3: Write chord V (G + B + D)
  Bar 4: Write chord I (C + E + G)
  This feels final and resolved — "the answer."

STEP 4 → PLAGAL CADENCE (bars 5–6):
  Bar 5: Write chord IV (F + A + C)
  Bar 6: Write chord I (C + E + G)
  The "Amen" cadence.

STEP 5 → FIRST INVERSION (bars 7–8):
  Write chord I in FIRST INVERSION: E + G + C (E in the bass).
  Then write it in ROOT POSITION: C + E + G.

STEP 6 → Screenshot your completed 8-bar cadence study.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot from Maestro showing all 4 cadence types + inversions
✅ Theory answers including Question 7 (inversions written out)''',
        14,
      ),

      // ── Project 10 ──────────────────────────────────────────────────────────
      proj(
        'Project 10: Compose in Binary Form — Your First Full Piece!',
        '''📖 LESSONS COVERED: Part II — Chapter 8 (Form and Structure) + ALL previous topics

🏆 This is your CAPSTONE project — it brings together everything you have learned!

═══════════════════════════════════
📚 PART A — THEORY QUESTIONS

1. Define BINARY form. What is its structure? What letter labels are used (AB)?
2. Define TERNARY form. How does it differ from binary?
3. What is RONDO form? Give the letter sequence for a typical rondo.
4. Name the THREE sections of SONATA form and briefly describe each.
5. In binary form, what typically happens harmonically at the end of Section A?
   (Hint: which chord is often used to create the feeling of "going to a new key"?)
6. How would you recognise binary form when listening to a piece of music?
7. Name ONE famous piece in binary form and ONE in ternary form (research or ask your teacher).

═══════════════════════════════════
🎵 PART B — MAESTRO PRACTICAL TASK (Full Composition!)

Open Maestro on your Android device.

🎼 COMPOSE AN 8-BAR PIECE IN BINARY FORM (AB)

STEP 1 → Create a new score titled "Binary Form Piece – [Your Name]".
  Choose: 4/4 time | C major | Treble clef | Andante tempo

═══ SECTION A (bars 1–4) — "Home" ═══
STEP 2 → Write a 4-bar melody that:
  • Starts on the tonic note (C)
  • Uses mostly notes from C major scale
  • Ends with an IMPERFECT cadence (V chord — G) to feel "unfinished"
  • Is simple and memorable — this is your main theme!
  • Mark it with "p" (soft) or "mp"

═══ SECTION B (bars 5–8) — "Contrast" ═══
STEP 3 → Write a contrasting 4-bar melody that:
  • Uses DIFFERENT rhythms or a higher register than Section A
  • Feels busier or more exciting than Section A
  • Ends with a PERFECT CADENCE (V → I) to feel "finished and at home"
  • Mark it with "f" (loud) or "mf"

STEP 4 → Add EXPRESSION to your piece:
  • Add a tempo marking (Andante, Allegretto, or Moderato)
  • Add dynamics (at least p and f in different sections)
  • Add at least one crescendo OR diminuendo
  • Add a fermata on the very last note

STEP 5 → Review your piece — play it back in Maestro if possible.
  Does Section A feel different from Section B? Does it feel complete at the end?

STEP 6 → Take a CLEAR screenshot of your full 8-bar composition.
  Make sure both sections (bars 1–4 and 5–8) are visible.

═══════════════════════════════════
📸 WHAT TO SUBMIT
✅ Screenshot(s) from Maestro showing your complete 8-bar binary form composition
✅ Theory answers (all 7 questions) in the Notes box
✅ In your notes, LABEL where Section A ends and Section B begins in your composition

⭐ BONUS: If you finish early, try adding a second instrument part in Maestro!''',
        21,
      ),
    ];
  }
}
