import '../overlay_pack.dart';
import 'basic_landscape.dart';
import 'basic_portrait.dart';

/// "Basic" overlay pack — the default broadcast overlay.
/// Portrait = minimal one-line strip. Landscape = full scoreboard.
final OverlayPack basicOverlayPack = OverlayPack(
  id: 'basic',
  name: 'Basic',
  portraitBuilder: ({key, required bootstrap, required tick, required effects}) =>
      BasicPortrait(key: key, bootstrap: bootstrap, tick: tick, effects: effects),
  landscapeBuilder: ({key, required bootstrap, required tick, required effects}) =>
      BasicLandscape(key: key, bootstrap: bootstrap, tick: tick, effects: effects),
);
