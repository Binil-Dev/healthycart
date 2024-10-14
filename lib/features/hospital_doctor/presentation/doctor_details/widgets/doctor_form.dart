import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/divider/divider.dart';
import 'package:healthycart/core/custom/text_formfield/textformfield.dart';
import 'package:healthycart/core/general/validator.dart';
import 'package:healthycart/features/add_hospital_form_page/presentation/widgets/text_above_form_widdget.dart';
import 'package:healthycart/features/hospital_doctor/application/doctor_provider.dart';
import 'package:healthycart/features/hospital_doctor/presentation/doctor_details/widgets/add_circular_image.dart';
import 'package:healthycart/features/hospital_doctor/presentation/doctor_details/widgets/doctor_timeslot_selector.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

class DoctorAddForm extends StatelessWidget {
  const DoctorAddForm({
    super.key,
    required this.addImageTap,
    required this.saveButtonTap,
  });
  final VoidCallback addImageTap;
  final VoidCallback saveButtonTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorProvider>(builder: (context, value, _) {
      return PopScope(
        onPopInvoked: (didPop) {
          value.clearDoctorDetails();
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: 640,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: (value.imageFile == null &&
                                      value.imageUrl == null)
                                  ? CircularAddImageWidget(
                                      addTap: addImageTap,
                                      iconSize: 48,
                                      height: 120,
                                      width: 120,
                                      radius: 120)
                                  : (value.imageFile != null)
                                      ? GestureDetector(
                                          onTap: addImageTap,
                                          child: CircleAvatar(
                                            radius: 80,
                                            backgroundImage: FileImage(
                                              value.imageFile!,
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: addImageTap,
                                          child: CircleAvatar(
                                            radius: 80,
                                            backgroundImage: NetworkImage(
                                              value.imageUrl!,
                                            ),
                                          ),
                                        ),
                            ),
                            const Gap(15),
                            const DividerWidget(text: 'Tap above to add photo'),
                            const Gap(24),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Form(
                                      key: value.formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //doctor Name
                                          const TextAboveFormFieldWidget(
                                            text: "Doctor Name",
                                          ),

                                          TextfieldWidget(
                                            hintText:
                                                'Enter the name eg: Dr Meenakshi',
                                            validator: BValidator.validate,
                                            controller:
                                                value.doctorNameController,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontSize: 15,
                                                ),
                                          ),

                                          const Gap(8),

                                          const TextAboveFormFieldWidget(
                                            text: "Total time available",
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TimePickerSpinnerPopUp(
                                                cancelTextStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                confirmTextStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                iconSize: 24,
                                                timeFormat: 'hh:mm a',
                                                use24hFormat: false,
                                                mode: CupertinoDatePickerMode
                                                    .time,
                                                initTime: value.timeSlot1?? DateTime.now(),
                                                onChange: (dateTime) {
                                                  value.timeSlot1 = dateTime;
                                                  value.availableTotalTimeSlot1 =
                                                      DateFormat.jm()
                                                          .format(dateTime);

                                                  value.totalAvailableTimeSetter(
                                                      '${value.availableTotalTimeSlot1 ?? '"please add start time"'} - ${value.availableTotalTimeSlot2 ?? '"please add end time"'}');
                                                },
                                              ),
                                              Text(
                                                '-',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge,
                                              ),
                                              TimePickerSpinnerPopUp(
                                                cancelTextStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                confirmTextStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                iconSize: 24,
                                                timeFormat: 'hh:mm a',
                                                use24hFormat: false,
                                                mode: CupertinoDatePickerMode
                                                    .time,
                                                initTime:value.timeSlot2?? DateTime.now(),
                                                onChange: (dateTime) {
                                                  value.timeSlot2 = dateTime;
                                                  value.availableTotalTimeSlot2 =
                                                      DateFormat.jm()
                                                          .format(dateTime);
                                                  value.totalAvailableTimeSetter(
                                                      '${value.availableTotalTimeSlot1 ?? '"please add start time"'} - ${value.availableTotalTimeSlot2 ?? '"please add end time"'}');
                                                },
                                              ),
                                            ],
                                          ),
                                          const Gap(8),
                                          if (value.availableTotalTime != null)
                                            Column(
                                              children: [
                                                const Gap(8),
                                                ListTile(
                                                  tileColor:
                                                      BColors.mainlightColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  title: Center(
                                                    child: Text(
                                                      value.availableTotalTime ??
                                                          'No time added',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          const Gap(8),
                                          const TextAboveFormFieldWidget(
                                            text: "Add available time slots",
                                          ),
                                          const TimeSlotChooserWidget(),
                                          ///////////hereeeeee
                                          const Gap(8),

                                          const TextAboveFormFieldWidget(
                                            text: "Doctor Fee",
                                          ),
                                          TextfieldWidget(
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.next,
                                              prefixText: "₹",    
                                            hintText:
                                                'Enter the amount in rupees eg: 250 ',
                                            validator: BValidator.validate,
                                            controller:
                                                value.doctorFeeController,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontSize: 15,
                                                ),
                                          ),
                                          const Gap(8),

                                          const TextAboveFormFieldWidget(
                                            text: "Experience",
                                          ),
                                          TextfieldWidget(
                                            keyboardType: TextInputType.number,
                                            hintText:
                                                'Enter the years of experience eg: 5',
                                            validator: BValidator.validate,
                                            controller:
                                                value.experienceController,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontSize: 15,
                                                ),
                                          ),
                                          const Gap(8),

                                          const TextAboveFormFieldWidget(
                                            text: "Specialization",
                                          ),
                                          TextfieldWidget(
                                            readOnly: true,
                                            hintText:
                                                'Enter the area of specialization',
                                            validator: BValidator.validate,
                                            controller:
                                                value.specializationController,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontSize: 15,
                                                ),
                                          ),

                                          const Gap(8),

                                          const TextAboveFormFieldWidget(
                                            text: "Qualification",
                                          ),
                                          TextfieldWidget(
                                            textInputAction:
                                                TextInputAction.next,
                                            hintText:
                                                'Enter the qualification eg: MBBS,FRCS, etc...',
                                            validator: BValidator.validate,
                                            controller:
                                                value.qualificationController,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontSize: 15,
                                                ),
                                          ),
                                          const Gap(8),

                                          const TextAboveFormFieldWidget(
                                            text: "About doctor",
                                          ),
                                          TextfieldWidget(
                                            textInputAction:
                                                TextInputAction.done,
                                            maxlines: 5,
                                            hintText:
                                                'Enter the about the doctor.',
                                            validator: BValidator.validate,
                                            controller: value.aboutController,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontSize: 15,
                                                ),
                                          ),
                                          const Gap(15),
                                        ],
                                      )),
                                  const Gap(12),
                                  SizedBox(
                                    height: 48,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: saveButtonTap,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: BColors.darkblue,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15))),
                                      child: (value.fetchLoading)
                                          ? const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 4,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Save',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                    ),
                                  ),
                                ]),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
