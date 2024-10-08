import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:riverpodtemp/application/shop/shop_provider.dart';
import 'package:riverpodtemp/application/shop_order/shop_order_provider.dart';
import 'package:riverpodtemp/infrastructure/models/data/shop_data.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/local_storage.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/components/buttons/animation_button_effect.dart';
import 'package:riverpodtemp/presentation/components/buttons/custom_button.dart';
import 'package:riverpodtemp/presentation/components/custom_network_image.dart';
import 'package:riverpodtemp/presentation/components/shop_avarat.dart';
import 'package:riverpodtemp/presentation/pages/shop/group_order/group_order.dart';
import 'package:riverpodtemp/presentation/routes/app_router.dart';
import 'package:riverpodtemp/presentation/theme/theme.dart';

import '../../../../infrastructure/models/data/bonus_data.dart';
import '../../../components/bonus_discount_popular.dart';
import 'bonus_screen.dart';
import 'shop_description_item.dart';
import 'package:intl/intl.dart' as intl;

class ShopPageAvatar extends StatefulWidget {
  final ShopData shop;
  final String workTime;
  final bool isLike;
  final VoidCallback onShare;
  final VoidCallback onLike;
  final VoidCallback onChange;
  final BonusModel? bonus;

  const ShopPageAvatar(
      {super.key,
      required this.shop,
      required this.onLike,
      required this.workTime,
      required this.isLike,
      required this.onShare,
      required this.bonus,
      required this.onChange
      });

  @override
  State<ShopPageAvatar> createState() => _ShopPageAvatarState();
}

class _ShopPageAvatarState extends State<ShopPageAvatar> {
  int selectedIndex = 0;

