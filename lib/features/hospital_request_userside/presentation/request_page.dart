import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:healthycart/core/custom/app_bar/custom_appbar_curve.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/accepted.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/cancelled.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/completed.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/new_request.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            const CustomSliverCurveAppBarWidget(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ButtonsTabBar(
                    unselectedLabelStyle: const TextStyle(
                        color: BColors.darkblue,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                    labelStyle: const TextStyle(
                        color: BColors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                    backgroundColor: BColors.darkblue,
                    unselectedBackgroundColor: BColors.white,
                    unselectedBorderColor: BColors.darkblue,
                    borderWidth: 1,
                    contentPadding: const EdgeInsets.all(8),
                    radius: 12,
                    duration: 50,
                    buttonMargin: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: const [
                      Tab(
                        text: 'New Request',
                      ),
                      Tab(
                        text: 'Accepted',
                      ),
                      Tab(
                        text: 'Completed',
                      ),
                      Tab(
                        text: 'Cancelled',
                      ),
                    ]),
              ),
            ),
            const SliverFillRemaining(
              child: TabBarView(children: [
                NewRequest(),
                Accepted(),
                Completed(),
                Cancelled(),
              ]),
            )
          ]),
    );
  }
}
