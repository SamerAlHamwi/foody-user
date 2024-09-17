import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:riverpodtemp/application/currency/currency_provider.dart';
import 'package:riverpodtemp/application/home/home_notifier.dart';
import 'package:riverpodtemp/application/home/home_provider.dart';
import 'package:riverpodtemp/application/home/home_state.dart';
import 'package:riverpodtemp/application/map/view_map_provider.dart';
import 'package:riverpodtemp/application/product/product_provider.dart';
import 'package:riverpodtemp/application/shop_order/shop_order_provider.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/local_storage.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/components/loading.dart';
import 'package:riverpodtemp/presentation/pages/home/app_bar_home.dart';
import 'package:riverpodtemp/presentation/pages/home/category_screen.dart';
import 'package:riverpodtemp/presentation/pages/home/filter_category_product.dart';
import 'package:riverpodtemp/presentation/pages/product/product_page.dart';
import 'package:riverpodtemp/presentation/pages/shop/widgets/shop_product_item.dart';
import 'package:riverpodtemp/presentation/routes/app_router.dart';
import 'package:riverpodtemp/presentation/theme/theme.dart';
import 'package:upgrader/upgrader.dart';
import '../../../infrastructure/models/data/local_cart_model.dart';
import '../../../infrastructure/models/data/shop_data.dart';
import '../../components/custom_network_image.dart';
import '../../components/title_icon.dart';
import 'product_by_category.dart';
import 'shimmer/banner_shimmer.dart';
import 'widgets/add_address.dart';
import 'widgets/banner_item.dart';
import 'widgets/recommended_item.dart';
import 'widgets/shop_bar_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late HomeNotifier event;
  late RefreshController _bannerController;
  late RefreshController _productController;
  late RefreshController _categoryController;
  late RefreshController _storyController;
  late RefreshController _popularController;
  late RefreshController _restaurantController;

  @override
  void initState() {
    _bannerController = RefreshController();
    _productController = RefreshController();
    _categoryController = RefreshController();
    _storyController = RefreshController();
    _popularController = RefreshController();
    _restaurantController = RefreshController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier)
        ..fetchBranches(context, false)
        ..setAddress()
        ..fetchBanner(context)
        ..fetchStore(context)
        ..fetchProductsWithCheckBranch(context)
        ..fetchProductsPopular(context)
        ..fetchRecipeCategory(context)
        ..fetchCategories(context);
      ref.read(viewMapProvider.notifier).checkAddress();
      ref.read(currencyProvider.notifier).fetchCurrency(context);
      if (LocalStorage.instance.getToken().isNotEmpty) {
        ref
            .read(shopOrderProvider.notifier)
            .getCart(context, () {}, isStart: true);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    event = ref.read(homeProvider.notifier);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _categoryController.dispose();
    _productController.dispose();
    _storyController.dispose();
    _popularController.dispose();
    super.dispose();
  }

  void _onLoading(HomeState state) {
    if (state.isSelectCategoryLoading == 0) {
      event.fetchCategoriesPage(context, _productController);
    } else {
      event.fetchFilterProductsPage(context, _productController);
    }
  }

  void _onRefresh(HomeState state) {
    state.isSelectCategoryLoading == 0
        ? (event
          ..fetchBannerPage(context, _productController, isRefresh: true)
          ..fetchProductsPage(context, _productController, isRefresh: true)
          ..fetchCategoriesPage(context, _productController, isRefresh: true)
          ..fetchRecipeCategoryPage(context, _productController,
              isRefresh: true)
          ..fetchStorePage(context, _productController, isRefresh: true)
          ..fetchProductsPopularPage(context, _productController,
              isRefresh: true))
        : event.fetchFilterProductsPage(context, _productController,
            isRefresh: true);
    _productController.resetNoData();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final stateCart = ref.watch(shopOrderProvider).cart?.userCarts?.first;
    final bool isDarkMode = LocalStorage.instance.getAppThemeMode();
    final bool isLtr = LocalStorage.instance.getLangLtr();
    ref.listen(viewMapProvider, (previous, next) {
      if (!next.isSetAddress &&
          !(previous?.isSetAddress ?? false == next.isSetAddress)) {
        AppHelpers.showAlertDialog(context: context, child: const AddAddress());
      }
    });
    return UpgradeAlert(
      child: Directionality(
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDarkMode ? Style.mainBackDark : Style.bgGrey,
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            physics: const BouncingScrollPhysics(),
            controller: _productController,
            header: WaterDropMaterialHeader(
              distance: 160.h,
              backgroundColor: Style.white,
              color: Style.textGrey,
            ),
            onLoading: () => _onLoading(state),
            onRefresh: () => _onRefresh(state),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32.h),
                child: Column(
                  children: [
                    AppBarHome(
                      state: state,
                      event: event,
                      refreshController: _productController,
                    ),
                    24.verticalSpace,
                    _body(stateCart, state, context)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(dynamic stateCart, HomeState state, BuildContext context) {
    return Column(
      children: [
        // state.story?.isNotEmpty ?? false
        //     ? SizedBox(
        //         height: 110.h,
        //         child: SmartRefresher(
        //           controller: _storyController,
        //           scrollDirection: Axis.horizontal,
        //           enablePullDown: false,
        //           enablePullUp: true,
        //           primary: false,
        //           onLoading: () async {
        //             await event.fetchStorePage(context, _storyController);
        //           },
        //           child: AnimationLimiter(
        //             child: ListView.builder(
        //               shrinkWrap: true,
        //               primary: false,
        //               scrollDirection: Axis.horizontal,
        //               itemCount: state.story?.length ?? 0,
        //               padding: EdgeInsets.only(left: 16.w),
        //               itemBuilder: (context, index) =>
        //                   AnimationConfiguration.staggeredList(
        //                 position: index,
        //                 duration: const Duration(milliseconds: 375),
        //                 child: SlideAnimation(
        //                   verticalOffset: 50.0,
        //                   child: FadeInAnimation(
        //                     child: ShopBarItem(
        //                       index: index,
        //                       controller: _storyController,
        //                       story: state.story?[index]?.first,
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       )
        //     : const SizedBox.shrink(),
        ///Restaurants
        !state.isBranchesLoading ?
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleAndIcon(
              title:
              AppHelpers.getTranslation(TrKeys.restaurants),
            ),
            6.verticalSpace,
            Container(
              height: state.branches!.isNotEmpty ? 1.sw/3 : 0,
              margin: EdgeInsets.only(bottom: 8.h,left: 6.w,right: 6.w),
              child: SmartRefresher(
                scrollDirection: Axis.horizontal,
                enablePullDown: false,
                enablePullUp: true,
                primary: false,
                controller: _restaurantController,
                onLoading: () async {
                  // await event.fetchCategoriesPage(context, _restaurantController);
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: state.branches!.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: Container(
                        width: state.branches!.isNotEmpty ? 1.sw/3 : 0,
                        height: state.branches!.isNotEmpty ? 1.sw/3 : 0,
                        padding: EdgeInsets.all(4.sp),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: InkWell(
                              onTap: (){
                                context.router.push(ShopRoute(shopId: state.branches![index].id!));
                                // context.router.push(SingleShopRoute());
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomNetworkImage(
                                        url: state.branches![index].backgroundImg!,
                                        height: 1.sw/3.3,
                                        width: 1.sw/3.3,
                                        radius: 8.r,
                                      ),
                                      Container(
                                        height: 1.sw/3.3,
                                        width: 1.sw/3.3,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                            color: Style.black.withOpacity(0.3)),
                                      ),
                                      Text(
                                        state.branches![index].translation?.title ?? "",
                                        style: Style.interNormal(
                                          size: 13,
                                          color: Style.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.visible,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                                  /*
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.2,
                                child: Container(
                                  // padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Style.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          CustomNetworkImage(
                                            url: state.branches![index].backgroundImg ?? '',
                                            height: 120,
                                            width: MediaQuery.of(context).size.width / 1.2,
                                            radius: 8.r,
                                          ),
                                          Positioned(
                                            bottom: -30,
                                            right: 16,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                CustomNetworkImage(
                                                  url: state.branches![index].logoImg ?? '',
                                                  height: 60,
                                                  width: 60,
                                                  radius: 50.r,
                                                  isWithBorder: true,
                                                ),
                                                Positioned(
                                                  bottom: -1,
                                                  right: 5,
                                                  child: Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                        color: Style.brandGreen,
                                                        borderRadius: BorderRadius.circular(50.r)
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      6.verticalSpace,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width / 1.7,
                                              child: Text(
                                                state.branches![index].translation?.title ??
                                                    "",
                                                style: Style.interNormal(
                                                  size: 18,
                                                  color: Style.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              state.branches![index].type ?? '',
                                              style: Style.interNormal(
                                                size: 12,
                                                color: Style.textGrey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            6.verticalSpace,
                                            Text(
                                              'Dessert',
                                              style: Style.interNormal(
                                                size: 14,
                                                color: Style.brandGreen,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                                   */
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        )
            : const SizedBox(),

        ///Products Popular
        state.productsPopular.isNotEmpty
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleAndIcon(
              title:
              "${AppHelpers.getTranslation(TrKeys.popular)} ${AppHelpers.getTranslation(TrKeys.products)}",
            ),
            16.verticalSpace,
            SizedBox(
              height: 250.h,
              child: SmartRefresher(
                controller: _popularController,
                scrollDirection: Axis.horizontal,
                enablePullDown: false,
                enablePullUp: true,
                primary: false,
                onLoading: () async {
                  await event.fetchProductsPopularPage(
                      context, _popularController);
                },
                child: AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.productsPopular.length,
                    padding: EdgeInsets.only(left: 16.w),
                    itemBuilder: (context, index) =>
                        AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {

                                  AppHelpers.showCustomModalBottomDragSheet(
                                    paddingTop: MediaQuery.of(context)
                                        .padding
                                        .top +
                                        100.h,
                                    context: context,
                                    modal: (c) => ProductScreen(
                                      data: state.productsPopular[index],
                                      controller: c,
                                    ),
                                    isDarkMode: false,
                                    isDrag: true,
                                    radius: 16,
                                  );
                                },
                                child: SizedBox(
                                  width: 180.r,
                                  child: ShopProductItem(
                                    product: state.productsPopular[index],
                                    count: LocalStorage.instance
                                        .getCartLocal()
                                        .firstWhere(
                                            (element) =>
                                        element.stockId ==
                                            (state
                                                .productsPopular[
                                            index]
                                                .stock
                                                ?.id), orElse: () {
                                      return CartLocalModel(
                                          count: 0, stockId: 0);
                                    }).count,
                                    isAdd: (LocalStorage.instance
                                        .getCartLocal()
                                        .map((item) => item.stockId)
                                        .contains(state
                                        .productsPopular[index]
                                        .stock
                                        ?.id)),
                                    addCount: () {
                                      ref
                                          .read(
                                          shopOrderProvider.notifier)
                                          .addCount(
                                        context: context,
                                        localIndex: LocalStorage
                                            .instance
                                            .getCartLocal()
                                            .findIndex(state
                                            .productsPopular[
                                        index]
                                            .stock
                                            ?.id),
                                      );
                                    },
                                    removeCount: () {
                                      ref
                                          .read(
                                          shopOrderProvider.notifier)
                                          .removeCount(
                                        context: context,
                                        localIndex: LocalStorage
                                            .instance
                                            .getCartLocal()
                                            .findIndex(state
                                            .productsPopular[
                                        index]
                                            .stock
                                            ?.id),
                                      );
                                    },
                                    addCart: () {
                                      if (LocalStorage.instance
                                          .getToken()
                                          .isNotEmpty) {
                                        ref
                                            .read(shopOrderProvider
                                            .notifier)
                                            .addCart(
                                            context,
                                            state.productsPopular[
                                            index]);
                                        ref
                                            .read(
                                            productProvider.notifier)
                                            .createCart(
                                            context,
                                            state
                                                .productsPopular[
                                            index]
                                                .shopId ??
                                                0, () {
                                          ref
                                              .read(shopOrderProvider
                                              .notifier)
                                              .getCart(context, () {});
                                        },
                                            product:
                                            state.productsPopular[
                                            index]);
                                      } else {
                                        context.pushRoute(
                                            const LoginRoute());
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
        12.verticalSpace,

        ///Banner
        state.isBannerLoading
            ? const BannerShimmer() :
        state.banners.isNotEmpty ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleAndIcon(
                  title: AppHelpers.getTranslation(TrKeys.specialOffers),
                ),
                16.verticalSpace,
                Container(
                    height: state.banners.isNotEmpty ? 200.h : 0,
                    margin: EdgeInsets.only(
                        bottom: state.banners.isNotEmpty ? 30.h : 0),
                    child: SmartRefresher(
                      scrollDirection: Axis.horizontal,
                      enablePullDown: false,
                      enablePullUp: true,
                      primary: false,
                      controller: _bannerController,
                      onLoading: () async {
                        await event.fetchBannerPage(context, _bannerController);
                      },
                      child: AnimationLimiter(
                        child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          scrollDirection: Axis.horizontal,
                          itemCount: state.banners.length,
                          padding: EdgeInsets.only(left: 16.w),
                          itemBuilder: (context, index) =>
                              AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: BannerItem(
                                  banner: state.banners[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
            : const SizedBox.shrink(),
        ///Recipes
        Column(
          children: [
            state.recipesCategory.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleAndIcon(
                        title: AppHelpers.getTranslation(TrKeys.recipes),
                        rightTitle: AppHelpers.getTranslation(TrKeys.seeAll),
                        onRightTap: () {
                          context.pushRoute(RecommendedRoute());
                        },
                      ),
                      16.verticalSpace,
                      SizedBox(
                        height: 190.h,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            scrollDirection: Axis.horizontal,
                            itemCount: state.recipesCategory.length,
                            padding: EdgeInsets.only(left: 16.w),
                            itemBuilder: (context, index) =>
                                AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: RecommendedItem(
                                      recipeCategory:
                                          state.recipesCategory[index],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            16.verticalSpace,



            // ListView.builder(
            //   padding: EdgeInsets.zero,
            //   physics: const NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: state.allProducts.length,
            //   itemBuilder: (context, index) {
            //     return ProductByCategory(
            //       categoryId: state.allProducts[index].id ?? 0,
            //       title: state.allProducts[index].translation?.title ?? "",
            //       listOfProduct: state.allProducts[index].products ?? [],
            //     );
            //   },
            // ),
          ],
        ),


        CategoryScreen(
          state: state,
          event: event,
          categoryController: _categoryController,
          restaurantController: _productController,
        ),
        state.isSelectCategoryLoading == -1
            ? const Loading()
            : state.isSelectCategoryLoading == 0
            ? const SizedBox()
            : FilterCategoryProduct(
          stateCart: stateCart,
          state: state,
          event: event,
        ),
      ],
    );
  }
}
