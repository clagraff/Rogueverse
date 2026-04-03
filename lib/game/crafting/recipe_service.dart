import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';

/// Represents an ingredient that is missing or insufficient.
class MissingIngredient {
  final int templateId;
  final String name;
  final int required;
  final int available;

  MissingIngredient({
    required this.templateId,
    required this.name,
    required this.required,
    required this.available,
  });
}

/// Represents a recipe with its craftability status.
class CraftableRecipe {
  final int recipeTemplateId;
  final String name;
  final Recipe recipe;
  final bool canCraft;
  final List<MissingIngredient> missing;

  CraftableRecipe({
    required this.recipeTemplateId,
    required this.name,
    required this.recipe,
    required this.canCraft,
    required this.missing,
  });
}

/// Service for discovering and checking recipe requirements.
class RecipeService {
  /// Find all direct-craftable recipes (empty requiredCapabilities).
  static List<CraftableRecipe> getDirectRecipes(World world, Entity player) {
    final inventory = player.get<Inventory>()?.items ?? [];
    return _getRecipes(
      world,
      inventory,
      (recipe) => recipe.requiredCapabilities.isEmpty,
    );
  }

  /// Find all recipes a station can craft (based on capabilities).
  ///
  /// When [crafter] is provided, combines the crafter's inventory with the
  /// station's inventory (crafter items first) for availability checks.
  static List<CraftableRecipe> getStationRecipes(
    World world,
    Entity station, {
    Entity? crafter,
  }) {
    final capabilities = station.get<CraftingStation>()?.capabilities ?? {};
    final stationItems = station.get<Inventory>()?.items ?? [];
    final crafterItems = crafter?.get<Inventory>()?.items ?? [];
    final inventory = [...crafterItems, ...stationItems];
    return _getRecipes(
      world,
      inventory,
      (recipe) =>
          recipe.requiredCapabilities.isNotEmpty &&
          capabilities.containsAll(recipe.requiredCapabilities),
    );
  }

  /// Find all recipes that produce a specific item.
  static List<int> getRecipesProducing(World world, int itemTemplateId) {
    final results = <int>[];

    for (final entity in world.entities()) {
      if (!entity.has<IsTemplate>()) continue;
      final recipe = entity.get<Recipe>();
      if (recipe == null) continue;

      for (final output in recipe.outputs) {
        if (output.templateId == itemTemplateId) {
          results.add(entity.id);
          break;
        }
      }
    }

    return results;
  }

  static List<CraftableRecipe> _getRecipes(
    World world,
    List<int> inventoryItems,
    bool Function(Recipe) filter,
  ) {
    final results = <CraftableRecipe>[];

    for (final entity in world.entities()) {
      if (!entity.has<IsTemplate>()) continue;
      final recipe = entity.get<Recipe>();
      if (recipe == null || !filter(recipe)) continue;

      final name = entity.get<Name>()?.name ?? 'Unknown Recipe';
      final missing = <MissingIngredient>[];

      for (final ingredient in recipe.inputs) {
        final available =
            _countIngredient(world, inventoryItems, ingredient.templateId);
        if (available < ingredient.quantity) {
          final ingredientEntity = world.getEntity(ingredient.templateId);
          final ingredientName =
              ingredientEntity.get<Name>()?.name ?? 'Unknown';
          missing.add(MissingIngredient(
            templateId: ingredient.templateId,
            name: ingredientName,
            required: ingredient.quantity,
            available: available,
          ));
        }
      }

      results.add(CraftableRecipe(
        recipeTemplateId: entity.id,
        name: name,
        recipe: recipe,
        canCraft: missing.isEmpty,
        missing: missing,
      ));
    }

    // Sort: craftable first, then alphabetically
    results.sort((a, b) {
      if (a.canCraft != b.canCraft) {
        return a.canCraft ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });

    return results;
  }

  /// Count how many items match template (including inheritance).
  static int _countIngredient(
      World world, List<int> items, int templateId) {
    var count = 0;
    for (final itemId in items) {
      final item = world.getEntity(itemId);
      if (_matchesTemplate(world, item, templateId)) {
        count++;
      }
    }
    return count;
  }

  /// Check if item matches required template (traverses FromTemplate chain).
  static bool _matchesTemplate(World world, Entity item, int templateId) {
    var fromTemplate = item.get<FromTemplate>();
    while (fromTemplate != null) {
      if (fromTemplate.templateEntityId == templateId) return true;
      final parent = world.getEntity(fromTemplate.templateEntityId);
      fromTemplate = parent.get<FromTemplate>();
    }
    return false;
  }

  /// Get the display name for a recipe (from the recipe's Name component or
  /// the primary output's name).
  static String getRecipeDisplayName(World world, Entity recipeTemplate) {
    // Try the recipe's own name first
    final recipeName = recipeTemplate.get<Name>()?.name;
    if (recipeName != null && recipeName.isNotEmpty) {
      return recipeName;
    }

    // Fall back to primary output name
    final recipe = recipeTemplate.get<Recipe>();
    if (recipe != null && recipe.outputs.isNotEmpty) {
      final primaryOutput = world.getEntity(recipe.outputs.first.templateId);
      final outputName = primaryOutput.get<Name>()?.name;
      if (outputName != null) {
        return 'Craft $outputName';
      }
    }

    return 'Unknown Recipe';
  }

  /// Get ingredient info for display (includes available count).
  static List<IngredientInfo> getIngredientInfo(
    World world,
    Recipe recipe,
    List<int> inventoryItems,
  ) {
    return recipe.inputs.map((ingredient) {
      final ingredientEntity = world.getEntity(ingredient.templateId);
      final name = ingredientEntity.get<Name>()?.name ?? 'Unknown';
      final available = _countIngredient(world, inventoryItems, ingredient.templateId);
      return IngredientInfo(
        templateId: ingredient.templateId,
        name: name,
        required: ingredient.quantity,
        available: available,
        isSatisfied: available >= ingredient.quantity,
      );
    }).toList();
  }

  /// Get output info for display.
  static List<OutputInfo> getOutputInfo(World world, Recipe recipe) {
    return recipe.outputs.map((output) {
      final outputEntity = world.getEntity(output.templateId);
      final name = outputEntity.get<Name>()?.name ?? 'Unknown';
      return OutputInfo(
        templateId: output.templateId,
        name: name,
        quantity: output.quantity,
      );
    }).toList();
  }
}

/// Information about a recipe ingredient for display.
class IngredientInfo {
  final int templateId;
  final String name;
  final int required;
  final int available;
  final bool isSatisfied;

  IngredientInfo({
    required this.templateId,
    required this.name,
    required this.required,
    required this.available,
    required this.isSatisfied,
  });
}

/// Information about a recipe output for display.
class OutputInfo {
  final int templateId;
  final String name;
  final int quantity;

  OutputInfo({
    required this.templateId,
    required this.name,
    required this.quantity,
  });
}
