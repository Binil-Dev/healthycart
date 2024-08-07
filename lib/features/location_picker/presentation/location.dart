import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/custom_button_n_search/common_button.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/location_picker/application/location_provider.dart';
import 'package:healthycart/features/location_picker/presentation/location_search.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:healthycart/utils/constants/image/image.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationProvider>(builder: (context, locationProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(BImage.lottieLocation, height: 232),
              const Gap(24),
              Text('Tap below to select hospital location.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                      )),
              const Gap(40),
              (locationProvider.locationGetLoading)
                  ? const SizedBox(
                      height: 48,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: LoadingIndicater(),
                        ),
                      ),
                    )
                  : CustomButton(
                      width: double.infinity,
                      height: 48,
                      onTap: () {
                        locationProvider.getLocationPermisson().then((value) {
                          if (value == true) {
                            EasyNavigation.push(
                                context: context,
                                page: const UserLocationSearchWidget());
                          }else {
                            CustomToast.errorToast(
                                text: 'Please enable location.');
                          }
                        });
                      },
                      text: "Pick Hospital Location",
                      buttonColor: BColors.buttonLightColor,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(fontSize: 18, color: BColors.white),
                    ),
              const Gap(16),
            ],
          ),
        );
      }),
    );
  }
}
