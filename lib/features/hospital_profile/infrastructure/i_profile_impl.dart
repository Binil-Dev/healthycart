import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:healthycart/core/failures/main_failure.dart';
import 'package:healthycart/core/general/firebase_collection.dart';
import 'package:healthycart/core/general/typdef.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/model/hospital_model.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/add_doctor_model.dart';
import 'package:healthycart/features/hospital_profile/domain/i_profile_facade.dart';
import 'package:healthycart/features/hospital_profile/domain/models/transaction_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IProfileFacade)
class IProfileImpl implements IProfileFacade {
  IProfileImpl(this._firebaseFirestore);
  final FirebaseFirestore _firebaseFirestore;

/* ----------------------------- GET ALL DOCTORS ---------------------------- */

  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  bool noMoreData = false;
  @override
  FutureResult<List<DoctorAddModel>> getHospitalAllDoctorDetails({
    required String hospitalId,
    required String? searchText,
  }) async {
    try {
      if (noMoreData) return right([]);
      Query query = _firebaseFirestore
          .collection(FirebaseCollections.doctors)
          .orderBy('createdAt', descending: true)
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
          .map((e) => DoctorAddModel.fromMap(e.data() as Map<String, dynamic>)
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

  @override
  FutureResult<String> setActiveHospital({
    required bool ishospitalON,
    required String hospitalId,
  }) async {
    final batch = _firebaseFirestore.batch();

    try {
      batch.update(
          _firebaseFirestore
              .collection(FirebaseCollections.hospitals)
              .doc(hospitalId),
          {'ishospitalON': ishospitalON});

      if (ishospitalON == true) {
        batch.update(
            _firebaseFirestore
                .collection(FirebaseCollections.counts)
                .doc('htfK5JIPTaZVlZi6fGdZ'),
            {
              'activeHospitals': FieldValue.increment(1),
              'inActiveHospitals': FieldValue.increment(-1)
            });
      } else {
        batch.update(
            _firebaseFirestore
                .collection(FirebaseCollections.counts)
                .doc('htfK5JIPTaZVlZi6fGdZ'),
            {
              'activeHospitals': FieldValue.increment(-1),
              'inActiveHospitals': FieldValue.increment(1)
            });
      }

      await batch.commit();

      return right('Hospital status changed.');
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.code));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  DocumentSnapshot<Map<String, dynamic>>? transactionLastDoc;
  bool transactionNoMoreData = false;
  @override
  FutureResult<List<TransferTransactionsModel>> getAdminTransactionList(
      {required String hospitalId}) async {
    if (noMoreData) return right([]);

    int limit = lastDoc == null ? 15 : 8;
    try {
      Query query = _firebaseFirestore
          .collection(FirebaseCollections.hospitalTransactions)
          .doc(hospitalId)
          .collection(FirebaseCollections.hospitalTransactionSubCollection)
          .orderBy('dateAndTime', descending: true);

      // if (search != null && search.isNotEmpty) {
      //   query = query.where('keywords', arrayContains: search.toLowerCase());
      // }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }
      final result = await query.limit(limit).get();

      if (result.docs.length < limit || result.docs.isEmpty) {
        noMoreData = true;
      } else {
        lastDoc = result.docs.last as DocumentSnapshot<Map<String, dynamic>>;
      }

      final transactionList = result.docs
          .map((e) => TransferTransactionsModel.fromMap(
              e.data() as Map<String, dynamic>))
          .toList();

      return right(transactionList);
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  void clearTransactionData() {
    transactionLastDoc = null;
    transactionNoMoreData = false;
  }

  @override
  FutureResult<String> addBankDetails(
      {required HospitalModel bankDetails, required String hospitalId}) async {
    try {
      await _firebaseFirestore
          .collection(FirebaseCollections.hospitals)
          .doc(hospitalId)
          .update(bankDetails.toBankDetailsMap());
      return right('Bank Details Updated Successfully');
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }
}
