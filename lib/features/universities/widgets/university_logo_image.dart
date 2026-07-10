import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../repositories/university_cache_store.dart';

final BaseCacheManager universityLogoCacheManager = CacheManager(
  Config(
    'nqaaeUniversityLogosV1',
    stalePeriod: universityCacheTtl,
    maxNrOfCacheObjects: 300,
  ),
);

class UniversityLogoImage extends StatelessWidget {
  const UniversityLogoImage({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  final String imageUrl;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: universityLogoCacheManager,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
