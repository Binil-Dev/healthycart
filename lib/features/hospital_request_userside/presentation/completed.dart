import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_request_userside/application/provider/hospital_booking_provider.dart.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/doctor_details_card.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/orderid_date_widget.dart';
import 'package:healthycart/features/hospital_request_userside/presentation/widgets/patient_details_card.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Completed extends StatefulWidget {
  const Completed({super.key});

  @override
  State<Completed> createState() => _NewRequestState();
}

class _NewRequestState extends State<Completed> {
  final scrollController = ScrollController();

  @override
  void initState() {
    final orderProvider = context.read<HospitalBookingProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        orderProvider
          ..cleatDataCompleted()
          ..getCompletedOrders(
              limit: 8, hospitalId: authProvider.hospitalDataFetched!.id!);
      },
    );
    orderProvider.completeInit(
        scrollController, authProvider.hospitalDataFetched!.id!, 5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalBookingProvider>(
        builder: (context, bookingProvider, _) {
      return CustomScrollView(
        slivers: [
          if (bookingProvider.isLoading == true &&
              bookingProvider.completedList.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: LoadingIndicater(),
              ),
            )
          else if (bookingProvider.completedList.isEmpty)
            const SliverFillRemaining(
              child: NoDataImageWidget(text: 'No Completed Bookings Found'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: bookingProvider.completedList.length,
                itemBuilder: (context, index) {
                  final bookings = bookingProvider.completedList[index];
                  final formattedDate = DateFormat('dd/MM/yyyy')
                      .format(bookings.completedAt!.toDate());
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
                                          .selectedDoctor!
                                          .doctorSpecialization!,
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
                                      uhid:  bookings.uhid?? null,
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
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Completed',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: BColors.green,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Gap(5),
                                          Icon(
                                            Icons.check_circle_outline_outlined,
                                            color: BColors.green,
                                          )
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
