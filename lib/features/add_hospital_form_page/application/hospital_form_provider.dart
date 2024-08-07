import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:healthycart/core/custom/keyword_builder/keyword_builder.dart';
import 'package:healthycart/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/failures/main_failure.dart';
import 'package:healthycart/core/general/typdef.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/i_form_facade.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/model/hospital_model.dart';
import 'package:healthycart/features/home/presentation/home.dart';
import 'package:healthycart/features/location_picker/presentation/location.dart';
import 'package:healthycart/utils/constants/enums.dart';
import 'package:injectable/injectable.dart';
import 'package:page_transition/page_transition.dart';

@injectable
class HosptialFormProvider extends ChangeNotifier {
  HosptialFormProvider(this._iFormFeildFacade);
  final IFormFeildFacade _iFormFeildFacade;

//Image section
  String? imageUrl;
  File? imageFile;
  bool fetchLoading = false;

  Future<void> getImage() async {
    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;

    final result = await _iFormFeildFacade.getImage();
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (imageFilesucess) async {
      if (imageUrl != null) {
        await _iFormFeildFacade.deleteImage(
            imageUrl: imageUrl!, hospitalId: hospitalId ?? '');
        imageUrl = null;
      } // when editing  this will make the url null when we pick a new file
      imageFile = imageFilesucess;
      notifyListeners();
    });
  }

  Future<void> saveImage() async {
    if (imageFile == null && imageUrl == null) {
      CustomToast.errorToast(text: 'Please check the image selected.');
      return;
    }
    final result = await _iFormFeildFacade.saveImage(imageFile: imageFile!);
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
    }, (imageurlGet) {
      imageUrl = imageurlGet;
      notifyListeners();
    });
  }

  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController hospitalEmailController = TextEditingController();
  List<String> keywordHospitalBuider() {
    return keywordsBuilder(hospitalNameController.text);
  }

  HospitalModel? hospitalDetail;
  Placemark? placemark;
  AdminType? adminType;
  Future<void> addHospitalForm({
    required BuildContext context,
  }) async {
    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;

    keywordHospitalBuider();
    hospitalDetail = HospitalModel(
      id: hospitalId,
      createdAt: Timestamp.now(),
      keywords: keywordHospitalBuider(),
      phoneNo: phoneNumberController.text,
      hospitalName: hospitalNameController.text,
      address: addressController.text,
      ownerName: ownerNameController.text,
      email: hospitalEmailController.text,
      uploadLicense: pdfUrl,
      image: imageUrl,
      adminType: adminType,
      isActive: true,
      ishospitalON: null,
      requested: 1,
    );

    final result = await _iFormFeildFacade.addHospitalDetails(
      hospitalDetails: hospitalDetail!,
      hospitalId: hospitalId!,
    );
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      Navigator.pop(context);
    }, (sucess) {
      clearAllData();
      CustomToast.sucessToast(text: sucess);
      Navigator.pop(context);
      EasyNavigation.pushReplacement(
        type: PageTransitionType.bottomToTop,
        context: context,
        page: const LocationPage(),
      );
      notifyListeners();
    });
  }

  void clearAllData() {
    hospitalNameController.clear();
    addressController.clear();
    adminType = null;
    pdfFile = null;
    pdfUrl = null;
    imageFile = null;
    imageUrl = null;
    phoneNumberController.clear();
    ownerNameController.clear();
    hospitalEmailController.clear();
    notifyListeners();
  }

/////////////////////////// pdf-----------
  ///

  File? pdfFile;
  String? pdfUrl;

  Future<void> getPDF({required BuildContext context}) async {
    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;

    final result = await _iFormFeildFacade.getPDF();
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (pdfFileSucess) async {
      LoadingLottie.showLoading(
          context: context, text: 'Uploading document...');
      if (pdfUrl != null) {
        await _iFormFeildFacade.deletePDF(
            pdfUrl: pdfUrl ?? '', hospitalId: hospitalId ?? '');
        pdfUrl = null;
      }
      pdfFile = pdfFileSucess;

      await savePDF().then((value) {
        // save PDF function is called here......
        value.fold((failure) {
          EasyNavigation.pop(context: context);
          notifyListeners();
          return CustomToast.errorToast(text: failure.errMsg);
        }, (pdfUrlSucess) {
          pdfUrl = pdfUrlSucess;
          EasyNavigation.pop(context: context);
          notifyListeners();
          return CustomToast.sucessToast(text: 'PDF Added Sucessfully');
        });
      });
    });
  }

  FutureResult<String?> savePDF() async {
    if (pdfFile == null) {
      return left(const MainFailure.generalException(
          errMsg: 'Please check the PDF selected.'));
    }
    final result = await _iFormFeildFacade.savePDF(pdfFile: pdfFile!);
    return result;
  }

  Future<void> deletePDF() async {
    if ((pdfUrl ?? '').isEmpty) {
      pdfFile = null;
      pdfUrl = null;
      CustomToast.errorToast(text: 'PDF removed.');
      notifyListeners();
      return;
    }
    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;

    final result = await _iFormFeildFacade.deletePDF(
        pdfUrl: pdfUrl ?? '', hospitalId: hospitalId ?? '');
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (sucess) {
      pdfFile = null;
      pdfUrl = null;
      CustomToast.sucessToast(text: sucess!);
      notifyListeners();
    });
  }

  ///edit data from the profile section
  void setEditData(HospitalModel hospitalDetailsEdit) {
    hospitalNameController.text = hospitalDetailsEdit.hospitalName ?? '';
    addressController.text = hospitalDetailsEdit.address ?? '';
    phoneNumberController.text = hospitalDetailsEdit.phoneNo ?? '';
    ownerNameController.text = hospitalDetailsEdit.ownerName ?? '';
    hospitalEmailController.text = hospitalDetailsEdit.email ?? '';
    pdfUrl = hospitalDetailsEdit.uploadLicense;
    imageUrl = hospitalDetailsEdit.image;
    notifyListeners();
  }

  Future<void> updateHospitalForm({
    required BuildContext context,
  }) async {
    keywordHospitalBuider();
    hospitalDetail = HospitalModel(
      keywords: keywordHospitalBuider(),
      phoneNo: phoneNumberController.text,
      hospitalName: hospitalNameController.text,
      address: addressController.text,
      ownerName: ownerNameController.text,
      email: hospitalEmailController.text,
      uploadLicense: pdfUrl,
      image: imageUrl,
    );
    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;

    final result = await _iFormFeildFacade.updateHospitalForm(
        hospitalDetails: hospitalDetail!, hospitalId: hospitalId!);

    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      EasyNavigation.pop(context: context);
    }, (sucess) {
      clearAllData();
      CustomToast.sucessToast(text: 'Sucessfully updated details.');
      EasyNavigation.pop(context: context);
      EasyNavigation.pushReplacement(
        type: PageTransitionType.bottomToTop,
        context: context,
        page: const HomeScreen(),
      );
      // when edited moving back to the profile screen
      notifyListeners();
    });
  }
}
