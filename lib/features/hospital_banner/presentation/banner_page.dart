import 'package:flutter/material.dart';
import 'package:healthycart/core/custom/app_bar/custom_appbar_curve.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/features/hospital_banner/application/add_banner_provider.dart';
import 'package:healthycart/features/hospital_banner/presentation/widget/ad_slider.dart';
import 'package:healthycart/features/hospital_banner/presentation/widget/add_banner_popup_widget.dart';
import 'package:healthycart/features/hospital_banner/presentation/widget/add_new_banner.dart';
import 'package:healthycart/features/hospital_banner/presentation/widget/banner_image_grid.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<AddBannerProvider>(context, listen: false).getBanner();
    });
    PopupAddBannerDialouge popUp = PopupAddBannerDialouge.instance;
    return Consumer<AddBannerProvider>(
        builder: (context, addBannerProvider, _) {
      return CustomScrollView(
        slivers: [
          const CustomSliverCurveAppBarWidget(),
          const SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: AdSlider(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Add or Edit Banner's",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          (addBannerProvider.fetchLoading)

              /// loading is done here
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LinearProgressIndicator(
                        color: BColors.darkblue,
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    itemCount: addBannerProvider.bannerList.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 104),
                    itemBuilder: (context, index) {
                      if (index == addBannerProvider.bannerList.length) {
                        return addBannerProvider.bannerList.length < 3
                            ? AddNewBannerWidget(
                                onTap: () {
                                  popUp.showAddbannerDialouge(
                                    context: context,
                                    nameTitle: 'Tap to add banner',
                                    buttonText: 'Save',
                                    onAddTap: () {
                                      addBannerProvider.getImage();
                                    },
                                    buttonTap: () async {
                                      if (addBannerProvider.imageFile == null) {
                                        CustomToast.errorToast(
                                            text: 'Pick a banner image');
                                        return;
                                      }
                                      await addBannerProvider
                                          .saveImage()
                                          .then((value) async {
                                        await addBannerProvider.addBanner(
                                            context: context);
                                      });
                                    },
                                  );
                                },
                                child: const Center(child: Icon(Icons.add)),
                              )
                            : null;
                      } else {
                        return BannerImageWidget(
                          index: index,
                          indexNumber: '${index + 1}',
                          bannerData: addBannerProvider.bannerList[index],
                        );
                      }
                    },
                  ),
                )
        ],
      );
    });
  }
}
