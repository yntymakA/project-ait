import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'osm_config.dart';

/// Tappable OSM map: tap to place one pin. Optional initial [latitude]/[longitude].
class ListingLocationPicker extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final ValueChanged<LatLng> onLocationChanged;
  final double height;

  const ListingLocationPicker({
    super.key,
    this.latitude,
    this.longitude,
    required this.onLocationChanged,
    this.height = 220,
  });

  @override
  State<ListingLocationPicker> createState() => _ListingLocationPickerState();
}

class _ListingLocationPickerState extends State<ListingLocationPicker> {
  late final MapController _controller = MapController();
  LatLng? _pin;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null &&
        widget.longitude != null &&
        widget.latitude!.isFinite &&
        widget.longitude!.isFinite) {
      _pin = LatLng(widget.latitude!, widget.longitude!);
    }
  }

  @override
  void didUpdateWidget(ListingLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude == null || widget.longitude == null) {
      if (_pin != null) {
        setState(() => _pin = null);
      }
    } else if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      setState(() {
        _pin = LatLng(widget.latitude!, widget.longitude!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(TapPosition _, LatLng point) {
    setState(() => _pin = point);
    widget.onLocationChanged(point);
  }

  @override
  Widget build(BuildContext context) {
    final center = _pin ?? OsmConfig.defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: center,
                initialZoom: OsmConfig.defaultZoomPicker,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: OsmConfig.tileUrlTemplate,
                  userAgentPackageName: OsmConfig.tileUserAgentPackageName,
                ),
                if (_pin != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pin!,
                        width: 44,
                        height: 44,
                        alignment: Alignment.bottomCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFE53935),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              left: 8,
              top: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'Tap to place pin',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    OsmConfig.attribution,
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
