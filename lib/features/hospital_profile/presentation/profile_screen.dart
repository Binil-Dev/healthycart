import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/app_bar/custom_appbar_curve.dart';
import 'package:healthycart/core/custom/confirm_alertbox/confirm_alertbox_widget.dart';
import 'package:healthycart/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_profile/application/profile_provider.dart';
import 'package:healthycart/features/hospital_profile/presentation/bank_account_details_screen.dart';
import 'package:healthycart/features/hospital_profile/presentation/payments_screen.dart';
import 'package:healthycart/features/hospital_profile/presentation/widget/contact_us_sheet.dart';
import 'package:healthycart/features/hospital_profile/presentation/widget/doctor_list_profile/doctor_list.dart';
import 'package:healthycart/features/hospital_profile/presentation/widget/profile_header_widget.dart';
import 'package:healthycart/features/hospital_profile/presentation/widget/profile_main_container_widget.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, ProfileProvider>(
        builder: (context, authenticationProvider, profileProvider, _) {
      return CustomScrollView(
        slivers: [
          const CustomSliverCurveAppBarWidget(),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Gap(6),
                  const ProfileHeaderWidget(),
                  const Gap(8),
                  ProfileMainContainer(
                    text: 'Hospital On / Off',
                    sideChild: LiteRollingSwitch(
                      value: authenticationProvider
                              .hospitalDataFetched?.ishospitalON ??
                          false,
                      width: 80,
                      textOn: 'On',
                      textOff: 'Off',
                      colorOff: Colors.grey.shade400,
                      colorOn: BColors.mainlightColor,
                      iconOff: Icons.block_rounded,
                      iconOn: Icons.power_settings_new,
                      animationDuration: const Duration(milliseconds: 300),
                      onChanged: (bool ishospitalON) async {
                        LoadingLottie.showLoading(
                            context: context, text: 'Please wait...');
                        profileProvider.hospitalStatus(ishospitalON);
                        await profileProvider.setActiveHospital().whenComplete(
                          () {
                            EasyNavigation.pop(context: context);
                          },
                        );
                      },
                      onDoubleTap: () {},
                      onSwipe: () {},
                      onTap: () {},
                    ),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                      EasyNavigation.push(
                          context: context,
                          page: const BankAccountDetailsScreen());
                    },
                    child: const ProfileMainContainer(
                        text: 'Bank Account Details',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                      EasyNavigation.push(
                          context: context, page: const DoctorProfileList());
                    },
                    child: const ProfileMainContainer(
                        text: 'Doctors List',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                      EasyNavigation.push(
                          context: context, page: const PaymentsScreen());
                    },
                    child: const ProfileMainContainer(
                        text: 'Payment History',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: BColors.white,
                        barrierColor: BColors.black.withOpacity(0.5),
                        elevation: 5,
                        showDragHandle: true,
                        context: context,
                        builder: (context) => ContactUsBottomSheet(
                          message:
                              'Hi, I am reaching out from ${authenticationProvider.hospitalDataFetched?.hospitalName}',
                        ),
                      );
                    },
                    child: const ProfileMainContainer(
                        text: 'Contact Us',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.call),
                        )),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                      ConfirmAlertBoxWidget.showAlertConfirmBox(
                          context: context,
                          confirmButtonTap: () async {
                            LoadingLottie.showLoading(
                                context: context, text: 'Logging out..');
                            await authenticationProvider.hospitalLogOut(
                                context: context);
                          },
                          titleText: 'Confirm to Log Out',
                          subText: 'Are you sure to Log Out ?');
                    },
                    child: const ProfileMainContainer(
                        text: 'Log Out',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.logout),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
