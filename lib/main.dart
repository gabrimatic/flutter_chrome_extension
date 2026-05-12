import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FlutterChromeExtensionApp());
}

class FlutterChromeExtensionApp extends StatelessWidget {
  const FlutterChromeExtensionApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF101418);
    const surface = Color(0xFF182028);
    const primary = Color(0xFF38BDF8);

    return MaterialApp(
      title: 'Flutter Chrome Extension',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: primary,
              brightness: Brightness.dark,
            ).copyWith(
              primary: primary,
              secondary: const Color(0xFF7DD3FC),
              tertiary: const Color(0xFFFACC15),
              surface: surface,
              onSurface: const Color(0xFFE5EDF3),
            ),
        scaffoldBackgroundColor: background,
        cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Color(0xFF2A3642)),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF0F766E),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const ExtensionPopup(),
    );
  }
}

enum PopupSection { overview, build, ship }

class ExtensionPopup extends StatefulWidget {
  const ExtensionPopup({super.key});

  @override
  State<ExtensionPopup> createState() => _ExtensionPopupState();
}

class _ExtensionPopupState extends State<ExtensionPopup> {
  static const _buildCommand =
      'flutter build web --csp --no-web-resources-cdn --no-source-maps';

  PopupSection _section = PopupSection.overview;
  final Set<String> _checkedItems = {'manifest', 'build'};

  bool get _isExtensionContext => Uri.base.scheme == 'chrome-extension';

