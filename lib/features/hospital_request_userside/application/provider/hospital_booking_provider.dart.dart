import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/core/services/get_network_time.dart';
import 'package:healthycart/core/services/sent_fcm_message.dart';
import 'package:healthycart/features/hospital_request_userside/domain/i_booking_facade.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/booking_model.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/day_transaction_model.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/hospital_transaction_model.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

@injectable
class HospitalBookingProvider extends ChangeNotifier {
  HospitalBookingProvider(this.iBookingFacade);
  final IBookingFacade iBookingFacade;
  bool isLoading = false;
  TextEditingController dateController = TextEditingController();
  String? selectedTimeSlot1;
  String? selectedTimeSlot2;
  String? totalTime;
  void clearTimeSlotData() {
    selectedTimeSlot1 = null;
    selectedTimeSlot2 = null;
    dateController.clear();
    notifyListeners();
  }


  /* ------------------------- GET NEW REQUEST STREAM ------------------------- */
  final TextEditingController searchNewRequestController = TextEditingController();
  List<HospitalBookingModel> newRequestList = [];
  void getNewRequestStream({
    required String hospitalId,
    String? searchPhoneNumber,
  }) {
    isLoading = true;
    notifyListeners();
    iBookingFacade
        .getNewRequestStream(hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber)
        .listen(
      (event) {
        event.fold(
          (err) {
            CustomToast.errorToast(text: 'Unable to get new orders');
            log('ERROR :: ${err.errMsg}');
            isLoading = false;
            notifyListeners();
          },
          (success) {
            newRequestList = success;
            isLoading = false;
            notifyListeners();
          },
        );
      },
    );
    notifyListeners();
  }

 Future<void> cancelNewRequestStream() async {
    await iBookingFacade.cancelNewRequestStream();
  }
  /* ------------------------- GET ACCEPTED REQUEST STREAM ------------------------- */
   final TextEditingController searchAcceptedBookingsController = TextEditingController();
  List<HospitalBookingModel> acceptedList = [];
  void getAcceptedBookingsStream({
    required String hospitalId,
    String? searchPhoneNumber,
  }) {
    isLoading = true;
    notifyListeners();
    iBookingFacade
        .getAcceptedBookingsStream(
            hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber)
        .listen(
      (event) {
        event.fold(
          (err) {
            log('ERROR :: ${err.errMsg}');
            isLoading = false;
            notifyListeners();
          },
          (success) {
            acceptedList = success;
            isLoading = false;
            notifyListeners();
          },
        );
      },
    );
    notifyListeners();
  }


  Future<void> cancelAcceptedBookingsStream() async {
    await iBookingFacade.cancelAcceptedBookingsStream();
  }
  /* ------------------------------ SET TIME SLOT ----------------------------- */
  Future<void> setTimeSlot(
      {required String bookingId,
      required String newDate,
      required String newTime}) async {
    final result = await iBookingFacade.setNewTimeSlot(
        bookingId: bookingId, newDate: newDate, newTimeSlot: newTime);
    result.fold(
      (err) {
        CustomToast.errorToast(text: err.errMsg);
      },
      (success) {
        CustomToast.sucessToast(text: success);
      },
    );
  }

  /* --------------------------- UPDATE ORDER STATUS -------------------------- */
  final TextEditingController rejectionReasonCobtroller =
      TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final rejectionFormKey = GlobalKey<FormState>();

  Future<void> updateOrderStatus({
    required String orderId,
    required int orderStatus,
    required String fcmtoken,
    String? hospitalName,
    String? hospitalId,
    num? totalAmount,
    num? commission,
    num? commissionAmt,
    String? dayTransactionDate,
    String? paymentMode,
    String? rejectReason,
  }) async {
    isLoading = true;
    notifyListeners();
    final networkTime = await getNetworkTime();
    final result = await iBookingFacade.updateOrderStatus(
        tokenNumber: int.tryParse(tokenController.text),
        totalAmount: totalAmount,
        orderId: orderId,
        orderStatus: orderStatus,
        hospitalId: hospitalId,
        rejectReason: rejectReason,
        dayTransactionDate: dayTransactionDate,
        paymentMode: paymentMode,
        commissionAmt: commissionAmt,
        commission: commission,
        dayTransactionModel: DayTransactionModel(
          commission: commissionAmt,
          createdAt: Timestamp.fromDate(networkTime),
          totalAmount: totalAmount,
          offlinePayment: paymentMode != 'Online' ? totalAmount : 0,
          onlinePayment: paymentMode == 'Online' ? totalAmount : 0,
        ),);
    result.fold((err) {
      CustomToast.errorToast(text: err.errMsg);
      isLoading = false;
      notifyListeners();
    }, (success) async {
      if (orderStatus == 3) {
        sendFcmMessage(
            token: fcmtoken,
            body:
                'Your booking is rejected by $hospitalName hospital, Click to check details!!',
            title: 'Booking Rejected!!');
      } else if (orderStatus == 1) {
        sendFcmMessage(
            token: fcmtoken,
            body:
                'Your booking is approved by $hospitalName hospital, Please check the details and complete payment!!',
            title: 'Booking Approved!!');
      } else if (orderStatus == 2) {
        sendFcmMessage(
            token: fcmtoken,
            body:
                'Your hospital appointment is successfully completed, Thank you for choosing Healthycart. We look forward to continuing to serve your healthcare needs.',
            title: 'Appointment Completed!!');
      }
      CustomToast.sucessToast(text: success);
      tokenController.clear();
      isLoading = false;
      notifyListeners();
    });
  }

