import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:healthycart/core/failures/main_failure.dart';
import 'package:healthycart/core/general/firebase_collection.dart';
import 'package:healthycart/core/general/typdef.dart';
import 'package:healthycart/core/services/image_picker.dart';
import 'package:healthycart/features/hospital_doctor/domain/i_doctor_facade.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/add_doctor_model.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/doctor_category_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IDoctorFacade)
class IDoctorImpl implements IDoctorFacade {
  IDoctorImpl(this._firebaseFirestore, this._imageService);
  final FirebaseFirestore _firebaseFirestore;
  final ImageService _imageService;
//// Image section --------------------------
  @override
  FutureResult<File> getImage() async {
    return await _imageService.getGalleryImage();
  }

  @override
  FutureResult<String> saveImage({required File imageFile}) async {
    return await _imageService.saveImage(
        imageFile: imageFile, folderName: 'doctor_image');
  }

  @override
  FutureResult<Unit> deleteImage({
    required String imageUrl,
    required String doctorId,
  }) async {
    try {
      await _imageService.deleteImageUrl(imageUrl: imageUrl).then((value) {
        value.fold((failure) {
          return left(failure);
        }, (sucess) async {
          await _firebaseFirestore
              .collection(FirebaseCollections.doctors)
              .doc(doctorId)
              .update({'doctorImage': null}).then((value) {});
        });
      });
      return right(unit);
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

//////////// add and get category----------------------------------
  @override
  FutureResult<List<DoctorCategoryModel>> getDoctorCategoryAll() async {
    try {
      final snapshot = await _firebaseFirestore
          .collection(FirebaseCollections.doctorcategory)
          .orderBy('isCreated', descending: true)
          .get();
      return right([
        ...snapshot.docs.map(
            (e) => DoctorCategoryModel.fromMap(e.data()).copyWith(id: e.id))
      ]);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

//////////////// getting the list of hospital selected categories here
  @override
  FutureResult<List<DoctorCategoryModel>> getHospitalDoctorCategory({required List<String> categoryIdList}) async {
    try {
      List<Future<DocumentSnapshot<Map<String, dynamic>>>> futures = [];

      for (var element in categoryIdList) {
        futures.add(_firebaseFirestore
            .collection(FirebaseCollections.doctorcategory)
            .doc(element)
            .get());
      }

      List<DocumentSnapshot<Map<String, dynamic>>> results =
          await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(futures);

      final categoryList = results
          .map<DoctorCategoryModel>((e) =>
              DoctorCategoryModel.fromMap(e.data() as Map<String, dynamic>)
                  .copyWith(id: e.id))
          .toList();

      return right(categoryList);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  FutureResult<DoctorCategoryModel> updateHospitalDetails({
    required String? hospitalId,
    required DoctorCategoryModel category,
  }) async {
    try {
      if (hospitalId == null) {
        return left(
            const MainFailure.firebaseException(errMsg: 'check userid'));
      }

      await _firebaseFirestore
          .collection(FirebaseCollections.hospitals)
          .doc(hospitalId)
          .update({
        'selectedCategoryId': FieldValue.arrayUnion([category.id])
      });
      return right(category);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  ///////////delete category----------------------------------
  @override
  FutureResult<DoctorCategoryModel> deleteCategory({
    required String? userId,
    required DoctorCategoryModel category,
  }) async {
    try {
      if (userId == null) {
        return left(
            const MainFailure.firebaseException(errMsg: 'Check user Id'));
      }
      final categoryId = category.id;

      await _firebaseFirestore.collection(FirebaseCollections.hospitals).doc(userId).update({
        'selectedCategoryId': FieldValue.arrayRemove([categoryId])
      });
      return right(category);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  // this is to check if there is data inside the selected category, if yes to inform before the category is deleted.
  @override
  FutureResult<bool> checkDoctorInsideCategory({
    required String categoryId,
    required String hospitalId, // hospital id is the user id
  }) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection(FirebaseCollections.doctors)
          .where('categoryId', isEqualTo: categoryId)
          .where('hospitalId', isEqualTo: hospitalId)
          .get();
      return right(snapshot.docs.isNotEmpty);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  //////////////////////// doctor add section------------------------------------------
  @override
  FutureResult<DoctorAddModel> addDoctorDetails({
    required DoctorAddModel doctorData,
  }) async {
    try {
      final id = _firebaseFirestore.collection(FirebaseCollections.doctors).doc().id;
      doctorData.id = id;
      await _firebaseFirestore
          .collection(FirebaseCollections.doctors)
          .doc(id)
          .set(doctorData.toMap());

      return right(doctorData.copyWith(id: id));
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

/* ----------------------------- GET ALL DOCTORS BY CATEGORY---------------------------- */

  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  bool noMoreData = false;
  @override
  FutureResult<List<DoctorAddModel>> getHospitalCategoryDoctorsDetails({
    required String hospitalId,
    required String categoryId,
    required String? searchText,
  }) async {
    try {
      if (noMoreData) return right([]);
      Query query = _firebaseFirestore
          .collection(FirebaseCollections.doctors)
          .orderBy('createdAt', descending: true)
          .where('categoryId', isEqualTo: categoryId)
          .where('hospitalId', isEqualTo: hospitalId);

      if (searchText != null && searchText.isNotEmpty) {
        query =
            query.where('keywords', arrayContains: searchText.toLowerCase());
      }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }
      final snapshots = await query.limit(6).get();
      if (snapshots.docs.length < 6 || snapshots.docs.isEmpty) {
        noMoreData = true;
      } else {
        lastDoc = snapshots.docs.last as DocumentSnapshot<Map<String, dynamic>>;
      }
      final List<DoctorAddModel> productList = snapshots.docs
          .map((e) =>
              DoctorAddModel.fromMap(e.data() as Map<String, dynamic>)
                  .copyWith(id: e.id))
          .toList();
      return right(productList);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  void clearFetchData() {
    noMoreData = false;
    lastDoc = null;
  }




/* -------------------------------------------------------------------------- */
  // @override
  // FutureResult<List<DoctorAddModel>> getDoctorDetails({
  //   required String categoryId,
  //   required String hospitalId,
  // }) async {
  //   try {
  //     final snapshot = await _firebaseFirestore
  //         .collection(FirebaseCollections.doctors)
  //         .orderBy('createdAt')
  //         .where('categoryId', isEqualTo: categoryId)
  //         .where('hospitalId', isEqualTo: hospitalId)
  //         .get();

  //     return right(snapshot.docs
  //         .map((e) => DoctorAddModel.fromMap(e.data()).copyWith(id: e.id))
  //         .toList());
  //   } on FirebaseException catch (e) {
  //     return left(MainFailure.firebaseException(errMsg: e.message.toString()));
  //   } catch (e) {
  //     return left(MainFailure.generalException(errMsg: e.toString()));
  //   }
  // }

  @override
  FutureResult<DoctorAddModel> deleteDoctorDetails({
    required String doctorId,
    required DoctorAddModel doctorData,
  }) async {
    try {
      await _imageService
          .deleteImageUrl(imageUrl: doctorData.doctorImage)
          .then((value) async{
          await _firebaseFirestore
          .collection(FirebaseCollections.doctors)
          .doc(doctorId)
          .delete();
          });


      return right(doctorData);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  FutureResult<DoctorAddModel> updateDoctorDetails({
    required String doctorId,
    required DoctorAddModel doctorData,
  }) async {
    try {
      await _firebaseFirestore
          .collection(FirebaseCollections.doctors)
          .doc(doctorId)
          .update(doctorData.toMap());

      return right(doctorData);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }
}
