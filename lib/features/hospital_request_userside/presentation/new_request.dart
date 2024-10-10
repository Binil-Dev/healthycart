import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/confirm_alertbox/confirm_alertbox_widget.dart';
import 'package:healthycart/core/custom/custom_button_n_search/search_field_button.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_request_userside/application/provider/hospital_booking_provider.dart.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/date_and_time_tab.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/date_time_picker.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/doctor_details_card.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/orderid_date_widget.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/patient_details_card.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/reject_popup.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewRequest extends StatefulWidget {
  const NewRequest({super.key});

  @override
  State<NewRequest> createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  @override
  void initState() {
    final orderProvider = context.read<HospitalBookingProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        orderProvider.getNewRequestStream(
            hospitalId: authProvider.hospitalDataFetched!.id!);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalBookingProvider>(
        builder: (context, bookingProvider, _) {
      return CustomScrollView(
        slivers: [
          if (bookingProvider.isLoading == true &&
              bookingProvider.newRequestList.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: LoadingIndicater(),
              ),
            )
          else if (bookingProvider.newRequestList.isEmpty)
            const SliverFillRemaining(
              child: NoDataImageWidget(text: 'No New Bookings Found'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: bookingProvider.newRequestList.length,
                itemBuilder: (context, index) {
                  final bookings = bookingProvider.newRequestList[index];
                  final formattedDate = DateFormat('dd/MM/yyyy')
                      .format(bookings.bookedAt!.toDate());
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
                  //             SearchTextFieldButton(
                  //   text: "Search Doctors",
                  //   controller: doctorProvider.searchController,
                  //   onChanged: (value) {
                  //     EasyDebounce.debounce(
                  //         'searchdoctors', const Duration(milliseconds: 500),
                  //         () {
                  //       doctorProvider.searchCategoryDoctors(value);
                  //     });
                  //   },
                  // ),
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
                              Row(
                                children: [
                                  DateAndTimeTab(
                                      text1: 'Time slot',
                                      text2: bookings.newTimeSlot == null
                                          ? bookings.selectedTimeSlot!
                                          : bookings.newTimeSlot!,
                                      tabWidth: 152,
                                      gap: 10),
                                  const Gap(5),
                                  /* --------------------------- TIME SLOT SELECTION -------------------------- */
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                DateAndTimePick(
                                                  onSave: () {
                                                    if (bookingProvider.selectedTimeSlot1 != null &&
                                                        bookingProvider
                                                                .selectedTimeSlot2 !=
                                                            null &&
                                                        bookingProvider
                                                            .dateController
                                                            .text
                                                            .isNotEmpty) {
                                                      bookingProvider.setTimeSlot(
                                                          bookingId:
                                                              bookingProvider
                                                                  .newRequestList[
                                                                      index]
                                                                  .id!,
                                                          newDate:
                                                              bookingProvider
                                                                  .dateController
                                                                  .text,
                                                          newTime:
                                                              '${bookingProvider.selectedTimeSlot1} - ${bookingProvider.selectedTimeSlot2}');
                                                      Navigator.pop(context);
                                                    } else {
                                                      CustomToast.errorToast(
                                                          text:
                                                              'Please select date and time');
                                                    }
                                                  },
                                                ));
                                      },
                                      child: const Text(
                                        'Change time slot?',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: BColors.black,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  )
                                ],
                              ),
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
                                uhid:  bookings.uhid ?? null,
                                patientName:
                                    bookings.patientName ?? 'Unknown User',
                                patientGender:
                                    bookings.patientGender ?? 'Unknown Gender',
                                patientAge:
                                    bookings.patientAge ?? 'Unknown Age',
                                patientPlace:
                                    bookings.patientPlace ?? 'Unknown Place',
                                patientNumber:
                                    bookings.patientNumber ?? 'Unknown Number',
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
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Gap(4),
                              Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade200),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bookings.userDetails!.userName!,
                                              style: const TextStyle(
                                                  color: BColors.black,
                                                  fontSize: 12),
                                            ),
                                            const Gap(4),
                                            Text(
                                              bookings.userDetails!.phoneNo!,
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                                  )),
                              const Gap(16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 136,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              RejectionReasonPopup(
                                            reasonController: bookingProvider
                                                .rejectionReasonCobtroller,
                                            formKey: bookingProvider
                                                .rejectionFormKey,
                                            onConfirm: () {
                                              if (!bookingProvider
                                                  .rejectionFormKey
                                                  .currentState!
                                                  .validate()) {
                                                bookingProvider.rejectionFormKey
                                                    .currentState!
                                                    .validate();
                                              } else {
                                                bookingProvider
                                                    .updateOrderStatus(
                                                  hospitalName: bookings
                                                      .hospitalDetails!
                                                      .hospitalName,
                                                  fcmtoken: bookings
                                                      .userDetails!.fcmToken!,
                                                  orderId: bookings.id!,
                                                  orderStatus: 3,
                                                  rejectReason: bookingProvider
                                                      .rejectionReasonCobtroller
                                                      .text,
                                                );
                                                bookingProvider
                                                    .rejectionReasonCobtroller
                                                    .clear();
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 136,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        ConfirmAlertBoxWidget
                                            .showAlertConfirmBox(
                                                context: context,
                                                confirmButtonTap: () {
                                                  LoadingLottie.showLoading(
                                                      context: context,
                                                      text: 'Please wait...');
                                                  bookingProvider
                                                      .updateOrderStatus(
                                                    orderId: bookings.id!,
                                                    orderStatus: 1,
                                                    fcmtoken: bookings
                                                            .userDetails!
                                                            .fcmToken ??
                                                        '',
                                                    hospitalName: bookings
                                                        .hospitalDetails!
                                                        .hospitalName,
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
                                                    'Are you sure you want to accept this order?');
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff6EAE6D),
                                          surfaceTintColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8))),
                                      child: Text('Approve',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              )
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
