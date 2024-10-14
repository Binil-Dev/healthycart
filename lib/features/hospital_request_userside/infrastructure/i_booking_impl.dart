import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:healthycart/core/failures/main_failure.dart';
import 'package:healthycart/core/general/firebase_collection.dart';
import 'package:healthycart/core/general/typdef.dart';
import 'package:healthycart/core/services/get_network_time.dart';
import 'package:healthycart/features/hospital_request_userside/domain/i_booking_facade.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/booking_model.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/day_transaction_model.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/hospital_transaction_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IBookingFacade)
class IBookingImpl implements IBookingFacade {
  IBookingImpl(this._firestore);
  final FirebaseFirestore _firestore;

/* -------------------- GET HOSPITAL NEW REQUESTS STREWA -------------------- */
  StreamController<Either<MainFailure, List<HospitalBookingModel>>>
      newRequestStreamController = StreamController<
          Either<MainFailure, List<HospitalBookingModel>>>.broadcast();
  late StreamSubscription newRequestSubscription;

  @override
  Stream<Either<MainFailure, List<HospitalBookingModel>>> getNewRequestStream(
      {required String hospitalId, required String? searchPhoneNumber}) async* {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.hospitalBooking)
          .orderBy('bookedAt', descending: true)
          .where(Filter.and(Filter('hospitalId', isEqualTo: hospitalId),
              Filter('orderStatus', isEqualTo: 0)));
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
       query = query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }

      newRequestSubscription = query.snapshots().listen(
        (snapshot) {
          newRequestStreamController.add(right(snapshot.docs
              .map((e) =>
                  HospitalBookingModel.fromMap(e.data() as Map<String, dynamic>)
                      .copyWith(id: e.id))
              .toList()));
        },
      );
    } catch (e) {
      newRequestStreamController
          .add(left(MainFailure.generalException(errMsg: e.toString())));
    }
    yield* newRequestStreamController.stream;
  }
  @override
   Future<void> cancelNewRequestStream() async {
    await newRequestSubscription.cancel();
  }
  @override
  FutureResult<String> setNewTimeSlot(
      {required String bookingId,
      required String newDate,
      required String newTimeSlot}) async {
    try {
      await _firestore
          .collection(FirebaseCollections.hospitalBooking)
          .doc(bookingId)
          .update({'newBookingDate': newDate, 'newTimeSlot': newTimeSlot});
      return right('Time slot updated successfully');
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  /* -------------------------- GET ACCEPTED BOOKINGS ------------------------- */
  StreamController<Either<MainFailure, List<HospitalBookingModel>>>
      acceptedStreamController = StreamController<
          Either<MainFailure, List<HospitalBookingModel>>>.broadcast();
 late StreamSubscription acceptedSubscription;
  @override
  Stream<Either<MainFailure, List<HospitalBookingModel>>>
      getAcceptedBookingsStream(
           {required String hospitalId, required String? searchPhoneNumber}) async* {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.hospitalBooking)
          .orderBy('acceptedAt', descending: true)
          .where(Filter.and(Filter('hospitalId', isEqualTo: hospitalId),
              Filter('orderStatus', isEqualTo: 1)));
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
       query = query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }
      acceptedSubscription = query
          .snapshots()
          .listen(
        (snapshots) {
          acceptedStreamController.add(right(snapshots.docs
              .map((e) =>
                  HospitalBookingModel.fromMap(e.data() as Map<String,dynamic>).copyWith(id: e.id))
              .toList()));
        },
      );
    } catch (e) {
      acceptedStreamController
          .add(left(MainFailure.generalException(errMsg: e.toString())));
    }
    yield* acceptedStreamController.stream;
  }
   @override
   Future<void> cancelAcceptedBookingsStream() async {
    await acceptedSubscription.cancel();
  }

  /* --------------------------- UPDATE ORDER STATUS -------------------------- */

  @override
  FutureResult<String> updateOrderStatus({
    required String orderId,
    required int orderStatus,
    required int? tokenNumber,
    String? hospitalId,
    DayTransactionModel? dayTransactionModel,
    num? totalAmount,
    String? paymentMode,
    String? dayTransactionDate,
    String? rejectReason,
    num? commission,
    num? commissionAmt,
  }) async {
    try {
      /* ------------------------------- ACCEPT ORDER ------------------------------ */
      if (orderStatus == 1) {
        await _firestore
            .collection(FirebaseCollections.hospitalBooking)
            .doc(orderId)
            .update({
          'orderStatus': 1,
          'acceptedAt': Timestamp.now(),
          'tokenNumber': tokenNumber,
        });
        return right('Booking Accepted successfully');
      } else if (orderStatus == 2) {
        final batch = _firestore.batch();
        final formattedDate = await getFormattedNetworkTime();

        final bookingDoc = _firestore
            .collection(FirebaseCollections.hospitalBooking)
            .doc(orderId);
        final transactionDoc = _firestore
            .collection(FirebaseCollections.hospitalTransactions)
            .doc(hospitalId);

        final dayTransactionDoc = _firestore
            .collection(FirebaseCollections.hospitals)
            .doc(hospitalId)
            .collection(FirebaseCollections.dayTransaction)
            .doc(formattedDate);
        final hospitalDoc = _firestore
            .collection(FirebaseCollections.hospitals)
            .doc(hospitalId);

        batch.update(bookingDoc, {
          'orderStatus': 2,
          'completedAt': Timestamp.now(),
          'commission': commission,
          'commissionAmt': commissionAmt,
        });
        batch.update(transactionDoc, {
          'totalTransactionAmt': FieldValue.increment(totalAmount!),
          'totalCommissionPending': FieldValue.increment(commissionAmt!)
        });

        if (paymentMode == 'Online') {
          batch.update(transactionDoc,
              {'onlinePayment': FieldValue.increment(totalAmount)});
        } else {
          batch.update(transactionDoc,
              {'offlinePayment': FieldValue.increment(totalAmount)});
        }
        batch.update(hospitalDoc, {'dayTransaction': formattedDate});

        if (dayTransactionDate == formattedDate) {
          batch.update(dayTransactionDoc, {
            'totalAmount': FieldValue.increment(totalAmount),
            'commission': FieldValue.increment(commissionAmt),
            'offlinePayment': paymentMode != 'Online'
                ? FieldValue.increment(totalAmount)
                : FieldValue.increment(0),
            'onlinePayment': paymentMode == 'Online'
                ? FieldValue.increment(totalAmount)
                : FieldValue.increment(0),
          });
        } else {
          batch.set(dayTransactionDoc, dayTransactionModel?.toMap());
        }

        await batch.commit();

        return right('Order Completed Successfully');
      } else if (orderStatus == 3) {
        await _firestore
            .collection(FirebaseCollections.hospitalBooking)
            .doc(orderId)
            .update({
          'orderStatus': 3,
          'rejectReason': rejectReason,
          'rejectedAt': Timestamp.now()
        });
        return right('Order Rejected');
      }
      return left(
          const MainFailure.generalException(errMsg: 'Invalid order status'));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  /* -------------------------- GET COMPLETE BOOKINGS ------------------------- */

  DocumentSnapshot<Map<String, dynamic>>? completedLastDoc;
  bool completedNoMoreData = false;
  @override
  FutureResult<List<HospitalBookingModel>> getCompletedBookings(
      {required String hospitalId, required String? searchPhoneNumber,}) async {
    if (completedNoMoreData) return right([]);
     int limit = completedLastDoc == null ? 8 : 4;
    try {
      Query query = _firestore
          .collection(FirebaseCollections.hospitalBooking)
          .where('hospitalId', isEqualTo: hospitalId)
          .where('orderStatus', isEqualTo: 2)
          .orderBy('completedAt', descending: true);
  if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
      query = query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }
      if (completedLastDoc != null) {
        query = query.startAfterDocument(completedLastDoc!);
      }
      final snapshot = await query.limit(limit).get();

      if (snapshot.docs.length < limit || snapshot.docs.isEmpty) {
        completedNoMoreData = true;
      } else {
        completedLastDoc = snapshot.docs.last as DocumentSnapshot<Map<String, dynamic>>;
      }

      return right(snapshot.docs.map((e) =>
              HospitalBookingModel.fromMap(e.data() as Map<String, dynamic>).copyWith(id: e.id)).toList());
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  void clearDataCompleted() {
    completedLastDoc = null;
    completedNoMoreData = false;
  }

/* ------------------------- GET CANCELLED BOOKINGD ------------------------- */
  DocumentSnapshot<Map<String, dynamic>>? cancelledLastDoc;
  bool cancelledNoMoreData = false;

  @override
  FutureResult<List<HospitalBookingModel>> getRejectedOrders(
      {required String hospitalId,required String? searchPhoneNumber,}) async {
    if (cancelledNoMoreData) return right([]);
    int limit = cancelledLastDoc == null ? 8 : 4;
    try {
      Query query = _firestore
          .collection(FirebaseCollections.hospitalBooking)
          .where('hospitalId', isEqualTo: hospitalId)
          .where('orderStatus', isEqualTo: 3)
          .orderBy('rejectedAt', descending: true);
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
   query = query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }  

      if (cancelledLastDoc != null) {
        query = query.startAfterDocument(cancelledLastDoc!);
      }
      final snapshot = await query.limit(limit).get();
      if (snapshot.docs.length < limit || snapshot.docs.isEmpty) {
        cancelledNoMoreData = true;
      } else {
        cancelledLastDoc =
            snapshot.docs.last as DocumentSnapshot<Map<String, dynamic>>;
      }
      final rejectedOrderList = snapshot.docs
          .map((e) =>
              HospitalBookingModel.fromMap(e.data() as Map<String, dynamic>)
                  .copyWith(id: e.id))
          .toList();

      return right(rejectedOrderList);
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  void clearDataRejected() {
    cancelledLastDoc = null;
    cancelledNoMoreData = false;
  }

  /* --------------- UPDATE PAYMENT STATUS WHEN PAYMENT RECEIVED -------------- */
  @override
  FutureResult<String> updatePaymentStatus({required String orderId}) async {
    try {
      await _firestore
          .collection(FirebaseCollections.hospitalBooking)
          .doc(orderId)
          .update({'paymentStatus': 1});
      return right('Payment status updated successfully');
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

/* ------------------------- GET TRANSACTION DETAIL ------------------------- */
  @override
  FutureResult<HospitalTransactionModel> getTransactionData(
      {required String hospitalId}) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.hospitalTransactions)
          .where('id', isEqualTo: hospitalId)
          .get();

      return right(HospitalTransactionModel.fromMap(doc.docs.single.data()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }
}
