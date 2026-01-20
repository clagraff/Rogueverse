import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/text_template_service.dart';

/// Screen displaying all available template variables with search functionality.
///
/// Shows variables grouped by namespace (Keybindings, Player, NPC, etc.)
/// with their descriptions and current values.
class TemplateVariablesScreen extends StatefulWidget {
  const TemplateVariablesScreen({super.key});

  @override
  State<TemplateVariablesScreen> createState() => _TemplateVariablesScreenState();
}

class _TemplateVariablesScreenState extends State<TemplateVariablesScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      // If search field has text, clear it; otherwise go back
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      } else {
        Navigator.of(context).pop();
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _scrollController.animateTo(
        (_scrollController.offset - 50).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _scrollController.animateTo(
        (_scrollController.offset + 50).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    } else if (key == LogicalKeyboardKey.pageUp) {
      _scrollController.animateTo(
        (_scrollController.offset - 300).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    } else if (key == LogicalKeyboardKey.pageDown) {
      _scrollController.animateTo(
        (_scrollController.offset + 300).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  /// Filters variables based on search query.
  List<TemplateVariableInfo> _filterVariables(List<TemplateVariableInfo> variables) {
    if (_searchQuery.isEmpty) return variables;

    return variables.where((v) {
      return v.key.toLowerCase().contains(_searchQuery) ||
          v.description.toLowerCase().contains(_searchQuery) ||
          (v.currentValue?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final namespaces = TextTemplateService.instance.getNamespaces();

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back (Escape)',
          ),
          title: const Text('Template Variables'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search variables...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ),
        body: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: namespaces.length,
          itemBuilder: (context, namespaceIndex) {
            final namespace = namespaces[namespaceIndex];
            final filteredVariables = _filterVariables(namespace.getVariables());

            // Skip empty namespaces after filtering
            if (filteredVariables.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Namespace header
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: namespaceIndex == 0 ? 0 : 16),
                  child: Text(
                    namespace.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Variable cards
                ...filteredVariables.map((variable) => _VariableCard(variable: variable)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Card displaying a single template variable.
class _VariableCard extends StatelessWidget {
  final TemplateVariableInfo variable;

  const _VariableCard({required this.variable});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key and value on same row for easy scanning
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Key (template syntax)
                SelectableText(
                  '{{${variable.key}}}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),

                // Current value or "requires context" badge
                if (variable.requiresContext)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'context',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  )
                else if (variable.currentValue != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      variable.currentValue!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Description below
            Text(
              variable.description,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
