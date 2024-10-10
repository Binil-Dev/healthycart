import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthycart/core/custom/keyword_builder/keyword_builder.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/model/hospital_model.dart';
import 'package:healthycart/features/hospital_doctor/domain/i_doctor_facade.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/add_doctor_model.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/doctor_category_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class DoctorProvider extends ChangeNotifier {
  DoctorProvider(this._iDoctorFacade);
  final IDoctorFacade _iDoctorFacade;
/////////////////////////////////////

  ///////////////////////
  ///Image section ---------------------------
  String? imageUrl;
  File? imageFile;
  bool fetchLoading = false;
  bool fetchAlertLoading = false;
  bool onTapBool = false;

  void onTapEditButton() {
    // to change to long press and ontap
    onTapBool = !onTapBool;
    notifyListeners();
  }

  Future<void> getImage({String? doctorId}) async {
    final result = await _iDoctorFacade.getImage();
    notifyListeners();
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
    }, (imageFilesucess) async {
      if (imageUrl != null && doctorId != null) {
        await _iDoctorFacade.deleteImage(
            imageUrl: imageUrl ?? '', doctorId: doctorId);
        imageUrl = null;
      } // when editing  this will make the url null when we pick a new file
      imageFile = imageFilesucess;
      notifyListeners();
    });
  }

  Future<void> saveImage() async {
    if (imageFile == null) {
      CustomToast.errorToast(text: 'Please check the image selected.');
      return;
    }
    fetchLoading = true;

    /// fetch loading is true because I am using this function along with add function
    notifyListeners();
    final result = await _iDoctorFacade.saveImage(imageFile: imageFile!);
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
    }, (imageurlGet) {
      imageUrl = imageurlGet;
      notifyListeners();
    });
  }

//////////////////////////
  /// adding category -----------------------------------------
  ///
  /// radio button
  DoctorCategoryModel? selectedRadioButtonCategoryValue;
  void selectedRadioButton({
    required DoctorCategoryModel result,
  }) {
    selectedRadioButtonCategoryValue = result;
    notifyListeners();
  }

  List<DoctorCategoryModel> doctorCategoryAllList = [];
  List<String> doctorCategoryIdList =
      []; // to get id of category from the doctors list
  List<DoctorCategoryModel> doctorCategoryList = [];
  DoctorCategoryModel? doctorCategory;
  List<DoctorCategoryModel> doctorCategoryUniqueList = [];
////getting category of doctor from admin side
  Future<void> getDoctorCategoryAll() async {
    if (doctorCategoryAllList.isNotEmpty) return;
    fetchAlertLoading = true;
    notifyListeners();
    final result = await _iDoctorFacade.getDoctorCategoryAll();
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to fetch category");
      fetchLoading = false;
      notifyListeners();
    }, (categoryAllList) {
      doctorCategoryAllList.addAll(categoryAllList);
      doctorCategoryUniqueList.addAll(doctorCategoryAllList);
    });
    fetchAlertLoading = false;
    notifyListeners();
  }

  Future<void> getHospitalDoctorCategory() async {
    if (doctorCategoryList.isNotEmpty) return;
    fetchLoading = true;
    notifyListeners();
    final result = await _iDoctorFacade.getHospitalDoctorCategory(
        categoryIdList: doctorCategoryIdList);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to fetch category");
      fetchLoading = false;
      notifyListeners();
    }, (categoryList) {
      doctorCategoryList.addAll(categoryList);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void removingFromUniqueCategoryList() {
    for (var element in doctorCategoryList) {
      // removing selected category
      doctorCategoryUniqueList.removeWhere((cat) {
        return cat.id == element.id;
      });
      notifyListeners();
    }
  }

  /// update the category in hospital model
  Future<void> updateCategory(
      {required DoctorCategoryModel categorySelected,
      required String hospitalId}) async {
    final result = await _iDoctorFacade.updateHospitalDetails(
        hospitalId: hospitalId, category: categorySelected);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to update category");
    }, (categorymodel) {
      doctorCategoryList.insert(doctorCategoryList.length, categorymodel);
      removingFromUniqueCategoryList();
      notifyListeners();
    });
    return;
  }

