import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import 'package:tayssir/environment_config.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final BoxFit? fit;
  final bool isGrayscale;
  final Widget? errorWidget;
  final double? borderRadius;
  final Clip clipBehavior;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.margin,
    this.fit,
    this.isGrayscale = false,
    this.errorWidget,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final String safeUrl = EnvironmentConfig.resolveImageUrl(imageUrl);
    
    if (safeUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (kIsWeb) {
      String getObjectFit() {
        switch (fit) {
          case BoxFit.cover: return 'cover';
          case BoxFit.contain: return 'contain';
          case BoxFit.fill: return 'fill';
          case BoxFit.fitWidth: return 'cover';
          case BoxFit.fitHeight: return 'cover';
          default: return 'contain';
        }
      }
      return Container(
        height: height,
        width: width,
        margin: margin,
        clipBehavior: clipBehavior,
        decoration: BoxDecoration(
          borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        ),
        child: HtmlElementView.fromTagName(
          tagName: 'img',
          onElementCreated: (Object element) {
            final dynamic img = element;
            img.src = safeUrl;
            img.style.objectFit = getObjectFit();
            img.style.width = '100%';
            img.style.height = '100%';
            if (borderRadius != null) {
              img.style.borderRadius = '${borderRadius}px';
            }
            if (isGrayscale) {
              img.style.filter = 'grayscale(100%)';
            }
          },
        ),
      );
    }

    Widget image = CachedNetworkImage(
      imageUrl: safeUrl,
      fit: fit,
      color: isGrayscale ? Colors.grey : null,
      colorBlendMode: isGrayscale ? BlendMode.saturation : null,
      placeholder: (context, url) => shimmer.Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.2),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Container(
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        clipBehavior: clipBehavior,
        child: image,
      );
    }

    return Container(
      height: height,
      width: width,
      margin: margin,
      child: image,
    );
  }
}
