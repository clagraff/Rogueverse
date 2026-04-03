import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/crafting/recipe_service.dart';

/// Crafting tab content for the character screen.
///
/// Displays recipes that can be crafted directly from inventory
/// (recipes with empty requiredCapabilities), or station-compatible
/// recipes when a [station] entity is provided.
class CraftingTabContent extends StatefulWidget {
  final World world;
  final Entity player;
  final FocusNode? parentFocusNode;

  /// Optional crafting station entity. When provided, shows only
  /// station-compatible recipes and emits [StationCraftIntent].
  final Entity? station;

  const CraftingTabContent({
    super.key,
    required this.world,
    required this.player,
    this.parentFocusNode,
    this.station,
  });

  @override
  State<CraftingTabContent> createState() => _CraftingTabContentState();
}

class _CraftingTabContentState extends State<CraftingTabContent> {
  final FocusNode _focusNode = FocusNode();
  final _keybindings = KeyBindingService.instance;
  int _selectedIndex = 0;
  List<CraftableRecipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _refreshRecipes() {
    setState(() {
      final station = widget.station;
      _recipes = station != null
          ? RecipeService.getStationRecipes(widget.world, station,
              crafter: widget.player)
          : RecipeService.getDirectRecipes(widget.world, widget.player);
      if (_selectedIndex >= _recipes.length && _recipes.isNotEmpty) {
        _selectedIndex = _recipes.length - 1;
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // Navigation
    if (key == LogicalKeyboardKey.arrowUp ||
        _keybindings.matches('menu.up', keysPressed)) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _recipes.length - 1);
      });
      return;
    }

