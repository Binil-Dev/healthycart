import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/custom_cached_network/custom_cached_network_image.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_request_userside/application/provider/hospital_booking_provider.dart.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:healthycart/utils/constants/image/image.dart';
import 'package:provider/provider.dart';

class UserPayment extends StatefulWidget {
  const UserPayment({super.key});

  @override
  State<UserPayment> createState() => _UserPaymentState();
}

class _UserPaymentState extends State<UserPayment> {
  final scrollController = ScrollController();
  @override
  void initState() {
    final provider = context.read<HospitalBookingProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        provider
          ..cleatDataCompleted()
          ..getCompletedOrders(
              hospitalId: authProvider.hospitalDataFetched!.id!,)
          ..getTransactionData(hospitalId: authProvider.hospitalDataFetched!.id!);
      },
    );
    provider.completeInit(
       scrollController:  scrollController,hospitalId:  authProvider.hospitalDataFetched!.id!,);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<HospitalBookingProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          if (ordersProvider.isLoading ||
              ordersProvider.hospitalTransactionModel == null)
            const SliverFillRemaining(
              child: Center(
                child: LoadingIndicater(),
              ),
            )
          else if (ordersProvider.completedList.isEmpty &&
              ordersProvider.isLoading == false)
            const SliverFillRemaining(
              child: NoDataImageWidget(text: 'No Transactiond Found!'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16, top: 32),
              sliver: SliverList.separated(
                separatorBuilder: (context, index) => const Gap(5),
                itemCount: ordersProvider.completedList.length,
                itemBuilder: (context, index) {
                  final orders = ordersProvider.completedList[index];
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all()),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            height: 50,
                            width: 50,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: orders.userDetails!.image == null
                                ? Image.asset(BImage.userAvatar)
                                : CustomCachedNetworkImage(
                                    image: orders.userDetails!.image!),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            orders.userDetails!.userName ??
                                                'Not Provided',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(fontSize: 12)),
                                      ),
                                      Text(
                                        orders.paymentMethod ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                                color: BColors.green,
                                                fontSize: 12),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₹${orders.totalAmount ?? 0}',
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .copyWith(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Commission : ${orders.commission}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(fontSize: 12)),
                                      Text(
                                          'Commission Amt : ₹${orders.commissionAmt}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          SliverToBoxAdapter(
              child: (ordersProvider.isLoading == true &&
                      ordersProvider.completedList.isNotEmpty)
                  ? const Center(child: LoadingIndicater())
                  : const Gap(0)),
        ],
      ),
      bottomNavigationBar: ordersProvider.hospitalTransactionModel != null
          ? Container(
              height: 52,
              color: BColors.mainlightColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Transaction : ₹${ordersProvider.hospitalTransactionModel!.totalTransactionAmt}',
                      style: const TextStyle(
                          color: BColors.darkblue, fontSize: 12),
                    ),
                    Text(
                      'Total Commission : ₹${ordersProvider.hospitalTransactionModel!.totalCommissionPending}',
                      style: const TextStyle(
                          color: BColors.darkblue, fontSize: 12),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }
}