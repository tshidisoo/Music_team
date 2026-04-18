import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/project_service.dart';
import '../../../core/services/user_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;
  final String studentId;
  final SubmissionModel? existingSubmission;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.studentId,
    this.existingSubmission,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _notesCtrl = TextEditingController();
  final List<PlatformFile> _pickedFiles = [];

  bool _submitting = false;
  double _uploadProgress = 0;
  String? _statusMessage;
  SubmissionModel? _submission;
  StreamSubscription<SubmissionModel?>? _submissionSub;

  @override
  void initState() {
    super.initState();
    _submission = widget.existingSubmission;
    if (_submission?.notes != null) {
      _notesCtrl.text = _submission!.notes!;
    }
    // Watch for real-time teacher feedback — updates instantly when graded
    _submissionSub = ProjectService()
        .watchStudentSubmission(widget.project.id, widget.studentId)
        .listen((updated) {
      if (mounted) setState(() => _submission = updated);
    });
  }

  @override
  void dispose() {
    _submissionSub?.cancel();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );
    if (result == null) return;
    setState(() => _pickedFiles.addAll(result.files));
  }

  void _removeFile(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  Future<void> _submit() async {
    if (_pickedFiles.isEmpty && _notesCtrl.text.trim().isEmpty) {
      _showSnack('Please add at least one file or a note before submitting.',
          isError: true);
      return;
    }

    setState(() {
      _submitting = true;
      _uploadProgress = 0;
      _statusMessage = 'Uploading files…';
    });

    try {
      // Get student display name
      final UserModel? user =
          await UserService().getUser(widget.studentId);
      final studentName = user?.displayName ?? 'Student';

      // Upload files to Storage
      final List<MediaFile> uploadedFiles = [];
      for (var i = 0; i < _pickedFiles.length; i++) {
        final file = _pickedFiles[i];
        if (file.bytes == null) continue;

        setState(() {
          _statusMessage =
              'Uploading file ${i + 1} of ${_pickedFiles.length}…';
        });

        final submissionId =
            '${widget.studentId}_${widget.project.id}';
        final mediaFile = await ProjectService().uploadFile(
          studentId: widget.studentId,
          submissionId: submissionId,
          fileName: file.name,
          bytes: file.bytes!,
          mimeType: file.extension != null
              ? _mimeFromExtension(file.extension!)
              : 'application/octet-stream',
          onProgress: (p) {
            setState(() {
              _uploadProgress =
                  (i + p) / _pickedFiles.length;
            });
          },
        );

        uploadedFiles.add(mediaFile);
      }

      setState(() => _statusMessage = 'Saving submission…');

      // Save submission to Firestore
      await ProjectService().submitProject(
        projectId: widget.project.id,
        studentId: widget.studentId,
        studentName: studentName,
        mediaFiles: uploadedFiles,
        notes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      );

      // Award XP
      await UserService()
          .awardXp(widget.studentId, AppConstants.xpPerProjectSubmission);

      // Refresh submission
      final updated = await ProjectService()
          .getStudentSubmission(widget.project.id, widget.studentId);

      if (mounted) {
        setState(() {
          _submission = updated;
          _pickedFiles.clear();
          _submitting = false;
          _statusMessage = null;
        });
        _showSnack(
            '🎉 Submitted! +${AppConstants.xpPerProjectSubmission} XP earned!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _statusMessage = null;
        });
        _showSnack('Upload failed: $e', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4':
      case 'mov':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/m4a';
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alreadySubmitted = _submission != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Due date badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  color: Colors.white70, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                widget.project.isPastDue
                                    ? 'Past due'
                                    : widget.project.daysRemaining == 0
                                        ? 'Due today!'
                                        : '${widget.project.daysRemaining} days remaining',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Feedback (if graded) ─────────────────────────────────
                if (_submission?.isGraded == true) ...[
                  _FeedbackCard(submission: _submission!),
                  const SizedBox(height: 20),
                ],

                // ── Description ──────────────────────────────────────────
                _SectionHeader(
                    icon: Icons.description_rounded,
                    label: 'Project Brief',
                    color: AppColors.primary),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _RichDescription(
                        text: widget.project.description),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Existing submission ──────────────────────────────────
                if (alreadySubmitted) ...[
                  _SectionHeader(
                      icon: Icons.check_circle_rounded,
                      label: 'Your Submission',
                      color: AppColors.success),
                  const SizedBox(height: 12),
                  _SubmittedFilesCard(submission: _submission!),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ve already submitted this project. You can add more files below.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Submit section ───────────────────────────────────────
                _SectionHeader(
                    icon: Icons.upload_rounded,
                    label: alreadySubmitted
                        ? 'Add More Files'
                        : 'Submit Your Work',
                    color: AppColors.secondary),
                const SizedBox(height: 12),

                // Notes field
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Add notes about your work (optional)…',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon:
                        const Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                // File picker
                if (_pickedFiles.isNotEmpty) ...[
                  ..._pickedFiles.asMap().entries.map(
                        (e) => _FileChip(
                          file: e.value,
                          onRemove: () => _removeFile(e.key),
                        ),
                      ),
                  const SizedBox(height: 12),
                ],

                // Add file button
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickFiles,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('Attach Files'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accepted: images, screenshots, PDF, audio, video',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Upload progress
                if (_submitting) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      minHeight: 8,
                      backgroundColor:
                          AppColors.secondary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage ?? 'Uploading…',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_submitting
                        ? 'Submitting…'
                        : alreadySubmitted
                            ? 'Add to Submission'
                            : 'Submit Project  (+20 XP)'),
                    style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

// ─── Rich Description (renders section headers from ── markers) ───────────────

class _RichDescription extends StatelessWidget {
  final String text;
  const _RichDescription({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('──')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              line.replaceAll('─', '').trim(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          );
        }
        if (line.trim().isEmpty) return const SizedBox(height: 4);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5)),
        );
      }).toList(),
    );
  }
}