  int get _checklistProgress => _checkedItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PopupHeader(),
                  const SizedBox(height: 14),
                  _SectionPicker(
                    selected: _section,
                    onSelectionChanged: (section) {
                      setState(() => _section = section);
                    },
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _buildSelectedSection(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSection() {
    return switch (_section) {
      PopupSection.overview => _OverviewSection(
        isExtensionContext: _isExtensionContext,
        checklistProgress: _checklistProgress,
        checklistTotal: releaseChecklist.length,
      ),
      PopupSection.build => const _BuildSection(buildCommand: _buildCommand),
      PopupSection.ship => _ShipSection(
        checkedItems: _checkedItems,
        onChanged: _toggleChecklistItem,
      ),
    };
  }

  void _toggleChecklistItem(String id, bool? value) {
    setState(() {
      if (value ?? false) {
        _checkedItems.add(id);
      } else {
        _checkedItems.remove(id);
      }
    });
  }
}

class _PopupHeader extends StatelessWidget {
  const _PopupHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(Icons.extension_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flutter Chrome Extension',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manifest V3 popup built with Flutter Web.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xFFA7B3BE), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(label: 'Manifest V3', icon: Icons.verified_outlined),
            _StatusChip(label: 'No permissions', icon: Icons.lock_outline),
            _StatusChip(
              label: 'Local assets',
              icon: Icons.inventory_2_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: const Color(0xFF2A3642)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionPicker extends StatelessWidget {
  const _SectionPicker({
    required this.selected,
    required this.onSelectionChanged,
  });

  final PopupSection selected;
  final ValueChanged<PopupSection> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PopupSection>(
      segments: const [
        ButtonSegment(
          value: PopupSection.overview,
          label: Text('Overview'),
          icon: Icon(Icons.dashboard_outlined),
        ),
        ButtonSegment(
          value: PopupSection.build,
          label: Text('Build'),
          icon: Icon(Icons.terminal_outlined),
        ),
        ButtonSegment(
          value: PopupSection.ship,
          label: Text('Ship'),
          icon: Icon(Icons.rocket_launch_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        onSelectionChanged(selection.single);
      },
      showSelectedIcon: false,
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.isExtensionContext,
    required this.checklistProgress,
    required this.checklistTotal,
  });

  final bool isExtensionContext;
  final int checklistProgress;
  final int checklistTotal;

  @override
  Widget build(BuildContext context) {
    return _ScrollableSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MetricGrid(
            children: [
              _MetricTile(
                label: 'Runtime',
                value: isExtensionContext ? 'Extension' : 'Preview',
                icon: Icons.travel_explore_outlined,
              ),
              const _MetricTile(
                label: 'Permissions',
                value: '0',
                icon: Icons.shield_outlined,
              ),
              _MetricTile(
                label: 'Checklist',
                value: '$checklistProgress/$checklistTotal',
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'What this popup is for',
            body:
                'Use it as a small, permission-light Chrome extension shell. The UI is Flutter, the browser package is static files, and the manifest stays readable enough to audit before shipping.',
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Default stance',
            body:
                'No background worker, no host permissions, no remote assets. Add permissions only when the feature needs them.',
            icon: Icons.rule_outlined,
          ),
        ],
      ),
    );
  }
}

class _BuildSection extends StatelessWidget {
  const _BuildSection({required this.buildCommand});

  final String buildCommand;

  @override
  Widget build(BuildContext context) {
    return _ScrollableSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CommandCard(command: buildCommand),
          const SizedBox(height: 12),
          const _StepCard(
            steps: [
              'Run the command from the repo root.',
              'Open chrome://extensions and turn on Developer mode.',
              'Load build/web as an unpacked extension.',
              'Reload the extension after each new build.',
            ],
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Why these flags',
            body:
                'The build disables dynamic code generation, keeps Flutter web resources local to the package, and skips source maps for a cleaner extension artifact.',
            icon: Icons.tune_outlined,
          ),
        ],
      ),
    );
  }
}

class _ShipSection extends StatelessWidget {
  const _ShipSection({required this.checkedItems, required this.onChanged});

  final Set<String> checkedItems;
  final void Function(String id, bool? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return _ScrollableSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Release checklist',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  for (final item in releaseChecklist)
                    _ChecklistTile(
                      item: item,
                      value: checkedItems.contains(item.id),
                      onChanged: (value) => onChanged(item.id, value),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Package target',
            body:
                'Ship the contents of build/web. Keep the manifest and icons at the package root so Chrome can read them without a server.',
            icon: Icons.inventory_2_outlined,
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 16) / 3;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth.clamp(96, 132), child: child),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: colorScheme.tertiary),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFA7B3BE), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: colorScheme.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: const TextStyle(
                      color: Color(0xFFA7B3BE),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({required this.command});

  final String command;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Build the extension',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy build command',
                  onPressed: () => _copyCommand(context),
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0D10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3642)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  command,
                  style: const TextStyle(
                    color: Color(0xFFBAE6FD),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCommand(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: command));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Build command copied')));
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Load it in Chrome',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final (index, step) in steps.indexed)
              Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          color: Color(0xFFC5D0DA),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.value,
    required this.onChanged,
  });

  final ReleaseChecklistItem item;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        item.title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        item.description,
        style: const TextStyle(
          color: Color(0xFFA7B3BE),
          fontSize: 12,
          height: 1.25,
        ),
      ),
    );
  }
}

class _ScrollableSection extends StatelessWidget {
  const _ScrollableSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey<String>('extension-popup-section'),
      child: child,
    );
  }
}

@visibleForTesting
const releaseChecklist = [
  ReleaseChecklistItem(
    id: 'manifest',
    title: 'Manifest matches the package',
    description: 'Name, version, popup path, icons, and CSP are current.',
  ),
  ReleaseChecklistItem(
    id: 'build',
    title: 'Build is extension-safe',
    description: 'CSP mode is on, resources are local, source maps are off.',
  ),
  ReleaseChecklistItem(
    id: 'chrome',
    title: 'Chrome loads the unpacked folder',
    description: 'The popup opens from build/web without console errors.',
  ),
  ReleaseChecklistItem(
    id: 'docs',
    title: 'Docs match the shipped behavior',
    description: 'README commands and manifest claims match the build.',
  ),
];

@visibleForTesting
class ReleaseChecklistItem {
  const ReleaseChecklistItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}
