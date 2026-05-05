import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/app/bloc/location/location_cubit.dart';

class LocationPermissionBanner extends StatelessWidget {
  const LocationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationPermissionDenied) {
          return Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.orange[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Cần quyền truy cập vị trí')),
                    TextButton(
                      onPressed: () {
                        context.read<LocationCubit>().requestPermission();
                      },
                      child: const Text('Cho phép'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
