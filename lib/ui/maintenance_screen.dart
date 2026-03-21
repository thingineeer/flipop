import 'package:flutter/material.dart';
import '../game/game_colors.dart';
import '../l10n/app_localizations.dart';

/// 서버 점검 중 화면
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: GameColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔧',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.infraMaintenance,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GameColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.infraMaintenanceDesc,
                style: const TextStyle(
                  fontSize: 16,
                  color: GameColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
