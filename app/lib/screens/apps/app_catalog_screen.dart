import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/theme/droid_theme.dart';

class AppCatalogScreen extends StatefulWidget {
  const AppCatalogScreen({super.key});

  @override
  State<AppCatalogScreen> createState() => _AppCatalogScreenState();
}

class _AppCatalogScreenState extends State<AppCatalogScreen> {
  // ── Categories ──────────────────────────────────────────────────────────────

  static const _categoryDev = 'Development';
  static const _categoryGaming = 'Gaming';
  static const _categoryMedia = 'Media & Graphics';
  static const _categoryProductivity = 'Productivity';
  static const _categorySystem = 'System';

  static const _apps = [
    // ── Development ──
    _OptionalApp(
      id: 'firefox',
      name: 'Firefox',
      description: 'Full desktop web browser with ARM64 native build.',
      icon: Icons.public_rounded,
      color: Color(0xFFFF7139),
      category: _categoryDev,
    ),
    _OptionalApp(
      id: 'code_oss',
      name: 'Code OSS',
      description: 'Source-code editor. Large download (~200 MB).',
      icon: Icons.code_rounded,
      color: Color(0xFF23A8F2),
      category: _categoryDev,
    ),
    _OptionalApp(
      id: 'nodejs',
      name: 'Node.js + npm',
      description: 'JavaScript runtime and package manager.',
      icon: Icons.javascript_rounded,
      color: Color(0xFF68A063),
      category: _categoryDev,
    ),
    _OptionalApp(
      id: 'python3_dev',
      name: 'Python 3 + pip',
      description: 'Python interpreter with pip and common libraries.',
      icon: Icons.terminal_rounded,
      color: Color(0xFF3776AB),
      category: _categoryDev,
    ),
    _OptionalApp(
      id: 'neovim',
      name: 'Neovim',
      description: 'Hyperextensible terminal text editor.',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF57A143),
      category: _categoryDev,
    ),

