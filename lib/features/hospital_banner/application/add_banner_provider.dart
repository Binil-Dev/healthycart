import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/easy_navigation.dart';
import 'package:healthycart/features/hospital_banner/domain/i_banner_facade.dart';
import 'package:healthycart/features/hospital_banner/domain/model/hospital_banner_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddBannerProvider extends ChangeNotifier {
  AddBannerProvider(this.iBannerFacade);
  final IBannerFacade iBannerFacade;

  String? imageUrl;
  File? imageFile;
  HospitalBannerModel? banner;
  List<HospitalBannerModel> bannerList = [];
  bool fetchLoading = false;
  bool saveLoading = false;
  final hospitalId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> getImage() async {
    final result = await iBannerFacade.getImage();
    notifyListeners();
    result.fold((failure) {
      CustomToast.errorToast(text: "Can't able to pick an image.");
    }, (imagefile) {
      imageUrl = null;
      imageFile = imagefile;
      notifyListeners();
      CustomToast.sucessToast(text: "Image picked sucessfully.");
    });
  }

  Future<void> saveImage() async {
    if (imageFile == null) {
      CustomToast.errorToast(text: "Pick an image.");
      return;
    }
    saveLoading = true;
    notifyListeners();
    final result = await iBannerFacade.saveImage(imageFile: imageFile!);

    result.fold((failure) {
      CustomToast.errorToast(text: "Can't able to save image.");
    }, (imageurlSucess) {
      imageUrl = imageurlSucess;
      notifyListeners();
    });
  }

  Future<void> deleteBanner(
      {required HospitalBannerModel bannerToDelete,
      required String imageUrl,
   
      required int index}) async {
    final result =
        await iBannerFacade.deleteHospitalBanner(banner: bannerToDelete);
    result.fold((failure) {
      CustomToast.errorToast(text: "Can't able to remove the banner.");
    }, (sucess) async {
      await iBannerFacade.deleteImage(imageUrl: imageUrl).then((value) {
      });
      bannerList.removeAt(index);
      CustomToast.sucessToast(text: "Banner removed sucessfully.");
      notifyListeners();
    });
  }

  Future<void> addBanner({required BuildContext context}) async {
    banner = HospitalBannerModel(
      isCreated: Timestamp.now(),
      image: imageUrl,
      hospitalId: hospitalId ?? '',
    );
    saveLoading = true;
    notifyListeners();
    final result = await iBannerFacade.addHospitalBanner(banner: banner!);
    result.fold((failure) {
      CustomToast.errorToast(text: "Can't able to save banner");
    }, (model) {
      bannerList.insert(bannerList.length, model);
      clearBannerDetails();
      EasyNavigation.pop(context: context);
    });
    saveLoading = false;
    notifyListeners();
    return;
  }

  Future<void> getBanner() async {
    if (bannerList.isNotEmpty) return;
    fetchLoading = true;
    notifyListeners();
    final result =
        await iBannerFacade.getHospitalBanner(hospitalId: hospitalId ?? '');
    result.fold((failure) {
      log(failure.errMsg);
      CustomToast.errorToast(text: "Couldn't able to get banner");
    }, (bannerlist) {
      bannerList.addAll(bannerlist);
      fetchLoading = false;
      notifyListeners();
    });
  }

  void clearBannerDetails() {
    imageFile = null;
    notifyListeners();
    if (imageUrl != null) {
      imageUrl = null;
    }
    notifyListeners();
  }
}
