import 'dart:io';
import 'package:flutter/material.dart';

class StudentAvatar extends StatelessWidget {
  final String avatar;
  final String name;
  final double radius;
  final bool enableHero;
  final String? heroTag;
  final VoidCallback? onTap;

  const StudentAvatar({
    super.key,
    required this.avatar,
    required this.name,
    this.radius = 28,
    this.enableHero = false,
    this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget = _buildAvatarContent(context);

    if (enableHero && heroTag != null) {
      avatarWidget = Hero(
        tag: heroTag!,
        child: avatarWidget,
      );
    }

    if (onTap != null) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildAvatarContent(BuildContext context) {
    final theme = Theme.of(context);
    final size = radius * 2;

    Widget imageContent;

    final trimmedAvatar = avatar.trim();

    if (trimmedAvatar.startsWith('http://') || trimmedAvatar.startsWith('https://')) {
      imageContent = Image.network(
        trimmedAvatar,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: theme.colorScheme.primary.withAlpha(25),
            child: Center(
              child: SizedBox(
                width: radius * 0.8,
                height: radius * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            ),
          );
        },
      );
    } else if (trimmedAvatar.isNotEmpty && File(trimmedAvatar).existsSync()) {
      imageContent = Image.file(
        File(trimmedAvatar),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else {
      imageContent = _buildFallback(context);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: imageContent),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final initials = _getInitials(name);
    final size = radius * 2;

    // Gradient màu sắc hài hòa dựa trên tên
    final colorPair = _getColorForName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorPair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  String _getInitials(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return 'SV';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  List<Color> _getColorForName(String input) {
    final colorsList = [
      [const Color(0xFF4F46E5), const Color(0xFF7C3AED)], // Indigo to Violet
      [const Color(0xFF0284C7), const Color(0xFF2563EB)], // Sky to Blue
      [const Color(0xFF0D9488), const Color(0xFF059669)], // Teal to Emerald
      [const Color(0xFFE11D48), const Color(0xFFD946EF)], // Rose to Fuchsia
      [const Color(0xFFEA580C), const Color(0xFFF59E0B)], // Orange to Amber
    ];
    final hash = input.codeUnits.fold(0, (acc, c) => acc + c);
    return colorsList[hash % colorsList.length];
  }
}
