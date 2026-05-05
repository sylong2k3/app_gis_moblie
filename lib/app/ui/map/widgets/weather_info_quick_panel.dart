import 'package:app_core/domain/entities/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/weather/weather_cubit.dart';

class WeatherQuickInfo extends StatelessWidget {
  final VoidCallback? onClose;
  final String? locationText;

  const WeatherQuickInfo({super.key, this.onClose, this.locationText});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(31),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _buildWeatherContent(state),
          ),
        );
      },
    );
  }

  Widget _buildWeatherContent(WeatherState state) {
    if (state is WeatherLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Đang tải...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      );
    }

    if (state is WeatherError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFF44336),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Lỗi tải thời tiết',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, size: 18, color: Colors.grey),
            ),
          ],
        ],
      );
    }

    if (state is WeatherLoaded) {
      return _buildLoadedWeather(state.weather);
    }

    // Default state
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3E0),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            color: Color(0xFFFF9800),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Chạm để xem thời tiết',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedWeather(Weather weather) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weather icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getWeatherIconBackground(weather.icon),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getWeatherIcon(weather.icon),
            color: _getWeatherIconColor(weather.icon),
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        // Temperature & location
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${weather.temperature.round()}°C',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  weather.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              weather.location.isNotEmpty
                  ? weather.location
                  : '${weather.latitude.toStringAsFixed(2)}, ${weather.longitude.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.black45,
              ),
            ),
          ],
        ),

        const SizedBox(width: 12),
        Column(
          children: [
            _WeatherStat(
              icon: Icons.air,
              value: '${weather.windSpeed.toStringAsFixed(1)}km/h',
            ),
            const SizedBox(width: 10),
            _WeatherStat(
              icon: Icons.water_drop_outlined,
              value: '${weather.humidity}%',
            ),
          ],
        ),

        const SizedBox(width: 12),

        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            onClose?.call();
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.close, size: 16, color: Colors.black45),
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': // clear sky day
      case '01n': // clear sky night
        return Icons.wb_sunny_rounded;
      case '02d': // few clouds day
      case '02n': // few clouds night
      case '03d': // scattered clouds day
      case '03n': // scattered clouds night
      case '04d': // broken clouds day
      case '04n': // broken clouds night
        return Icons.wb_cloudy_rounded;
      case '09d': // shower rain day
      case '09n': // shower rain night
      case '10d': // rain day
      case '10n': // rain night
        return Icons.grain_rounded;
      case '11d': // thunderstorm day
      case '11n': // thunderstorm night
        return Icons.flash_on_rounded;
      case '13d': // snow day
      case '13n': // snow night
        return Icons.ac_unit_rounded;
      case '50d': // mist day
      case '50n': // mist night
        return Icons.blur_on_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _getWeatherIconColor(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return const Color(0xFFFF9800);
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return const Color(0xFF9E9E9E);
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return const Color(0xFF2196F3);
      case '11d':
      case '11n':
        return const Color(0xFF9C27B0);
      case '13d':
      case '13n':
        return const Color(0xFF03DAC6);
      case '50d':
      case '50n':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFFFF9800);
    }
  }

  Color _getWeatherIconBackground(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return const Color(0xFFFFF3E0);
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return const Color(0xFFF5F5F5);
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return const Color(0xFFE3F2FD);
      case '11d':
      case '11n':
        return const Color(0xFFF3E5F5);
      case '13d':
      case '13n':
        return const Color(0xFFE0F2F1);
      case '50d':
      case '50n':
        return const Color(0xFFECEFF1);
      default:
        return const Color(0xFFFFF3E0);
    }
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _WeatherStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