  List<String> labels = [
    'Products', 'Shop info',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        shopAppBar(context),
        8.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.shop.translation?.title ?? "",
                style: Style.interSemi(
                  size: 22,
                  color: Style.black,
                ),
              ),
              Text(
                widget.shop.translation?.description ?? "",
                style: Style.interNormal(
                  size: 13,
                  color: Style.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              6.verticalSpace,
              Row(
                children: [
                  SvgPicture.asset("assets/svgs/star.svg"),
                  4.horizontalSpace,
                  Text(
                    (widget.shop.avgRate ?? ""),
                    style: Style.interNormal(
                      size: 12.sp,
                      color: Style.black,
                    ),
                  ),
                  8.horizontalSpace,
                  BonusDiscountPopular(
                    isSingleShop: true,
                    isPopular: widget.shop.isRecommend ?? false,
                    bonus: widget.shop.bonus,
                    isDiscount: widget.shop.isDiscount ?? false,
                  ),
                ],
              ),
              10.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShopDescriptionItem(
                    title: AppHelpers.getTranslation(TrKeys.workingHours),
                    description: widget.workTime,
                    icon: const Icon(FlutterRemix.time_fill),
                  ),
                  ShopDescriptionItem(
                    title: AppHelpers.getTranslation(TrKeys.deliveryTime),
                    description:
                        "${widget.shop.deliveryTime?.from ?? 0} - ${widget.shop.deliveryTime?.to ?? 0} ${widget.shop.deliveryTime?.type ?? "min"}",
                    icon: SvgPicture.asset("assets/svgs/delivery.svg"),
                  ),
                  ShopDescriptionItem(
                    title: AppHelpers.getTranslation(TrKeys.deliveryPrice),
                    description:
                        "${AppHelpers.getTranslation(TrKeys.from)} ${intl.NumberFormat.currency(
                      symbol:
                          LocalStorage.instance.getSelectedCurrency().symbol,
                    ).format(widget.shop.deliveryRange ?? 0)}",
                    icon: SvgPicture.asset(
                      "assets/svgs/ticket.svg",
                      width: 18.r,
                      height: 18.r,
                    ),
                  ),
                ],
              ),
              AppHelpers.getTranslation(TrKeys.close) == widget.workTime
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        decoration: BoxDecoration(
                            color: Style.bgGrey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r))),
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            const Icon(
                              FlutterRemix.time_fill,
                              color: Style.black,
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                AppHelpers.getTranslation(
                                    TrKeys.notWorkTodayTime),
                                style: Style.interNormal(
                                  size: 14,
                                  color: Style.black,
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              widget.bonus != null ? _bonusButton(context) : const SizedBox.shrink(),
              12.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 35,
                    child: FlutterToggleTab(
                      width: 80.w,
                      borderRadius: 30,
                      height: 40,
                      selectedIndex: selectedIndex,
                      selectedBackgroundColors: const [Style.brandGreen],
                      unSelectedBackgroundColors: const [Style.textGrey],
                      selectedTextStyle: Style.interNormal().copyWith(
                        color: Style.white,
                      ),
                      unSelectedTextStyle: Style.interNormal().copyWith(
                        color: Style.white,
                      ),
                      labels: labels,
                      selectedLabelIndex: (index) async {
                        setState(() {
                          selectedIndex = index;
                        });
                        widget.onChange();
                      },
                      isScroll:false,
                    ),
                  ),
                ],
              ),
              12.verticalSpace,
              // groupOrderButton(context),
            ],
          ),
        )
      ],
    );
  }

  checkOtherShop(BuildContext context) {
    AppHelpers.showAlertDialog(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppHelpers.getTranslation(TrKeys.allPreviouslyAdded),
              style: Style.interNormal(),
              textAlign: TextAlign.center,
            ),
            16.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                      title: AppHelpers.getTranslation(TrKeys.cancel),
                      background: Style.transparent,
                      borderColor: Style.borderColor,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                10.horizontalSpace,
                Expanded(child: Consumer(builder: (contextTwo, ref, child) {
                  return CustomButton(
                      isLoading: ref.watch(shopOrderProvider).isDeleteLoading,
                      title: AppHelpers.getTranslation(TrKeys.continueText),
                      onPressed: () {
                        ref
                            .read(shopOrderProvider.notifier)
                            .deleteCart(context)
                            .then((value) async {
                          ref.read(shopOrderProvider.notifier).createCart(
                                context,
                                (widget.shop.id ?? 0),
                              );
                        });
                      });
                })),
              ],
            )
          ],
        ));
  }

  Widget groupOrderButton(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      ref.listen(shopOrderProvider, (previous, next) {
        if (next.isOtherShop && next.isOtherShop != previous?.isOtherShop) {
          checkOtherShop(context);
        }
        if (next.isStartGroup && next.isStartGroup != previous?.isStartGroup) {
          AppHelpers.showCustomModalBottomSheet(
            paddingTop: MediaQuery.of(context).padding.top + 160.h,
            context: context,
            modal: const GroupOrderScreen(),
            isDarkMode: false,
            isDrag: true,
            radius: 12,
          );
        }
      });
      bool isStartOrder = (ref.watch(shopOrderProvider).cart?.group ?? false) &&
          (ref.watch(shopOrderProvider).cart?.shopId == widget.shop.id);
      return CustomButton(
        isLoading: ref.watch(shopOrderProvider).isStartGroupLoading ||
            ref.watch(shopOrderProvider).isCheckShopOrder,
        icon: Icon(
          isStartOrder
              ? FlutterRemix.list_settings_line
              : FlutterRemix.group_2_line,
          color: isStartOrder ? Style.black : Style.white,
        ),
        title: isStartOrder
            ? AppHelpers.getTranslation(TrKeys.manageOrder)
            : AppHelpers.getTranslation(TrKeys.startGroupOrder),
        background: isStartOrder ? Style.brandGreen : Style.orderButtonColor,
        textColor: isStartOrder ? Style.black : Style.white,
        radius: 10,
        onPressed: () {
          if (LocalStorage.instance.getToken().isNotEmpty) {
            !isStartOrder
                ? ref.read(shopOrderProvider.notifier).createCart(
                      context,
                      widget.shop.id ?? 0,
                    )
                : AppHelpers.showCustomModalBottomSheet(
                    paddingTop: MediaQuery.of(context).padding.top + 160.h,
                    context: context,
                    modal: const GroupOrderScreen(),
                    isDarkMode: false,
                    isDrag: true,
                    radius: 12,
                  );
          } else {
            context.pushRoute(const LoginRoute());
          }
        },
      );
    });
  }

  Stack shopAppBar(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180.h + MediaQuery.of(context).padding.top,
          width: double.infinity,
          color: Style.mainBack,
          child: CustomNetworkImage(
            url: widget.shop.backgroundImg ?? "",
            height: 180.h + MediaQuery.of(context).padding.top,
            width: double.infinity,
            radius: 0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 130.h + MediaQuery.of(context).padding.top,
              left: 16.w,
              right: 16.w),
          child: ShopAvatar(
            radius: 20,
            shopImage: widget.shop.logoImg ?? "",
            size: 70,
            padding: 6,
            bgColor: Style.white.withOpacity(0.65),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top,
          right: 16.w,
          child: Row(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return GestureDetector(
                    onTap: () {
                      context.pushRoute(AllGalleriesRoute(
                          galleriesModel: ref.watch(shopProvider).galleries));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.r, horizontal: 12.r),
                          color:
                              Style.unselectedBottomBarItem.withOpacity(0.29),
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/svgs/menuS.svg"),
                              6.horizontalSpace,
                              Text(AppHelpers.getTranslation(
                                  TrKeys.seeAllPhotos))
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  AnimationButtonEffect _bonusButton(BuildContext context) {
    return AnimationButtonEffect(
      child: GestureDetector(
          onTap: () {
            AppHelpers.showCustomModalBottomSheet(
              paddingTop: MediaQuery.of(context).padding.top,
              context: context,
              modal: BonusScreen(
                bonus: widget.bonus,
              ),
              isDarkMode: false,
              isDrag: true,
              radius: 12,
            );
          },
          child: Container(
            margin: EdgeInsets.only(top: 8.h),
            width: MediaQuery.of(context).size.width - 32,
            decoration: BoxDecoration(
                color: Style.bgGrey,
                borderRadius: BorderRadius.all(Radius.circular(10.r))),
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Style.blueBonus),
                  child: Icon(
                    FlutterRemix.gift_2_fill,
                    size: 16.r,
                    color: Style.white,
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    widget.bonus != null
                        ? ((widget.bonus?.type ?? "sum") == "sum")
                            ? "${AppHelpers.getTranslation(TrKeys.under)} ${intl.NumberFormat.currency(
                                symbol: LocalStorage.instance
                                    .getSelectedCurrency()
                                    .symbol,
                              ).format(widget.bonus?.value ?? 0)} + ${widget.bonus?.bonusStock?.product?.translation?.title ?? ""}"
                            : "${AppHelpers.getTranslation(TrKeys.under)} ${widget.bonus?.value ?? 0} + ${widget.bonus?.bonusStock?.product?.translation?.title ?? ""}"
                        : "",
                    style: Style.interNormal(
                      size: 14,
                      color: Style.black,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
