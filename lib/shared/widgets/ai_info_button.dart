import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class AiInfoButton extends StatelessWidget {
  const AiInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.auto_awesome),
      onPressed: () {
        final loc = AppLocalizations.of(context);
        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Icon(Icons.auto_awesome, size: 36, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  loc.translate('ai_placeholder'),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