  num calculateOrderCommission(num finalAmount) {
    return (finalAmount * hospitalTransactionModel!.commission!) / 100;
  }

  /* ------------------------------ LAUNCH DIALER ----------------------------- */
  Future<void> lauchDialer({required String phoneNumber}) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      CustomToast.errorToast(text: 'Could not launch the dialer');
    }
  }

  /* ------------------------- GET COMPLETED BOOKINGS ------------------------- */
  List<HospitalBookingModel> completedList = [];
  final TextEditingController searchCompletedBookingsController = TextEditingController();
  Future<void> getCompletedOrders({
    required String hospitalId,
    String? searchPhoneNumber,
  }) async {
    isLoading = true;
    notifyListeners();
    final result = await iBookingFacade.getCompletedBookings(
        hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber);
    result.fold((err) {
      log('error in getCompletedOrders() :: ${err.errMsg}');
    }, (success) {
      completedList.addAll(success);
      notifyListeners();
    });
    isLoading = false;
    notifyListeners();
  }

  void cleatDataCompleted() {
    iBookingFacade.clearDataCompleted();
    completedList = [];
    notifyListeners();
  }

  void searchCompletedOrders({
    required String hospitalId,
    required String searchPhoneNumber,
  }) {
    completedList.clear();
    iBookingFacade.clearDataCompleted();
    getCompletedOrders(
        hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber);
    notifyListeners();
  }

  void completeInit({
    required ScrollController scrollController,
    required String hospitalId,
    String? searchPhoneNumber,
  }) {
    scrollController.addListener(
      () {
        if (scrollController.position.atEdge &&
            scrollController.position.pixels != 0 &&
            isLoading == false) {
          getCompletedOrders(
              hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber);
        }
      },
    );
  }
/* -------------------------------------------------------------------------- */

/* -------------------------- GET REJECTED BOOKINGS ------------------------- */
  List<HospitalBookingModel> rejectedBookings = [];
   final TextEditingController searchRejectedOrdersController = TextEditingController();
  Future<void> getRejectedOrders({
    required String hospitalId,
    String? searchPhoneNumber,
  }) async {
    isLoading = true;
    notifyListeners();
    final result = await iBookingFacade.getRejectedOrders(
        hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber);
    result.fold(
      (err) {
        log('Error in getRejectedOrders() :: ${err.errMsg}');
      },
      (success) {
        rejectedBookings.addAll(success);
        notifyListeners();
      },
    );
    isLoading = false;
    notifyListeners();
  }

  void clearDataRejected() {
    iBookingFacade.clearDataRejected();

    rejectedBookings = [];
    notifyListeners();
  }

  void searchRejectedOrders({
    required String hospitalId,
    required String searchPhoneNumber,
  }) {
    rejectedBookings.clear();
    iBookingFacade.clearDataRejected();
    getRejectedOrders(
        hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber);
    notifyListeners();
  }

  void rejectInitt({
    required ScrollController scrollController,
    required String hospitalId,
    String? searchPhoneNumber,
  }) {
    scrollController.addListener(
      () {
        if (scrollController.position.atEdge &&
            scrollController.position.pixels != 0 &&
            isLoading == false) {
          getRejectedOrders(
              hospitalId: hospitalId, searchPhoneNumber: searchPhoneNumber);
        }
      },
    );
  }

  /* --------------- UPDATE PAYMENT STATUS WHEN PAYMENT RECEIVED -------------- */

  Future<void> updatePaymentStatus({required String orderId}) async {
    final result = await iBookingFacade.updatePaymentStatus(orderId: orderId);
    result.fold((err) {
      CustomToast.errorToast(text: 'Order status update failed');
      log('ERROR updatePaymentStatus :: ${err.errMsg}');
    }, (success) {
      CustomToast.sucessToast(text: success);
    });
    notifyListeners();
  }

  /* -------------------------- GET TRANSACTION DATA -------------------------- */
  HospitalTransactionModel? hospitalTransactionModel;

  Future<void> getTransactionData({required String hospitalId}) async {
    isLoading = true;
    notifyListeners();
    log('Called transcation fetch');
    final result =
        await iBookingFacade.getTransactionData(hospitalId: hospitalId);

    result.fold(
      (err) {
        log('error in provider getTransactionData():: ${err.errMsg}');
      },
      (success) {
        // log(success.toString());
        hospitalTransactionModel = success;
        // log('transaction ID ::: $labId');
      },
    );
    isLoading = false;

    notifyListeners();
  }
}
