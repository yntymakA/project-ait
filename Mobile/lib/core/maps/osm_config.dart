import 'package:latlong2/latlong.dart';

/// OpenStreetMap raster tiles + sensible defaults.
/// See https://operations.osmfoundation.org/policies/tiles/ — use a descriptive User-Agent via [tileUserAgentPackageName].
class OsmConfig {
  OsmConfig._();

  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Identifies the app when requesting tiles (OSM policy).
  static const String tileUserAgentPackageName = 'com.marketplace.app';

  static const String attribution = '© OpenStreetMap contributors';

  /// Default map center when no pin exists yet (Bishkek area — adjust if needed).
  static final LatLng defaultCenter = LatLng(42.8746, 74.5698);

  static const double defaultZoomPicker = 14;
  static const double defaultZoomPreview = 15;
}
