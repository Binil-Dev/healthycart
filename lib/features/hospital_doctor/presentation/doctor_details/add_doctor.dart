// ignore_for_file: use_build_context_synchronously
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart/core/custom/custom_button_n_search/common_button.dart';
import 'package:healthycart/core/custom/custom_button_n_search/search_field_button.dart';
import 'package:healthycart/core/custom/lottie/circular_loading.dart';
import 'package:healthycart/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart/features/hospital_doctor/application/doctor_provider.dart';
import 'package:healthycart/features/hospital_doctor/presentation/doctor_details/widgets/add_doctor_bottomsheet.dart';
import 'package:healthycart/features/hospital_doctor/presentation/doctor_details/widgets/details_doctor_container.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';
import '../../../../core/custom/app_bar/sliver_appbar.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final ScrollController _scrollcontroller = ScrollController();
  @override
  void initState() {
    final doctorProvider = context.read<DoctorProvider>();
  
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
   doctorProvider.hospitalData  =   context.read<AuthenticationProvider>().hospitalDataFetched;
      doctorProvider.clearFetchData();
      doctorProvider.getHospitalCategoryDoctorsDetails();
    });

    _scrollcontroller.addListener(() {
      if (_scrollcontroller.position.atEdge &&
          _scrollcontroller.position.pixels != 0 &&
          doctorProvider.fetchLoading == false) {
        doctorProvider.getHospitalCategoryDoctorsDetails();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    EasyDebounce.cancel('searchdoctors');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popup = PopUpAddDoctorBottomSheet.instance;
    return Scaffold(
      body: Consumer<DoctorProvider>(builder: (context, doctorProvider, _) {
        return CustomScrollView(
          slivers: [
            SliverCustomAppbar(
              title: doctorProvider.selectedDoctorCategoryText ?? '',
              onBackTap: () {
                EasyNavigation.pop(context: context);
              },
              child: PreferredSize(
                preferredSize: const Size(double.infinity, 68),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 8, top: 4),
                  child: SearchTextFieldButton(
                    text: "Search Doctors",
                    controller: doctorProvider.searchController,
                    onChanged: (value) {
                      EasyDebounce.debounce(
                          'searchdoctors', const Duration(milliseconds: 500),
                          () {
                        doctorProvider.searchCategoryDoctors(value);
                      });
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Doctors List",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: CustomButton(
                  width: 160,
                  height: 48,
                  onTap: () {
                    popup.showBottomSheet(
                        context:
                            context, //// adding nag in new doctor adding form from here
                        addImageTap: () async {
                          await doctorProvider.getImage();
                        },
                        saveButtonTap: () async {
                          if (doctorProvider.imageFile == null) {
                            CustomToast.errorToast(
                                text: "Pick an image of doctor");

                            return;
                          }
                            if (doctorProvider.availableTotalTimeSlot1 ==
                                        null ||
                                    doctorProvider.availableTotalTimeSlot2 ==
                                        null) {
                                  CustomToast.errorToast(
                                      text:
                                          'No total available time slot is added');
                                  return;
                                }
                                if (doctorProvider
                                    .timeSlotListElementList!.isEmpty) {
                                  CustomToast.errorToast(
                                      text: 'No available time slot is added');
                                  return;
                                }
                
                          if (!doctorProvider.formKey.currentState!
                              .validate()) {
                            doctorProvider.formKey.currentState!.validate();
                            return;
                          }

                          LoadingLottie.showLoading(
                              context: context, text: 'Please wait...');

                          await doctorProvider.saveImage().then((value) async {
                            await doctorProvider.addDoctorDetail(
                                context: context);
                          });
                        });
                  },
                  text: 'Add Doctor',
                  buttonColor: BColors.darkblue,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: BColors.white, fontWeight: FontWeight.w500),
                  icon: Icons.add,
                  iconColor: BColors.white,
                ),
              ),
            ),
            if (doctorProvider.fetchLoading &&
                doctorProvider.doctorList.isEmpty)

              /// loading is done here
              const SliverFillRemaining(
                child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0), child: LoadingIndicater()),
                ),
              )
            else if (doctorProvider.doctorList.isEmpty)
              const ErrorOrNoDataPage(
                text: "No Doctors added to this category.",
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: (doctorProvider.doctorList.length),
                  itemBuilder: (context, index) {
                    final doctorListData = doctorProvider.doctorList[index];
                    return Column(
                      children: [
                        DoctorDetailsViewContainerWidget(
                          doctorListData: doctorListData,
                          editButton: () {
                            doctorProvider.setDoctorEditData(
                                doctorEditData: doctorListData);
                            popup.showBottomSheet(
                                context:
                                    context, //// adding nag in new doctor adding form from here
                                addImageTap: () async {
                                  await doctorProvider.getImage(
                                      doctorId: doctorListData.id);
                                },
                                saveButtonTap: () async {
                                  if (doctorProvider.imageFile == null &&
                                      doctorProvider.imageUrl == null) {
                                    CustomToast.errorToast(
                                        text: "Pick an image of doctor");
                                    return;
                                  }
                                  if (doctorProvider
                                          .timeSlotListElementList!.isEmpty ||
                                      doctorProvider.availableTotalTime ==
                                          null) {
                                    CustomToast.errorToast(
                                        text:
                                            'No available time slot is added');
                                    return;
                                  }
                                  if (!doctorProvider.formKey.currentState!
                                      .validate()) {
                                    doctorProvider.formKey.currentState!
                                        .validate();
                                    return;
                                  }

                                  LoadingLottie.showLoading(
                                      context: context,
                                      text: 'Editing doctor details...');

                                  if (doctorProvider.imageUrl == null) {
                                    await doctorProvider.saveImage();
                                  }

                                  await doctorProvider.updateDoctorDetails(
                                      context: context,
                                      index: index,
                                      doctorData: doctorListData);
                                });
                          },
                          deleteButton: () {
                            LoadingLottie.showLoading(
                                context: context, text: 'Please wait ...');
                            doctorProvider
                                .deleteDoctorDetails(
                                    index: index, doctorData: doctorListData)
                                .then((value) {
                              EasyNavigation.pop(context: context);
                            });
                          },
                        ), // consumer/ provider data is passed here
                        const Gap(12)
                      ],
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
                child: (doctorProvider.fetchLoading == true &&
                        doctorProvider.doctorList.isNotEmpty)
                    ? const Center(child: LoadingIndicater())
                    : null),
          ],
        );
      }),
    );
  }
}
