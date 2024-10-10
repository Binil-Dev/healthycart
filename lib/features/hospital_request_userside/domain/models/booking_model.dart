import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/model/hospital_model.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/add_doctor_model.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/user_model.dart';

class HospitalBookingModel {
  String? id;
  String? hospitalId;
  String? userId;
  String? patientName;
  String? patientAge;
  String? patientGender;
  String? patientPlace;
  String? patientNumber;
  String? paymentMethod;
  int? orderStatus;
  int? totalAmount;
  Timestamp? bookedAt;
  int? paymentStatus;
  DoctorAddModel? selectedDoctor;
  String? selectedDate;
  String? selectedTimeSlot;
  Timestamp? acceptedAt;
  Timestamp? rejectedAt;
  Timestamp? completedAt;
  HospitalModel? hospitalDetails;
  String? rejectReason;
  bool? isUserAccepted;
  UserModel? userDetails;
  String? newBookingDate;
  String? newTimeSlot;
  num? commission;
  num? commissionAmt;
  String? uhid;
  int? tokenNumber;
  HospitalBookingModel({
    this.id,
    this.hospitalId,
    this.userId,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.patientPlace,
    this.patientNumber,
    this.paymentMethod,
    this.orderStatus,
    this.totalAmount,
    this.bookedAt,
    this.paymentStatus,
    this.selectedDoctor,
    this.selectedDate,
    this.selectedTimeSlot,
    this.acceptedAt,
    this.rejectedAt,
    this.completedAt,
    this.hospitalDetails,
    this.rejectReason,
    this.isUserAccepted,
    this.userDetails,
    this.newBookingDate,
    this.newTimeSlot,
    this.commission,
    this.commissionAmt,
    this.uhid,
    this.tokenNumber,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'hospitalId': hospitalId,
      'userId': userId,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'patientPlace': patientPlace,
      'patientNumber': patientNumber,
      'paymentMethod': paymentMethod,
      'orderStatus': orderStatus,
      'totalAmount': totalAmount,
      'bookedAt': bookedAt,
      'paymentStatus': paymentStatus,
      'selectedDoctor': selectedDoctor!.toMap(),
      'selectedDate': selectedDate,
      'selectedTimeSlot': selectedTimeSlot,
      'acceptedAt': acceptedAt,
      'rejectedAt': rejectedAt,
      'completedAt': completedAt,
      'hospitalDetails': hospitalDetails!.toMap(),
      'rejectReason': rejectReason,
      'isUserAccepted': isUserAccepted,
      'userDetails': userDetails!.toMap(),
      'newTimeSlot': newTimeSlot,
      'newBookingDate': newBookingDate,
      'commission': commission,
      'commissionAmt': commissionAmt,
    };
  }

  factory HospitalBookingModel.fromMap(Map<String, dynamic> map) {
    return HospitalBookingModel(
      id: map['id'] != null ? map['id'] as String : null,
      hospitalId:
          map['hospitalId'] != null ? map['hospitalId'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
      patientName:
          map['patientName'] != null ? map['patientName'] as String : null,
      patientAge:
          map['patientAge'] != null ? map['patientAge'] as String : null,
      patientGender:
          map['patientGender'] != null ? map['patientGender'] as String : null,
      patientPlace:
          map['patientPlace'] != null ? map['patientPlace'] as String : null,
      patientNumber:
          map['patientNumber'] != null ? map['patientNumber'] as String : null,
      paymentMethod:
          map['paymentMethod'] != null ? map['paymentMethod'] as String : null,
      orderStatus:
          map['orderStatus'] != null ? map['orderStatus'] as int : null,
      totalAmount:
          map['totalAmount'] != null ? map['totalAmount'] as int : null,
      bookedAt: map['bookedAt'] != null ? map['bookedAt'] as Timestamp : null,
      paymentStatus:
          map['paymentStatus'] != null ? map['paymentStatus'] as int : null,
      selectedDoctor: map['selectedDoctor'] != null
          ? DoctorAddModel.fromMap(
              map['selectedDoctor'] as Map<String, dynamic>)
          : null,
      selectedDate:
          map['selectedDate'] != null ? map['selectedDate'] as String : null,
      selectedTimeSlot: map['selectedTimeSlot'] != null
          ? map['selectedTimeSlot'] as String
          : null,
      acceptedAt:
          map['acceptedAt'] != null ? map['bookedAt'] as Timestamp : null,
      rejectedAt:
          map['rejectedAt'] != null ? map['bookedAt'] as Timestamp : null,
      completedAt:
          map['completedAt'] != null ? map['bookedAt'] as Timestamp : null,
      hospitalDetails: map['hospitalDetails'] != null
          ? HospitalModel.fromMap(
              map['hospitalDetails'] as Map<String, dynamic>)
          : null,
      rejectReason:
          map['rejectReason'] != null ? map['rejectReason'] as String : null,
      isUserAccepted:
          map['isUserAccepted'] != null ? map['isUserAccepted'] as bool : null,
      userDetails: map['userDetails'] != null
          ? UserModel.fromMap(map['userDetails'] as Map<String, dynamic>)
          : null,
      newBookingDate: map['newBookingDate'] != null
          ? map['newBookingDate'] as String
          : null,
      newTimeSlot:
          map['newTimeSlot'] != null ? map['newTimeSlot'] as String : null,
                 commission: map['commission'] != null ? map['commission'] as num : null,
      commissionAmt:
          map['commissionAmt'] != null ? map['commissionAmt'] as num : null,  
      uhid: map['uhid'] != null ? map['uhid'] as String : null,
      tokenNumber:  map['tokenNumber'] != null ? map['tokenNumber'] as int : null,         
    );
  }

  HospitalBookingModel copyWith({
    String? id,
    String? hospitalId,
    String? userId,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? patientPlace,
    String? patientNumber,
    String? paymentMethod,
    int? orderStatus,
    int? totalAmount,
    Timestamp? bookedAt,
    int? paymentStatus,
    DoctorAddModel? selectedDoctor,
    String? selectedDate,
    String? selectedTimeSlot,
    Timestamp? acceptedAt,
    Timestamp? rejectedAt,
    Timestamp? completedAt,
    HospitalModel? hospitalDetails,
    String? rejectReason,
    bool? isUserAccepted,
    UserModel? userDetails,
    String? newBookingDate,
    String? newTimeSlot,
    num? commission,
    num? commissionAmt,
    String?  uhid,
    int? tokenNumber,
  }) {
    return HospitalBookingModel(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      userId: userId ?? this.userId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      patientPlace: patientPlace ?? this.patientPlace,
      patientNumber: patientNumber ?? this.patientNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderStatus: orderStatus ?? this.orderStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      bookedAt: bookedAt ?? this.bookedAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      completedAt: completedAt ?? this.completedAt,
      hospitalDetails: hospitalDetails ?? this.hospitalDetails,
      rejectReason: rejectReason ?? this.rejectReason,
      isUserAccepted: isUserAccepted ?? this.isUserAccepted,
      userDetails: userDetails ?? this.userDetails,
      newTimeSlot: newTimeSlot ?? this.newTimeSlot,
      newBookingDate: newBookingDate ?? this.newBookingDate,
      commission: commission ?? this.commission,
      commissionAmt: commissionAmt ?? this.commissionAmt,
      uhid: uhid?? this.uhid,
      tokenNumber: tokenNumber?? this.tokenNumber,
    );
  }
}
