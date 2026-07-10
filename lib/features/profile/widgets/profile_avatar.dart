import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.size = 96,
    this.showCameraButton = false,
    this.image,
    this.onCameraPressed,
  });

  final double size;
  final bool showCameraButton;
  final ImageProvider? image;
  final VoidCallback? onCameraPressed;

  @override
  Widget build(BuildContext context) {
    final cameraSize = size * 0.34;

    return SizedBox(
      width: showCameraButton ? size + cameraSize * 0.46 : size,
      height: showCameraButton ? size + cameraSize * 0.12 : size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            key: const ValueKey('profile-avatar'),
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image(
              image:
                  image ?? const AssetImage('assets/images/profile-avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
          if (showCameraButton)
            Positioned(
              right: 0,
              bottom: size * 0.05,
              child: InkResponse(
                key: const ValueKey('profile-camera-button'),
                onTap: onCameraPressed,
                radius: cameraSize / 2,
                child: Container(
                  width: cameraSize,
                  height: cameraSize,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.camera,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
