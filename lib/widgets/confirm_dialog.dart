import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum ConfirmActionType { edit, delete }

Future<bool> showStudentConfirmDialog(
  BuildContext context, {
  required ConfirmActionType type,
}) async {
  final l10n = AppLocalizations.of(context);
  final isDelete = type == ConfirmActionType.delete;

  final title = isDelete ? l10n.confirmDeleteTitle : l10n.confirmEditTitle;
  final message = isDelete ? l10n.confirmDeleteMessage : l10n.confirmEditMessage;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDelete
                    ? theme.colorScheme.error.withAlpha(30)
                    : theme.colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDelete ? Icons.delete_outline_rounded : Icons.edit_note_rounded,
                color: isDelete ? theme.colorScheme.error : theme.colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyMedium?.color?.withAlpha(220),
            height: 1.4,
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.withAlpha(100)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.no, // "Không"
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDelete
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.yes, // "Có"
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
