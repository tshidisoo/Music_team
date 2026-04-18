import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/project_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import 'project_detail_screen.dart';

class StudentProjectsScreen extends StatelessWidget {
  const StudentProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId =
        authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
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
                    child: const Icon(Icons.assignment_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Projects',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          )),
                      Text('Theory + Maestro practicals',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: StreamBuilder<List<ProjectModel>>(
          stream: ProjectService().watchActiveProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final projects = snapshot.data ?? [];
            if (projects.isEmpty) {
              return _EmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _ProjectCard(
                project: projects[i],
                studentId: userId,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Project Card ─────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final String studentId;

  const _ProjectCard({required this.project, required this.studentId});

  Color _dueDateColor() {
    if (project.isPastDue) return AppColors.error;
    if (project.daysRemaining <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String _dueDateLabel() {
    if (project.isPastDue) return 'Past due';
    if (project.daysRemaining == 0) return 'Due today!';
    if (project.daysRemaining == 1) return '1 day left';
    return '${project.daysRemaining} days left';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SubmissionModel?>(
      stream: ProjectService()
          .watchStudentSubmission(project.id, studentId),
      builder: (context, snap) {
        final submitted = snap.data != null;
        final graded = snap.data?.isGraded ?? false;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(
                  project: project,
                  studentId: studentId,
                  existingSubmission: snap.data,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.assignment_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            // Due date chip
                            Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 13, color: _dueDateColor()),
                                const SizedBox(width: 4),
                                Text(
                                  _dueDateLabel(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _dueDateColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      _StatusBadge(submitted: submitted, graded: graded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description preview
                  Text(
                    project.description.length > 120
                        ? '${project.description.substring(0, 120)}...'
                        : project.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Footer
                  Row(
                    children: [
                      // Media allowed chips
                      ...project.mediaAllowed
                          .take(3)
                          .map((m) => _MediaTypeChip(type: m)),
                      const Spacer(),
                      // XP reward
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.xpGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: AppColors.xpGold, size: 12),
                            SizedBox(width: 4),
                            Text('+20 XP',
                                style: TextStyle(
                                  color: AppColors.xpGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool submitted;
  final bool graded;

  const _StatusBadge({required this.submitted, required this.graded});

  @override
  Widget build(BuildContext context) {
    if (graded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Graded',
            style: TextStyle(
                color: AppColors.info,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
    }
    if (submitted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Submitted',
            style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Pending',
          style: TextStyle(
              color: AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _MediaTypeChip extends StatelessWidget {
  final String type;
  const _MediaTypeChip({required this.type});

  IconData get _icon {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(_icon, size: 12, color: AppColors.primary),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 64,
              color: AppColors.secondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No active projects',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Your teacher hasn\'t assigned any projects yet.\nCheck back soon!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
