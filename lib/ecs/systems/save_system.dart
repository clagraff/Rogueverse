import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/persistence.dart';

part 'save_system.mapper.dart';

/// System that periodically saves the world state.
///
/// Saves every [saveIntervalTicks] ticks to avoid saving too frequently
/// with periodic game ticks. Runs last (priority 200) to ensure all
/// other systems have processed before saving.
@MappableClass()
class SaveSystem extends System with SaveSystemMappable {
  static final _logger = Logger('SaveSystem');

  /// Number of ticks between saves. With 600ms ticks, 10 = ~6 seconds.
  static const int saveIntervalTicks = 10;

  @override
  int get priority => 200; // Run after all other systems

  @override
  void update(World world) {
    if (world.tickId % saveIntervalTicks == 0) {
      _logger.fine("periodic save triggered", {"tickId": world.tickId});
      Persistence.writeSavePatch(world);
    }
  }
}