// ─── Submitted Files Card ─────────────────────────────────────────────────────

class _SubmittedFilesCard extends StatelessWidget {
  final SubmissionModel submission;
  const _SubmittedFilesCard({required this.submission});

  IconData _iconForType(String type) {
    switch (type) {
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.mic_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.image_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'video':
        return AppColors.error;
      case 'audio':
        return AppColors.info;
      case 'pdf':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.success.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                    'Submitted ${_formatDate(submission.submittedAt)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        fontSize: 13)),
              ],
            ),
            if (submission.notes != null &&
                submission.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(submission.notes!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            ],
            if (submission.mediaFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...submission.mediaFiles
                  .map((f) => _SubmittedFileTile(file: f)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ─── Feedback Card ────────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final SubmissionModel submission;
  const _FeedbackCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rate_review_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Teacher Feedback',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
          if (submission.grade != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Grade: ${submission.grade}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ),
          ],
          if (submission.feedback != null &&
              submission.feedback!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              submission.feedback!,
              style: const TextStyle(
                  color: Colors.white, height: 1.5, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Submitted File Tile (tappable — student views own files) ─────────────────

class _SubmittedFileTile extends StatelessWidget {
  final MediaFile file;
  const _SubmittedFileTile({required this.file});

  IconData get _icon {
    switch (file.type) {
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.mic_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.image_rounded;
    }
  }

  Color get _color {
    switch (file.type) {
      case 'video':
        return AppColors.error;
      case 'audio':
        return AppColors.info;
      case 'pdf':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  Future<void> _open(BuildContext context) async {
    if (file.type == 'image') {
      showDialog(
        context: context,
        builder: (_) => _FullScreenImageDialog(
            url: file.url, fileName: file.fileName),
      );
    } else {
      final uri = Uri.parse(file.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon, color: _color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.fileName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      file.type == 'image'
                          ? 'Tap to view'
                          : 'Tap to open',
                      style: TextStyle(
                          fontSize: 11,
                          color: _color,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(file.sizeFormatted,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.secondary)),
              const SizedBox(width: 6),
              Icon(
                file.type == 'image'
                    ? Icons.fullscreen_rounded
                    : Icons.open_in_new_rounded,
                size: 15,
                color: _color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full-Screen Image Viewer (student side) ──────────────────────────────────

class _FullScreenImageDialog extends StatelessWidget {
  final String url;
  final String fileName;
  const _FullScreenImageDialog(
      {required this.url, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(fileName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: 'Open in browser',
              icon: const Icon(Icons.open_in_browser_rounded,
                  color: Colors.white),
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 6.0,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                    color: Colors.white),
              ),
              errorWidget: (_, __, ___) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image_rounded,
                      color: Colors.white54, size: 64),
                  const SizedBox(height: 12),
                  const Text('Could not load image',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('Open in browser',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── File Chip ────────────────────────────────────────────────────────────────

class _FileChip extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;

  const _FileChip({required this.file, required this.onRemove});

  String get _sizeLabel {
    final s = file.size;
    if (s < 1024) return '${s}B';
    if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)}KB';
    return '${(s / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                Text(_sizeLabel,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                color: AppColors.error, size: 18),
          ),
        ],
      ),
    );
  }
}