///////////////////////
//////// Deleting doctor category-----------------------
  Future<void> deleteCategory(
      {required int index, required DoctorCategoryModel category}) async {
    // check if there is any doctors inside category that is going to be deleted
    final boolResult = await _iDoctorFacade.checkDoctorInsideCategory(
        categoryId: category.id ?? 'No categoryId',
        hospitalId: hospitalId ?? ' No hospital Id is here..');
    boolResult.fold((failure) {
      CustomToast.errorToast(text: "Something went wrong,please try again");
    }, (sucess) async {
      if (sucess) {
        CustomToast.errorToast(
            text: "Can't delete, there is doctor's list inside");
      } else {
        final result = await _iDoctorFacade.deleteCategory(
            userId: hospitalId!, category: category);
        result.fold((failure) {
          CustomToast.errorToast(
              text: "Can't able to delete the category,please try again.");
        }, (category) {
          doctorCategoryList.removeAt(index);
          doctorCategoryUniqueList.add(category);
          CustomToast.sucessToast(text: 'Sucessfully removed.');
          notifyListeners();
        });
      }
    });
  }

/////////////////////////////////////////////
//        Doctor  Section---------------------------------
  String? hospitalId =
      FirebaseAuth.instance.currentUser?.uid; // user id and hospital id is same
  String? categoryId;

  /// these both are used in the category also to check wheather the user
  String? selectedDoctorCategoryText;

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(); // formkey for the user
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController doctorFeeController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController aboutDoctorController = TextEditingController();
  String? timeSlotListElement1;
  String? timeSlotListElement2;
  String? availableTotalTimeSlot1;
  String? availableTotalTimeSlot2;
  String? availableTotalTime;
  DateTime? timeSlot1;
  DateTime? timeSlot2;
  List<String>? timeSlotListElementList = [];
// adding the userId/hospital and categoryId
  void selectedCategoryDetail({
    required String catId,
    required String catName,
  }) {
    categoryId = catId;
    selectedDoctorCategoryText = catName;
    specializationController.text =
        selectedDoctorCategoryText ?? 'No category selected';
    notifyListeners();
  }

  ///setting total time slot
  void totalAvailableTimeSetter(String time) {
    availableTotalTime = time;
    notifyListeners();
  }

// setting available time slot
  void addTimeslot() {
    if (timeSlotListElement1 != null && timeSlotListElement2 != null) {
      timeSlotListElementList!
          .add('$timeSlotListElement1 - $timeSlotListElement2');
      timeSlotListElement1 = null;
      timeSlotListElement2 = null;
      notifyListeners();
    } else {
      CustomToast.errorToast(text: 'Select both start and end time');
      notifyListeners();
    }
  }

// removing timeslot from the list
  void removeTimeSlot(int index) {
    timeSlotListElementList!.removeAt(index);
    notifyListeners();
  }

  ///////////////////////////////////// 1.)  Adding doctor----------
  ///
  HospitalModel? hospitalData;
  List<DoctorAddModel> doctorList = [];
  DoctorAddModel? doctorDetails;
  List<DoctorAddModel> doctorData = [];

  Future<void> addDoctorDetail({
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    doctorDataList();
    final result =
        await _iDoctorFacade.addDoctorDetails(doctorData: doctorDetails!);
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to add doctor, please try again.");
      EasyNavigation.pop(context: context);
    }, (doctorReturned) {
      CustomToast.sucessToast(text: "Added doctor sucessfully");
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
      doctorList.insert(0, doctorReturned);
      clearDoctorDetails();
      notifyListeners();
    });
    fetchLoading = false;
    notifyListeners();
  }

  List<String> keywordDoctorBuilder() {
    List<String> combinedKeyWords = [];
    combinedKeyWords.addAll(keywordsBuilder(doctorNameController.text));
    combinedKeyWords.addAll(keywordsBuilder(specializationController.text));
    return combinedKeyWords;
  }

  void doctorDataList() {
    doctorDetails = DoctorAddModel(
      categoryId: categoryId,
      hospitalId: hospitalId,
      doctorImage: imageUrl,
      doctorName: doctorNameController.text,
      doctorTotalTime: availableTotalTime,
      doctorTimeList: timeSlotListElementList,
      doctorFee: int.parse(doctorFeeController.text),
      doctorSpecialization: specializationController.text,
      doctorExperience: int.parse(experienceController.text),
      doctorQualification: qualificationController.text,
      doctorAbout: aboutController.text,
      createdAt: Timestamp.now(),
      keywords: keywordDoctorBuilder(),
      hospital: hospitalData?.hospitalName ?? '',
      placemark: hospitalData?.placemark,
    );
    notifyListeners();
  }

  void clearDoctorDetails() {
    imageFile = null;
    timeSlot1 = null;
    timeSlot2 = null;
    availableTotalTimeSlot2 = null;
    availableTotalTimeSlot1 = null;
    availableTotalTime = null;
    doctorNameController.clear();
    doctorFeeController.clear();
    experienceController.clear();
    qualificationController.clear();
    aboutController.clear();
    timeSlotListElementList?.clear();
    if (imageUrl != null) {
      imageUrl = null;
    }
    notifyListeners();
  }

  ///////////////// 2.)  Getting doctor details according to the category and user-------
  /* ----------------------------- GET ALL DOCTORS BY CATEGORY ---------------------------- */
  final TextEditingController searchController = TextEditingController();

  Future<void> getHospitalCategoryDoctorsDetails({String? searchText}) async {
    fetchLoading = true;
    notifyListeners();
    final result = await _iDoctorFacade.getHospitalCategoryDoctorsDetails(
        categoryId: categoryId!,
        hospitalId: hospitalId ?? '',
        searchText: searchText);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to show doctor");
    }, (products) {
      doctorList.addAll(products); //// here we are assigning the doctor
    });
    fetchLoading = false;
    notifyListeners();
  }

  void clearFetchData() {
    searchController.clear();
    doctorList.clear();
    _iDoctorFacade.clearFetchData();
  }

  void searchCategoryDoctors(String searchText) {
    doctorList.clear();
    _iDoctorFacade.clearFetchData();
    getHospitalCategoryDoctorsDetails(searchText: searchText);
    notifyListeners();
  }
  /* -------------------------------------------------------------------------- */

