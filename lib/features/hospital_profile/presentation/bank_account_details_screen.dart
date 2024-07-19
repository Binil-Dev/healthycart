import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/app_bar/sliver_appbar.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_profile/presentation/widget/bank_details_sheet.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class BankAccountDetailsScreen extends StatelessWidget {
  const BankAccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (context, state, _) {
      final bankDetails = state.hospitalDataFetched!;
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverCustomAppbar(
              title: 'Bank Account Details',
              onBackTap: () {
                Navigator.pop(context);
              },
            ),
            if (bankDetails.accountHolderName == null &&
                bankDetails.accountNumber == null)
              const SliverFillRemaining(
                child: NoDataImageWidget(text: 'No Bank Details Found'),
              )
            else
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DetailsColumn(
                                title: 'Account Holder Name',
                                value: bankDetails.accountHolderName
                                        ?.toUpperCase() ??
                                    'Not provided',
                              ),
                              const Gap(10),
                              DetailsColumn(
                                title: 'Bank Name',
                                value: bankDetails.bankName?.toUpperCase() ??
                                    'Not provided',
                              ),
                              const Gap(10),
                              DetailsColumn(
                                title: 'Account Number',
                                value:
                                    bankDetails.accountNumber?.toUpperCase() ??
                                        'Not provided',
                              ),
                              const Gap(10),
                              DetailsColumn(
                                title: 'IFSC Code',
                                value: bankDetails.ifscCode?.toUpperCase() ??
                                    'Not provided',
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              backgroundColor: BColors.white,
              isScrollControlled: true,
              useSafeArea: true,
              context: context,
              builder: (context) => BankDetailsSheet(
                hospitalModel: bankDetails,
              ),
            );
          },
          child: Container(
            height: 60,
            color: BColors.mainlightColor,
            child: Center(
                child: Text(
              bankDetails.accountHolderName == null
                  ? '+ Add Bank Details'
                  : 'Update Bank Details',
              style: const TextStyle(
                  color: BColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            )),
          ),
        ),
      );
    });
  }
}

class DetailsColumn extends StatelessWidget {
  const DetailsColumn({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: BColors.black, fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const Gap(5),
        Text(
          value,
          style: const TextStyle(
              color: BColors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
