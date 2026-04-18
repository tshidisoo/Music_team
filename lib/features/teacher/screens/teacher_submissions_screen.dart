import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/project_service.dart';

class TeacherSubmissionsScreen extends StatelessWidget {
  final ProjectModel project;

  const TeacherSubmissionsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            Text('Submissions',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.secondary)),
          ],
        ),
      ),
      body: StreamBuilder<List<SubmissionModel>>(
        stream: ProjectService().watchSubmissionsForProject(project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final submissions = snapshot.data ?? [];
          if (submissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No submissions yet',
                      style:
                          Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Students haven\'t submitted anything yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) =>
                _SubmissionCard(submission: submissions[i]),
          );
        },
      ),
    );
  }
}

// ─── Submission Card ──────────────────────────────────────────────────────────

class _SubmissionCard extends StatefulWidget {
  final SubmissionModel submission;
  const _SubmissionCard({required this.submission});

  @override
  State<_SubmissionCard> createState() => _SubmissionCardState();
}

class _SubmissionCardState extends State<_SubmissionCard> {
  bool _expanded = false;
  bool _saving = false;
  late TextEditingController _feedbackCtrl;
  late TextEditingController _gradeCtrl;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl =
        TextEditingController(text: widget.submission.feedback ?? '');
    _gradeCtrl =
        TextEditingController(text: widget.submission.grade ?? '');
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    if (_feedbackCtrl.text.trim().isEmpty &&
        _gradeCtrl.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      await ProjectService().gradeSubmission(
        submissionId: widget.submission.id,
        grade: _gradeCtrl.text.trim().isEmpty
            ? null
            : _gradeCtrl.text.trim(),
        feedback: _feedbackCtrl.text.trim().isEmpty
            ? null
            : _feedbackCtrl.text.trim(),
        gradedBy: 'teacher',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Feedback saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        setState(() => _expanded = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

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
    final s = widget.submission;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      s.studentName.isNotEmpty
                          ? s.studentName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.studentName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text(
                          'Submitted ${_formatDate(s.submittedAt)} · ${s.mediaFiles.length} file${s.mediaFiles.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Grade badge
                  if (s.isGraded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.grade ?? 'Feedback',
                        style: const TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Review',
                          style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ──────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes
                  if (s.notes != null && s.notes!.isNotEmpty) ...[
                    Text('Student Notes',
                        style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(s.notes!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.5)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Files
                  if (s.mediaFiles.isNotEmpty) ...[
                    Text('Submitted Files',
                        style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary)),
                    const SizedBox(height: 8),
                    ...s.mediaFiles.map(
                        (f) => _FileTile(file: f)),
                    const SizedBox(height: 16),
                  ],

                  // ── Grade & Feedback form ──────────────────────────
                  Text('Grade & Feedback',
                      style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.info)),
                  const SizedBox(height: 10),

                  // Grade input
                  TextField(
                    controller: _gradeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Grade (e.g. A, 8/10, Excellent)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon:
                          const Icon(Icons.grade_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Feedback input
                  TextField(
                    controller: _feedbackCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Written Feedback',
                      hintText:
                          'Write your comments for the student…',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon:
                          const Icon(Icons.rate_review_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _saveGrade,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Icon(Icons.save_rounded),
                      label: Text(_saving
                          ? 'Saving…'
                          : 'Save Feedback'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── All Submissions Screen (tab-level view) ──────────────────────────────────

class TeacherAllSubmissionsScreen extends StatelessWidget {
  const TeacherAllSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.rate_review_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Submissions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          )),
                      Text('Review student work',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: StreamBuilder<List<SubmissionModel>>(
          stream: ProjectService().watchAllSubmissions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final submissions = snapshot.data ?? [];
            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('No submissions yet',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Students haven\'t submitted any work yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            // Group by ungraded first
            final ungraded =
                submissions.where((s) => !s.isGraded).toList();
            final graded =
                submissions.where((s) => s.isGraded).toList();
            final sorted = [...ungraded, ...graded];

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: sorted.length + (ungraded.isNotEmpty ? 1 : 0) +
                  (graded.isNotEmpty ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                // Section headers
                if (ungraded.isNotEmpty && i == 0) {
                  return _SectionLabel(
                      label:
                          'Needs Review (${ungraded.length})',
                      color: AppColors.warning);
                }
                if (graded.isNotEmpty &&
                    i == (ungraded.isNotEmpty ? ungraded.length + 1 : 0)) {
                  return _SectionLabel(
                      label: 'Graded (${graded.length})',
                      color: AppColors.success);
                }
                // Adjust index for section headers
                int idx = i;
                if (ungraded.isNotEmpty) idx--;
                if (graded.isNotEmpty &&
                    i > (ungraded.isNotEmpty ? ungraded.length : -1)) {
                  idx--;
                }
                if (idx < 0 || idx >= sorted.length) {
                  return const SizedBox.shrink();
                }
                return _SubmissionCard(submission: sorted[idx]);
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Tappable File Tile ───────────────────────────────────────────────────────

class _FileTile extends StatelessWidget {
  final MediaFile file;
  const _FileTile({required this.file});

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

  Future<void> _open(BuildContext context) async {
    if (file.type == 'image') {
      showDialog(
        context: context,
        builder: (_) => _ImageViewerDialog(
          url: file.url,
          fileName: file.fileName,
        ),
      );
    } else {
      final uri = Uri.parse(file.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not open file.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(file.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconForType(file.type),
                      color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.fileName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(file.sizeFormatted,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary)),
                          const SizedBox(width: 8),
                          Text(
                            file.type == 'image'
                                ? 'Tap to view'
                                : 'Tap to open',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  file.type == 'image'
                      ? Icons.fullscreen_rounded
                      : Icons.open_in_new_rounded,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Full-Screen Image Viewer ─────────────────────────────────────────────────

class _ImageViewerDialog extends StatelessWidget {
  final String url;
  final String fileName;

  const _ImageViewerDialog(
      {required this.url, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            fileName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Open in browser button
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
                  const Text(
                    'Could not load image',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 14),
                  ),
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
                        style: TextStyle(color: Colors.white)),
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

// ─── All Submissions Section Label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
