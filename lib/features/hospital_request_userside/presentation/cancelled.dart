import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_request_userside/application/provider/hospital_booking_provider.dart.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/date_and_time_tab.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/doctor_details_card.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/patient_details_card.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Cancelled extends StatefulWidget {
  const Cancelled({super.key});

  @override
  State<Cancelled> createState() => _NewRequestState();
}

class _NewRequestState extends State<Cancelled> {
  final scrollController = ScrollController();
  @override
  void initState() {
    final orderProvider = context.read<HospitalBookingProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        orderProvider
          ..clearDataRejected()
          ..getRejectedOrders(
              hospitalId: authProvider.hospitalDataFetched!.id!);
      },
    );
    orderProvider.rejectInit(
        scrollController, authProvider.hospitalDataFetched!.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalBookingProvider>(
        builder: (context, bookingProvider, _) {
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          if (bookingProvider.isLoading == true &&
              bookingProvider.rejectedBookings.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: LoadingIndicater(),
              ),
            )
          else if (bookingProvider.rejectedBookings.isEmpty)
            const SliverFillRemaining(
              child: NoDataImageWidget(text: 'No Cancelled Bookings Found'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: bookingProvider.rejectedBookings.length,
                itemBuilder: (context, index) {
                  final bookings = bookingProvider.rejectedBookings[index];
                  final formattedDate = DateFormat('dd/MM/yyyy')
                      .format(bookings.rejectedAt!.toDate());
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: BColors.darkblue),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(bookings.id!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium!
                                                    .copyWith(
                                                        color: Colors.white)),
                                          ),
                                        ),
                                        Container(
                                          height: 28,
                                          width: 128,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(),
                                              color: BColors.offWhite),
                                          child: Center(
                                            child: Text(
                                              formattedDate,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    DoctorRoundImageNameWidget(
                                      doctorImage:
                                          bookings.selectedDoctor!.doctorImage!,
                                      doctorName:
                                          bookings.selectedDoctor!.doctorName!,
                                      doctorQualification: bookings
                                          .selectedDoctor!.doctorQualification!,
                                      doctorSpecialization: bookings
                                          .selectedDoctor!
                                          .doctorSpecialization!,
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
                                    PatientDetailsContainer(
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
                                    const Gap(10),
                                    bookings.rejectReason == null
                                        ? Center(
                                            child: Text(
                                              'Booking is cancelled by user',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: BColors.red,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        : Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Booking is cancelled by hospital',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: BColors.red,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  'Reject Reason : ${bookings.rejectReason}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: BColors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          )
                                  ]),
                            ))),
                  );
                },
              ),
            )
        ],
      );
    });
  }
}