    // ── Gaming ──
    _OptionalApp(
      id: 'steam_native',
      name: 'Steam (Native ARM64)',
      description: 'Steam client for Linux ARM64. Runs native ARM64 games and some x86-compatible titles.',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF1B2838),
      category: _categoryGaming,
      requiresProot: true,
    ),
    _OptionalApp(
      id: 'box64',
      name: 'Box64',
      description: 'x86_64 userspace emulator. Required for running x86 Steam games and Windows apps on ARM.',
      icon: Icons.memory_rounded,
      color: Color(0xFF7B68EE),
      category: _categoryGaming,
      requiresProot: true,
    ),
    _OptionalApp(
      id: 'wine_arm64',
      name: 'Wine (ARM64)',
      description: 'Run Windows applications. Use with Box64 for best x86 compatibility.',
      icon: Icons.wine_bar_rounded,
      color: Color(0xFFB0112C),
      category: _categoryGaming,
      requiresProot: true,
    ),
    _OptionalApp(
      id: 'lutris',
      name: 'Lutris',
      description: 'Open gaming platform. Manages GOG, Humble, and custom game installations.',
      icon: Icons.videogame_asset_rounded,
      color: Color(0xFFFF6D00),
      category: _categoryGaming,
      requiresProot: true,
    ),

    // ── Media & Graphics ──
    _OptionalApp(
      id: 'imagemagick',
      name: 'ImageMagick',
      description: 'Command-line image conversion and processing.',
      icon: Icons.image_rounded,
      color: DroidTheme.primaryLight,
      category: _categoryMedia,
    ),
    _OptionalApp(
      id: 'vlc',
      name: 'VLC',
      description: 'Multimedia player supporting almost every format.',
      icon: Icons.play_circle_filled_rounded,
      color: Color(0xFFFF8800),
      category: _categoryMedia,
    ),
    _OptionalApp(
      id: 'gimp',
      name: 'GIMP',
      description: 'GNU Image Manipulation Program. Full-featured photo editor.',
      icon: Icons.brush_rounded,
      color: Color(0xFF5A697D),
      category: _categoryMedia,
    ),
    _OptionalApp(
      id: 'ffmpeg',
      name: 'FFmpeg',
      description: 'Powerful CLI video/audio transcoder and streaming tool.',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFF007808),
      category: _categoryMedia,
    ),

    // ── Productivity ──
    _OptionalApp(
      id: 'libreoffice',
      name: 'LibreOffice',
      description: 'Office suite with Writer, Calc, and Impress. Very large download (~600 MB).',
      icon: Icons.description_rounded,
      color: Color(0xFF18A303),
      category: _categoryProductivity,
      requiresProot: true,
    ),

    // ── System ──
    _OptionalApp(
      id: 'htop',
      name: 'htop + system tools',
      description: 'Interactive process monitor plus neofetch, btop, and lsof.',
      icon: Icons.monitor_heart_rounded,
      color: Color(0xFF00BCD4),
      category: _categorySystem,
    ),
    _OptionalApp(
      id: 'mali_accel',
      name: 'Mali GPU Acceleration',
      description:
          'Enable ANGLE + Vulkan hardware rendering for Mali/Exynos/MediaTek GPUs. '
          'Replaces software llvmpipe. Mali devices only.',
      icon: Icons.speed_rounded,
      color: Color(0xFF00E676),
      category: _categorySystem,
    ),
  ];

  static const _proot = _OptionalApp(
    id: 'proot_debian',
    name: 'Debian (PRoot)',
    description:
        'Minimal PRoot base system. Required for gaming apps (Steam, Box64, Wine).',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFFD70A53),
    category: _categorySystem,
  );

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshOptionalApps();
    });
  }

  Future<void> _install(_OptionalApp app) async {
    final state = context.read<AppState>();
    // Guard: gaming apps need Debian PRoot
    if (app.requiresProot && !state.optionalApps.containsKey('proot_debian')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Install "Debian (PRoot)" first — gaming apps run inside Debian.',
          ),
          backgroundColor: DroidTheme.error,
        ),
      );
      return;
    }

    final ok = await state.installOptionalApp(app.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${app.name} installed'
              : '${app.name} installation failed. See the log below.',
        ),
        backgroundColor: ok ? DroidTheme.success : DroidTheme.error,
      ),
    );
  }

  List<String> _categories(List<_OptionalApp> apps) {
    final cats = apps.map((a) => a.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allApps = state.hasRoot ? _apps : [..._apps, _proot];
    final categories = _categories(allApps);
    final visible = _selectedCategory == 'All'
        ? allApps
        : allApps.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add applications')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: DroidTheme.backgroundGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category filter bar ──────────────────────────────────────────
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    selectedColor: DroidTheme.primaryLight.withValues(alpha: 0.22),
                    labelStyle: TextStyle(
                      color: selected
                          ? DroidTheme.primaryLight
                          : DroidTheme.textSecondary,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            // ── App list ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    'Install only what you need. Each package is independent and can be safely retried.',
                    style: DroidTheme.bodyMd,
                  ),
                  const SizedBox(height: 16),
                  for (final app in visible) ...[
                    _buildAppCard(state, app),
                    const SizedBox(height: 10),
                  ],
                  if (state.installingOptionalApp != null ||
                      state.optionalInstallLog.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInstallPanel(state),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(AppState state, _OptionalApp app) {
    final installed = state.optionalApps[app.id] == true;
    final installing = state.installingOptionalApp == app.id;
    final busy = state.installingOptionalApp != null;

    // Show PRoot badge for gaming apps when PRoot not yet installed
    final needsProot = app.requiresProot &&
        !(state.optionalApps['proot_debian'] == true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(
          color: installed
              ? DroidTheme.success.withValues(alpha: 0.45)
              : DroidTheme.surfaceBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: app.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(app.icon, color: app.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(app.name, style: DroidTheme.headingSm),
                    if (needsProot) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD70A53).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Needs Debian',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFD70A53),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(app.description, style: DroidTheme.bodySm),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (installed)
            const Icon(Icons.check_circle_rounded, color: DroidTheme.success)
          else if (installing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            FilledButton(
              onPressed: busy ? null : () => _install(app),
              child: const Text('Install'),
            ),
        ],
      ),
    );
  }

  Widget _buildInstallPanel(AppState state) {
    final cleanLog = state.optionalInstallLog.replaceAll(
      RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'),
      '',
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF080D18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.optionalInstallStatus.isEmpty
                      ? 'Package log'
                      : state.optionalInstallStatus,
                  style: DroidTheme.headingSm,
                ),
              ),
              Text(
                '${(state.optionalInstallProgress * 100).round()}%',
                style: DroidTheme.monoSm,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: state.installingOptionalApp == null
                ? null
                : state.optionalInstallProgress,
          ),
          if (cleanLog.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: SingleChildScrollView(
                reverse: true,
                child: SelectableText(
                  cleanLog,
                  style: DroidTheme.monoSm.copyWith(height: 1.35),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionalApp {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String category;
  final bool requiresProot;

  const _OptionalApp({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.requiresProot = false,
  });
}
