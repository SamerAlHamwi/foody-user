// ignore_for_file: unused_result

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:riverpodtemp/application/shop/shop_notifier.dart';
import 'package:riverpodtemp/infrastructure/models/data/shop_data.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/components/buttons/pop_button.dart';
import 'package:riverpodtemp/presentation/components/loading.dart';
import 'package:riverpodtemp/application/like/like_notifier.dart';
import 'package:riverpodtemp/application/like/like_provider.dart';
import 'package:riverpodtemp/presentation/pages/product/product_page.dart';
import 'package:riverpodtemp/presentation/pages/shop/shop_products_screen.dart';
import 'package:riverpodtemp/presentation/theme/theme.dart';

import '../../../../application/shop/shop_provider.dart';
import '../../../application/main/main_provider.dart';
import '../../../application/shop_order/shop_order_provider.dart';
import '../../../infrastructure/services/local_storage.dart';

import '../../components/buttons/animation_button_effect.dart';
import '../single_shop/widgets/info_screen.dart';
import '../single_shop/widgets/order_food.dart';
import '../single_shop/widgets/review_screen.dart';
import 'cart/cart_order_page.dart';
import 'package:intl/intl.dart' as intl;
import 'widgets/shop_page_avatar.dart';

@RoutePage()
class ShopPage extends ConsumerStatefulWidget {
  final ShopData? shop;
  final int shopId;
  final String? productId;

  const ShopPage({
    super.key,
    required this.shopId,
    this.productId,
    this.shop,
  });

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage>
    with TickerProviderStateMixin {
  late ShopNotifier event;
  late LikeNotifier eventLike;
  bool isProducts = true;


  @override
  void initState() {
    super.initState();
    ref.refresh(shopProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.shop == null) {
        ref.read(shopProvider.notifier).fetchShop(context, widget.shopId);
      } else {
        ref.read(shopProvider.notifier).setShop(widget.shop!);
      }
      ref.read(shopProvider.notifier)
        ..checkProductsPopular(context, widget.shopId)
        ..fetchCategory(context, widget.shopId)
        ..fetchShopMain(context)
        ..changeIndex(0);
      if (LocalStorage.instance.getToken().isNotEmpty) {
        ref.read(shopOrderProvider.notifier).getCart(context, () {});
      }

      if (widget.productId != null) {
        AppHelpers.showCustomModalBottomDragSheet(
          paddingTop: MediaQuery.of(context).padding.top + 100.h,
          context: context,
          modal: (c) => ProductScreen(
            productId: widget.productId,
            controller: c,
          ),
          isDarkMode: false,
          isDrag: true,
          radius: 16,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    event = ref.read(shopProvider.notifier);
    eventLike = ref.read(likeProvider.notifier);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr = LocalStorage.instance.getLangLtr();
    final state = ref.watch(shopProvider);
    return Directionality(
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Style.bgGrey,
        body: state.isLoading
            ? const Loading()
            : NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Style.white,
                      automaticallyImplyLeading: false,
                      toolbarHeight: (440.r +
                          MediaQuery.of(context).padding.top +
                          (state.shopData?.bonus == null ? 0 : 46.r) +
                          (state.endTodayTime.hour > TimeOfDay.now().hour
                              ? 0
                              : 70.r)),
                      elevation: 0.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: ShopPageAvatar(
                          workTime: state.endTodayTime.hour >
                                  TimeOfDay.now().hour
                              ? "${state.startTodayTime.hour.toString().padLeft(2, '0')}:${state.startTodayTime.minute.toString().padLeft(2, '0')} - ${state.endTodayTime.hour.toString().padLeft(2, '0')}:${state.endTodayTime.minute.toString().padLeft(2, '0')}"
                              : AppHelpers.getTranslation(TrKeys.close),
                          onLike: () {
                            event.onLike();
                            eventLike.fetchLikeProducts(context);
                          },
                          onChange: (){
                            setState(() {
                              isProducts = !isProducts;
                            });
                          },
                          isLike: state.isLike,
                          shop: state.shopData ?? ShopData(),
                          onShare: event.onShare,
                          bonus: state.shopData?.bonus,
                        ),
                      ),
                    ),
                  ];
                },
                body: isProducts ?
                state.isCategoryLoading || state.isPopularLoading
                    ? const Loading()
                    : ShopProductsScreen(
                        isPopularProduct: state.isPopularProduct,
                        listCategory: state.category,
                        currentIndex: state.currentIndex,
                        shopId: widget.shopId,
                      ) : state.isLoading
                    ? Padding(
                  padding: EdgeInsets.only(top: 64.r),
                  child: const Loading(),
                )
                    : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 48.r),
                    child: Column(
                      children: [
                        10.verticalSpace,
                        InfoScreen(
                            shop: state.shopData,
                            endTodayTime: state.endTodayTime,
                            startTodayTime: state.startTodayTime,
                            shopMarker: state.shopMarkers),
                        20.verticalSpace,
                        OrderFoodScreen(
                          shop: state.shopData,
                          startOrder: () {
                            ref.read(mainProvider.notifier).selectIndex(0);
                          },
                        ),
                        20.verticalSpace,
                        ReviewScreen(
                          shop: state.shopData,
                          review: state.reviews,
                          reviewCount: state.reviewCount,
                        )
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.all(16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const PopButton(),
              LocalStorage.instance.getToken().isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        AppHelpers.showCustomModalBottomDragSheet(
                          paddingTop:
                              MediaQuery.of(context).padding.top + 100.h,
                          context: context,
                          modal: (c) => CartOrderPage(
                            isGroupOrder: state.isGroupOrder,
                            controller: c,
                          ),
                          isDarkMode: false,
                          isDrag: true,
                          radius: 12,
                        );
                      },
                      child: AnimationButtonEffect(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Style.brandGreen,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.r),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 10.w),
                          child: Row(
                            children: [
                              const Icon(
                                FlutterRemix.shopping_bag_3_line,
                                color: Style.black,
                              ),
                              12.horizontalSpace,
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 14.w),
                                decoration: BoxDecoration(
                                  color: Style.black,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18.r),
                                  ),
                                ),
                                child: Consumer(builder: (context, ref, child) {
                                  return ref.watch(shopOrderProvider).isLoading
                                      ? CupertinoActivityIndicator(
                                          color: Style.white,
                                          radius: 10.r,
                                        )
                                      : Text(
                                          intl.NumberFormat.currency(
                                            symbol: LocalStorage.instance
                                                .getSelectedCurrency()
                                                .symbol,
                                          ).format(ref
                                                  .watch(shopOrderProvider)
                                                  .cart
                                                  ?.totalPrice ??
                                              0),
                                          style: Style.interSemi(
                                            size: 16,
                                            color: Style.white,
                                          ),
                                        );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
