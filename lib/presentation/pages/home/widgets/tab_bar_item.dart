import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:riverpodtemp/presentation/components/custom_network_image.dart';
import 'package:riverpodtemp/presentation/theme/theme.dart';

class CategoryBarItem extends StatelessWidget {
  final String image;
  final String title;
  final int index;
  final VoidCallback onTap;
  final bool isActive;

  const CategoryBarItem(
      {super.key,
      required this.image,
      required this.title,
      required this.index,
      this.isActive = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h,left: 4.w,right: 4.w),
        width: 1.sw/4.8,
        height: 1.sw/4.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
            color: isActive ? Style.brandGreen : null),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomNetworkImage(
                    url: image,
                    height: 1.sw/4.8,
                    width: 1.sw/4.8,
                    radius: 8.r,
                  ),
                  Container(
                    height: 1.sw/4.8,
                    width: 1.sw/4.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        color: Style.black.withOpacity(0.3)),
                  ),
                  Text(
                    title,
                    style: Style.interNormal(
                      size: 13,
                      color: Style.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
