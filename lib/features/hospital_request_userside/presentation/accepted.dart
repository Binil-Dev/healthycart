import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/confirm_alertbox/confirm_alertbox_widget.dart';
import 'package:healthycart/core/custom/cutom_buttons/button_widget.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_request_userside/application/provider/hospital_booking_provider.dart.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/date_and_time_tab.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/doctor_details_card.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/orderid_date_widget.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/patient_details_card.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Accepted extends StatefulWidget {
  const Accepted({super.key});

  @override
  State<Accepted> createState() => _NewRequestState();
}

class _NewRequestState extends State<Accepted> {
  @override
  void initState() {
    final orderProvider = context.read<HospitalBookingProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        orderProvider.getTransactionData(
            hospitalId: authProvider.hospitalDataFetched!.id!);
        orderProvider.getAcceptedBookingsStream(
            hospitalId: authProvider.hospitalDataFetched!.id!);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HospitalBookingProvider, AuthenticationProvider>(
        builder: (context, bookingProvider, authProvider, _) {
      return CustomScrollView(
        slivers: [
          if (bookingProvider.isLoading == true &&
              bookingProvider.acceptedList.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: LoadingIndicater(),
              ),
            )
          else if (bookingProvider.acceptedList.isEmpty)
            const SliverFillRemaining(
              child: NoDataImageWidget(text: 'No New Bookings Found'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: bookingProvider.acceptedList.length,
                itemBuilder: (context, index) {
                  final bookings = bookingProvider.acceptedList[index];
                  final formattedDate = DateFormat('dd/MM/yyyy')
                      .format(bookings.acceptedAt!.toDate());
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: PhysicalModel(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               OrderIDAndDateSection(orderData: bookings, date: formattedDate),
                              const Gap(8),
                              DoctorRoundImageNameWidget(
                                doctorImage:
                                    bookings.selectedDoctor!.doctorImage!,
                                doctorName:
                                    bookings.selectedDoctor!.doctorName!,
                                doctorQualification: bookings
                                    .selectedDoctor!.doctorQualification!,
                                doctorSpecialization: bookings
                                    .selectedDoctor!.doctorSpecialization!,
                              ),
                              const Gap(8),
                              DateAndTimeTab(
                                  text1: 'Date selected',
                                  text2: bookings.newBookingDate == null
                                      ? bookings.selectedDate!
                                      : bookings.newBookingDate!,
                                  tabWidth: 104,
                                  gap: 32),
                              const Gap(8),
                              DateAndTimeTab(
                                  text1: 'Time slot',
                                  text2: bookings.newTimeSlot == null
                                      ? bookings.selectedTimeSlot!
                                      : bookings.newTimeSlot!,
                                  tabWidth: 152,
                                  gap: 20),
                              const Gap(8),

                              /* ----------------------------- PATIENT DETAILS ---------------------------- */
                                 Text(
                                'Patient Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Gap(4),
                              PatientDetailsContainer(
                                uhid: bookings.uhid ?? null,
                                patientName: bookings.patientName!,
                                patientGender: bookings.patientGender!,
                                patientAge: bookings.patientAge!,
                                patientPlace: bookings.patientPlace!,
                                patientNumber: bookings.patientNumber!,
                                onCall: () {
                                  bookingProvider.lauchDialer(
                                      phoneNumber:
                                          '+91${bookings.patientNumber}');
                                },
                              ),
                              const Gap(8),
                              /* ------------------------------ USER DETAILS ------------------------------ */
                              Text(
                                'Booked By :-',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Gap(8),
                              Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade200),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bookings
                                                      .userDetails!.userName!,
                                                  style: const TextStyle(
                                                      color: BColors.black,
                                                      fontSize: 14),
                                                ),
                                                const Gap(4),
                                                Text(
                                                  bookings
                                                      .userDetails!.phoneNo!,
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            const Gap(10),
                                            PhysicalModel(
                                                elevation: 2,
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: SizedBox(
                                                    width: 35,
                                                    height: 35,
                                                    child: Center(
                                                        child: IconButton(
                                                            onPressed: () {
                                                              bookingProvider.lauchDialer(
                                                                  phoneNumber: bookings
                                                                      .userDetails!
                                                                      .phoneNo!);
                                                            },
                                                            icon: const Icon(
                                                                Icons.phone,
                                                                size: 20,
                                                                color: Colors
                                                                    .blue))))),
                                          ],
                                        ),
                                        const Gap(4),
                                        /* -------------------------- USER ACCEPTED STATUS -------------------------- */
                                        Row(
                                          children: [
                                            const Text(
                                              'User Status : ',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            bookings.isUserAccepted == false
                                                ? const Text(
                                                    'Pending',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffFFB800),
                                                        fontSize: 12),
                                                  )
                                                : const Text(
                                                    'Accepted',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12),
                                                  ),
                                          ],
                                        ),
                                        const Gap(4),
                                        /* ---------------------------------- FEES ---------------------------------- */

                                        Row(
                                          children: [
                                            const Text(
                                              'Consulting Fee : ',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '₹${bookings.totalAmount}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const Gap(4),
                                        /* -------------------------- USER PAYEMENT STATUS -------------------------- */
                                        Row(
                                          children: [
                                            const Text(
                                              'Payment Status : ',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                bookings.paymentStatus == 0
                                                    ? const Text(
                                                        'Pending',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffFFB800),
                                                            fontSize: 12),
                                                      )
                                                    : const Text(
                                                        'Completed',
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 12),
                                                      ),
                                                Gap(10),
                                                bookings.paymentMethod ==
                                                            'Cash in hand' &&
                                                        bookings.paymentStatus ==
                                                            0
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          ConfirmAlertBoxWidget
                                                              .showAlertConfirmBox(
                                                                  context:
                                                                      context,
                                                                  confirmButtonTap:
                                                                      () {
                                                                    bookingProvider.updatePaymentStatus(
                                                                        orderId:
                                                                            bookings.id!);
                                                                  },
                                                                  titleText:
                                                                      'Payment Received?',
                                                                  subText:
                                                                      'Are you revieved the payment?');
                                                        },
                                                        child: const Text(
                                                          'Payment Recieved?',
                                                          style: TextStyle(
                                                              color: BColors
                                                                  .darkblue,
                                                              fontSize: 12,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                        ),
                                                      )
                                                    : const Gap(0)
                                              ],
                                            )
                                          ],
                                        ),
                                        const Gap(4),
                                        /* ----------------------------- PAYEMENT METHOD ---------------------------- */
                                        bookings.isUserAccepted == false
                                            ? const Gap(0)
                                            : Row(
                                                children: [
                                                  const Text(
                                                    'Payment Method : ',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Text(
                                                    bookings.paymentMethod ??
                                                        'Not Provided',
                                                    style: const TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              ),
                                      ],
                                    ),
                                  )),
                              const Gap(16),
                              /* ----------------------------- COMPLETE BUTTON ---------------------------- */

                              ButtonWidget(
                                  buttonHeight: 42,
                                  buttonWidth: double.infinity,
                                  buttonColor: const Color(0xff6EAE6D),
                                  buttonWidget: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Mark Visited',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const Gap(5),
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: BColors.white,
                                      )
                                    ],
                                  ),
                                  onPressed: () {
                                    if (bookings.paymentStatus == 0) {
                                      CustomToast.errorToast(
                                          text: 'Payment is pending');
                                      return;
                                    }
                                    if (bookings.isUserAccepted == false) {
                                      CustomToast.errorToast(
                                          text: 'Booking not accepted by user');
                                      return;
                                    } else {
                                      ConfirmAlertBoxWidget.showAlertConfirmBox(
                                          context: context,
                                          confirmButtonTap: () {
                                            LoadingLottie.showLoading(
                                                context: context,
                                                text: 'Please wait...');
                                            bookingProvider
                                                .updateOrderStatus(
                                              commission: bookingProvider.hospitalTransactionModel!.commission,
                                              commissionAmt: bookingProvider.calculateOrderCommission(bookings.totalAmount!),    
                                              orderId: bookings.id!,
                                              orderStatus: 2,
                                              fcmtoken: bookings.userDetails!.fcmToken ??'',
                                              hospitalId: bookings.hospitalId,
                                              hospitalName: bookings
                                                  .hospitalDetails!
                                                  .hospitalName,
                                              totalAmount: bookings.totalAmount,
                                              dayTransactionDate: authProvider
                                                  .hospitalDataFetched!
                                                  .dayTransaction,
                                              paymentMode:
                                                  bookings.paymentMethod,
                                            )
                                                .whenComplete(
                                              () {
                                                EasyNavigation.pop(
                                                    context: context);
                                              },
                                            );
                                          },
                                          titleText: 'Confirm',
                                          subText:
                                              'Are you sure to confirm the patient is visited?');
                                    }
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
        ],
      );
    });
  }
}

class CustomElevatedTabButton extends StatelessWidget {
  const CustomElevatedTabButton({
    super.key,
    required this.backgroundColor,
    required this.child,
    required this.onPressed,
  });

  final Color backgroundColor;
  final Widget child;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: SizedBox(
        height: 40,
        width: 136,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              elevation: 5,
              backgroundColor: backgroundColor,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: const BorderSide(),
                  borderRadius: BorderRadius.circular(14))),
          child: child,
        ),
      ),
    );
  }
}
