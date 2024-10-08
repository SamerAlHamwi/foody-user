import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';

import '../theme/app_style.dart';

class CustomNetworkImage extends StatelessWidget {
  final String url;
  final double height;
  final double width;
  final double radius;
  final Color bgColor;
  final bool isWithBorder;

  const CustomNetworkImage({
    super.key,
    required this.url,
    required this.height,
    required this.width,
    required this.radius,
    this.isWithBorder = false,
    this.bgColor = Style.mainBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AppHelpers.checkIsSvg(url)
          ? SvgPicture.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Style.shimmerBase,
                ),
              ),
            )
          : Container(
            height: height,
            width: width,
            decoration: isWithBorder ? BoxDecoration(
              border: Border.all(
                color: Style.yourChatBack,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(radius),
            ) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedNetworkImage(
                  height: height,
                  width: width,
                  imageUrl: url,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                        color: Style.shimmerBase,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        color: bgColor,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        FlutterRemix.image_line,
                        color: Style.shimmerBaseDark,
                      ),
                    );
                  },
                ),
            ),
          ),
    );
  }
}
