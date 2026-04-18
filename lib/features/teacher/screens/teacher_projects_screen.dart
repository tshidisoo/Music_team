import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/project_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import 'create_project_screen.dart';
import 'teacher_submissions_screen.dart';

class TeacherProjectsScreen extends StatefulWidget {
  const TeacherProjectsScreen({super.key});

  @override
  State<TeacherProjectsScreen> createState() => _TeacherProjectsScreenState();
}

class _TeacherProjectsScreenState extends State<TeacherProjectsScreen> {
  bool _seeding = false;
  String? _seedResult;

  @override
  void initState() {
    super.initState();
    // Auto-deactivate any projects whose deadline has already passed
    ProjectService().checkAndDeactivateExpiredProjects();
  }

  Future<void> _seedProjects(String teacherId) async {
    setState(() {
      _seeding = true;
      _seedResult = null;
    });
    try {
      await ProjectService().seedProjects(teacherId);
      setState(() => _seedResult = '✅ 10 projects seeded successfully!');
    } catch (e) {
      setState(() => _seedResult = '❌ Error: $e');
    } finally {
      setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId =
        authState is AuthAuthenticated ? authState.user.uid : '';

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
                    child: const Icon(Icons.assignment_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Projects',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            )),
                        Text('Manage & assign projects',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: CustomScrollView(
          slivers: [
            // ── Admin tools ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create new project button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateProjectScreen(
                                teacherId: teacherId),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create New Project'),
                        style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Seed projects card
                    _SeedProjectsCard(
                      seeding: _seeding,
                      result: _seedResult,
                      onSeed: () => _seedProjects(teacherId),
                    ),
                    const SizedBox(height: 20),
                    Text('All Projects',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Project list ──────────────────────────────────────────────
            StreamBuilder<List<ProjectModel>>(
              stream: ProjectService().watchAllProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    )),
                  );
                }
                final projects = snapshot.data ?? [];
                if (projects.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 48,
                                color: AppColors.secondary
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text('No projects yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            const SizedBox(height: 4),
                            Text(
                                'Create a project or seed the 10 default projects above.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TeacherProjectCard(
                          project: projects[i],
                          teacherId: teacherId,
                        ),
                      ),
                      childCount: projects.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Seed Projects Card ───────────────────────────────────────────────────────

class _SeedProjectsCard extends StatelessWidget {
  final bool seeding;
  final String? result;
  final VoidCallback onSeed;

  const _SeedProjectsCard(
      {required this.seeding,
      required this.result,
      required this.onSeed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seed Default Projects',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                          'Load 10 pre-built projects covering all 21 lessons',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: result!.startsWith('✅')
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(result!,
                    style: TextStyle(
                      color: result!.startsWith('✅')
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    )),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: seeding ? null : onSeed,
                icon: seeding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded),
                label: Text(seeding ? 'Seeding…' : 'Seed 10 Projects'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Teacher Project Card ─────────────────────────────────────────────────────

class _TeacherProjectCard extends StatefulWidget {
  final ProjectModel project;
  final String teacherId;

  const _TeacherProjectCard(
      {required this.project, required this.teacherId});

  @override
  State<_TeacherProjectCard> createState() =>
      _TeacherProjectCardState();
}

class _TeacherProjectCardState extends State<_TeacherProjectCard> {
  bool _toggling = false;

  Future<void> _toggleActive() async {
    setState(() => _toggling = true);
    try {
      await ProjectService().toggleProjectActive(
          widget.project.id, !widget.project.isActive);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  Future<void> _editDeadline(BuildContext context) async {
    final p = widget.project;
    final initial = p.dueDate.isAfter(DateTime.now())
        ? p.dueDate
        : DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'Set New Deadline',
      confirmText: 'Set Deadline',
    );
    if (picked == null) return;
    try {
      await ProjectService().updateProjectDueDate(p.id, picked);
      // If the new date is in the future, also reactivate
      if (picked.isAfter(DateTime.now()) && !p.isActive) {
        await ProjectService().toggleProjectActive(p.id, true);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Deadline updated!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(p.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                // Active toggle
                _toggling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                    : GestureDetector(
                        onTap: _toggleActive,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.isActive
                                ? AppColors.success
                                    .withValues(alpha: 0.12)
                                : AppColors.error
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: p.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            // Due date + edit deadline
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 13, color: AppColors.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    p.isPastDue
                        ? 'Past due — ${_formatDate(p.dueDate)}'
                        : p.daysRemaining == 0
                            ? 'Due today!'
                            : 'Due ${_formatDate(p.dueDate)} · ${p.daysRemaining}d left',
                    style: TextStyle(
                        fontSize: 12,
                        color: p.isPastDue
                            ? AppColors.error
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                InkWell(
                  onTap: () => _editDeadline(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_calendar_rounded,
                            size: 13,
                            color: AppColors.primary
                                .withValues(alpha: 0.7)),
                        const SizedBox(width: 3),
                        Text('Edit',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              p.description.length > 100
                  ? '${p.description.substring(0, 100)}…'
                  : p.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherSubmissionsScreen(
                            project: p),
                      ),
                    ),
                    icon: const Icon(Icons.rate_review_rounded,
                        size: 16),
                    label: const Text('View Submissions'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
