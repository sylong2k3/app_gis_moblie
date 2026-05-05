import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/app/ui/map/widgets/feature_info_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureSelectedPanel extends StatelessWidget {
  const FeatureSelectedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        if (state is MapFeatureSelected) {
          return Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom,
            child: FeatureInfoPanel(
              feature: state.feature,
              onClose: () {
                context.read<MapCubit>().clearSelection();
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
