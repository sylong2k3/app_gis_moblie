import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/app/ui/map/base_map_item.dart';
import 'package:app_core/app/ui/map/layer_toggle_item.dart';
import 'package:app_core/app/ui/map/section_title.dart';
import 'package:app_core/app/ui/map/sheet_header.dart';
import 'package:app_core/shared/constants/mapbox_constants.dart';
import 'package:app_core/shared/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapStyleSelectorSheet extends StatefulWidget {
  final String currentStyle;
  final ValueChanged<String> onSelectStyle;

  const MapStyleSelectorSheet({
    super.key,
    required this.currentStyle,
    required this.onSelectStyle,
  });

  @override
  State<MapStyleSelectorSheet> createState() => _MapStyleSelectorSheetState();
}

class _MapStyleSelectorSheetState extends State<MapStyleSelectorSheet> {
  @override
  void initState() {
    super.initState();
    // Load layers when sheet opens
    context.read<MapCubit>().loadLayers();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cachedLayers = context.select((MapCubit cubit) => cubit.layersCache);

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SheetHeader(onClose: () => Navigator.pop(context)),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('BẢN ĐỒ NỀN'),
                  const SizedBox(height: 12),
                  // Row 1
                  Row(
                    children: [
                      BaseMapItem(
                        title: 'Vệ tinh',
                        selected:
                            widget.currentStyle ==
                            MapboxConstants.styleSatellite,
                        onTap: () {
                          widget.onSelectStyle(MapboxConstants.styleSatellite);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 12),
                      BaseMapItem(
                        title: 'Hỗn hợp',
                        selected:
                            widget.currentStyle ==
                            MapboxConstants.styleSatelliteStreets,
                        onTap: () {
                          widget.onSelectStyle(
                            MapboxConstants.styleSatelliteStreets,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2
                  Row(
                    children: [
                      BaseMapItem(
                        title: 'Ngoài trời',
                        selected:
                            widget.currentStyle ==
                            MapboxConstants.styleOutdoors,
                        onTap: () {
                          widget.onSelectStyle(MapboxConstants.styleOutdoors);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 12),
                      BaseMapItem(
                        title: 'Đường phố',
                        selected:
                            widget.currentStyle == MapboxConstants.styleStreet,
                        onTap: () {
                          widget.onSelectStyle(MapboxConstants.styleStreet);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionTitle('LỚP DỮ LIỆU'),
                  const SizedBox(height: 12),

                  BlocBuilder<MapCubit, MapState>(
                    builder: (context, state) {
                      if (state is MapLoading && cachedLayers.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: LoadingIndicator(),
                          ),
                        );
                      }

                      if (state is MapError && cachedLayers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (cachedLayers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Không có lớp dữ liệu',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final activeLayers = cachedLayers
                          .where((layer) => layer.isActive)
                          .toList();

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: activeLayers.map((layer) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: LayerToggleItem(
                              title: layer.name,
                              enabled: layer.isVisible,
                              onChanged: (value) {
                                final mapCubit = context.read<MapCubit>();

                                mapCubit.toggleLayer(layer.id.toString());

                                if (value) {
                                  mapCubit.loadLayerFeatures(layer.id);
                                } else {
                                  mapCubit.clearLayerFeatures(layer.id);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