/////////////////////////// 3.) deleting the doctor field

  Future<void> deleteDoctorDetails(
      {required int index, required DoctorAddModel doctorData}) async {
    final result = await _iDoctorFacade.deleteDoctorDetails(
        doctorId: doctorData.id ?? '', doctorData: doctorData);
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to delete doctor details, please try again.");
    }, (doctorsData) {
      CustomToast.sucessToast(text: "Removed doctor sucessfully");
      doctorList.removeAt(index); //// here we are assigning the doctor
    });
    notifyListeners();
  }

/////////////////////////// 3.) update the doctor field
  void setDoctorEditData({required DoctorAddModel doctorEditData}) {
    imageUrl = doctorEditData.doctorImage;
    doctorNameController.text = doctorEditData.doctorName ?? 'Unknown Name';
    availableTotalTime = doctorEditData.doctorTotalTime;
    timeSlotListElementList = doctorEditData.doctorTimeList;
    doctorFeeController.text = doctorEditData.doctorFee.toString();
    specializationController.text =
        doctorEditData.doctorSpecialization ?? 'Unknown Specialization';
    experienceController.text = doctorEditData.doctorExperience.toString();
    qualificationController.text =
        doctorEditData.doctorQualification ?? 'Unknown qualification';
    aboutController.text = doctorEditData.doctorAbout ?? 'Unknown About';
    notifyListeners();
  }

  Future<void> updateDoctorDetails({
    required int index,
    required DoctorAddModel doctorData,
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    doctorDetails = DoctorAddModel(
      id: doctorData.id,
      categoryId: doctorData.categoryId,
      hospitalId: doctorData.hospitalId,
      doctorImage: imageUrl,
      doctorName: doctorNameController.text,
      doctorTotalTime: availableTotalTime,
      doctorTimeList: timeSlotListElementList,
      doctorFee: int.parse(doctorFeeController.text),
      doctorSpecialization: specializationController.text,
      doctorExperience: int.parse(experienceController.text),
      doctorQualification: qualificationController.text,
      doctorAbout: aboutController.text,
      createdAt: doctorData.createdAt,
      keywords: keywordDoctorBuilder(),
      hospital: hospitalData?.hospitalName ?? '',
      placemark: hospitalData?.placemark,
    );
    final result = await _iDoctorFacade.updateDoctorDetails(
        doctorId: doctorData.id ?? '', doctorData: doctorDetails!);
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to update doctor details, please try again.");
      EasyNavigation.pop(context: context);
    }, (doctorsData) {
      CustomToast.sucessToast(text: "Updated doctor details sucessfully");
      doctorList[index] = doctorsData; //// here we are assigning the doctor
      clearDoctorDetails();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
      notifyListeners();
    });
    fetchLoading = false;
    notifyListeners();
  }
}