    if (key == LogicalKeyboardKey.arrowDown ||
        _keybindings.matches('menu.down', keysPressed)) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _recipes.length - 1);
      });
      return;
    }

    // Craft action
    if (_keybindings.matches('menu.select', keysPressed) ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _craftSelected();
      return;
    }
  }

  void _craftSelected() {
    if (_recipes.isEmpty || _selectedIndex >= _recipes.length) return;

    final recipe = _recipes[_selectedIndex];
    if (!recipe.canCraft) return;

    // Create the craft intent
    final station = widget.station;
    if (station != null) {
      widget.player.upsert(StationCraftIntent(
        stationEntityId: station.id,
        recipeTemplateId: recipe.recipeTemplateId,
      ));
    } else {
      widget.player.upsert(CraftIntent(recipeTemplateId: recipe.recipeTemplateId));
    }

    // Trigger a game tick to process the crafting
    widget.world.tick();

    // Refresh the recipe list
    _refreshRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: kSpacingL),
            Text(
              widget.station != null
                  ? 'No recipes for this station.'
                  : 'No recipes available.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: kSpacingS),
            Text(
              widget.station != null
                  ? 'This station has no compatible recipes.'
                  : 'Create recipe templates with empty required capabilities.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.translucent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel: Recipe list
            Expanded(
              flex: 2,
              child: _buildRecipeList(colorScheme),
            ),

            // Divider
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colorScheme.outlineVariant,
            ),

            // Right panel: Recipe details
            Expanded(
              flex: 3,
              child: _buildRecipeDetails(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingM),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        final isSelected = _focusNode.hasFocus && index == _selectedIndex;

        return _RecipeListItem(
          recipe: recipe,
          isSelected: isSelected,
          world: widget.world,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            _focusNode.requestFocus();
          },
        );
      },
    );
  }

  Widget _buildRecipeDetails(ColorScheme colorScheme) {
    if (_recipes.isEmpty) {
      return const SizedBox.shrink();
    }

    final recipe = _recipes[_selectedIndex.clamp(0, _recipes.length - 1)];
    final playerItems = widget.player.get<Inventory>()?.items ?? [];
    final stationItems = widget.station?.get<Inventory>()?.items ?? [];
    final inventory = [...playerItems, ...stationItems];
    final ingredients = RecipeService.getIngredientInfo(
      widget.world,
      recipe.recipe,
      inventory,
    );
    final outputs = RecipeService.getOutputInfo(widget.world, recipe.recipe);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe name
          Text(
            recipe.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingL),

          // Outputs section
          _SectionHeader(
            title: 'Produces',
            icon: Icons.arrow_forward,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: kSpacingM),
          ...outputs.map((output) => _OutputRow(
                output: output,
                world: widget.world,
              )),

          const SizedBox(height: kSpacingXL),

          // Ingredients section
          _SectionHeader(
            title: 'Requires',
            icon: Icons.inventory_2_outlined,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: kSpacingM),
          ...ingredients.map((ingredient) => _IngredientRow(
                ingredient: ingredient,
                world: widget.world,
              )),

          const SizedBox(height: kSpacingXL),

          // Crafting time
          _SectionHeader(
            title: 'Time',
            icon: Icons.timer_outlined,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: kSpacingM),
          Text(
            recipe.recipe.craftingTicks <= 1
                ? 'Instant'
                : '${recipe.recipe.craftingTicks} ticks',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: kSpacingXXL),

          // Craft button
          if (recipe.canCraft)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _craftSelected,
                icon: const Icon(Icons.build_outlined),
                label: const Text('Craft'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: kSpacingL),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kSpacingL),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(kRadiusM),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: kSpacingM),
                  Text(
                    'Missing ingredients',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: kSpacingM),

          // Keybinding hint
          Center(
            child: Text(
              _keybindings.getCombo('menu.select')?.toDisplayString() ?? 'E',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single recipe item in the list.
class _RecipeListItem extends StatelessWidget {
  final CraftableRecipe recipe;
  final bool isSelected;
  final World world;
  final VoidCallback onTap;

  const _RecipeListItem({
    required this.recipe,
    required this.isSelected,
    required this.world,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get icon from primary output
    String? iconPath;
    if (recipe.recipe.outputs.isNotEmpty) {
      final outputTemplate = world.getEntity(recipe.recipe.outputs.first.templateId);
      final renderable = outputTemplate.get<Renderable>();
      if (renderable != null && renderable.asset is ImageAsset) {
        iconPath = (renderable.asset as ImageAsset).svgAssetPath;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kRadiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingM,
          vertical: kSpacingM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
          borderRadius: BorderRadius.circular(kRadiusM),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 32,
              height: 32,
              child: iconPath != null
                  ? _buildAssetImage(iconPath)
                  : Icon(
                      Icons.construction_outlined,
                      size: 24,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
            ),
            const SizedBox(width: kSpacingM),

            // Name
            Expanded(
              child: Text(
                recipe.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Craftable indicator
            Icon(
              recipe.canCraft ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: recipe.canCraft ? colorScheme.primary : colorScheme.error.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetImage(String path) {
    final fullPath = 'assets/$path';
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.svg')) {
      return SvgPicture.asset(
        fullPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        fullPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme colorScheme;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: kSpacingS),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// A row showing an ingredient requirement.
class _IngredientRow extends StatelessWidget {
  final IngredientInfo ingredient;
  final World world;

  const _IngredientRow({
    required this.ingredient,
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get icon
    String? iconPath;
    final template = world.getEntity(ingredient.templateId);
    final renderable = template.get<Renderable>();
    if (renderable != null && renderable.asset is ImageAsset) {
      iconPath = (renderable.asset as ImageAsset).svgAssetPath;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingS),
      child: Row(
        children: [
          // Icon
          SizedBox(
            width: 24,
            height: 24,
            child: iconPath != null
                ? _buildAssetImage(iconPath)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: kSpacingM),

          // Name
          Expanded(
            child: Text(
              ingredient.name,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Quantity
          Text(
            '${ingredient.available}/${ingredient.required}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ingredient.isSatisfied
                  ? colorScheme.primary
                  : colorScheme.error,
            ),
          ),

          const SizedBox(width: kSpacingS),

          // Check/X icon
          Icon(
            ingredient.isSatisfied ? Icons.check : Icons.close,
            size: 16,
            color: ingredient.isSatisfied
                ? colorScheme.primary
                : colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImage(String path) {
    final fullPath = 'assets/$path';
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.svg')) {
      return SvgPicture.asset(
        fullPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        fullPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
  }
}

/// A row showing an output item.
class _OutputRow extends StatelessWidget {
  final OutputInfo output;
  final World world;

  const _OutputRow({
    required this.output,
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get icon
    String? iconPath;
    final template = world.getEntity(output.templateId);
    final renderable = template.get<Renderable>();
    if (renderable != null && renderable.asset is ImageAsset) {
      iconPath = (renderable.asset as ImageAsset).svgAssetPath;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingS),
      child: Row(
        children: [
          // Icon
          SizedBox(
            width: 24,
            height: 24,
            child: iconPath != null
                ? _buildAssetImage(iconPath)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: kSpacingM),

          // Name
          Expanded(
            child: Text(
              output.name,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Quantity
          if (output.quantity > 1)
            Text(
              'x${output.quantity}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssetImage(String path) {
    final fullPath = 'assets/$path';
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.svg')) {
      return SvgPicture.asset(
        fullPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        fullPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
  }
}
