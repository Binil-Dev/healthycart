import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalTransactionModel {
  String? id;
  String? hospitalId;
  num? commission = 0;
  num? totalCommissionReceived = 0;
  num? totalCommissionPending = 0;
  num? commissionPaid = 0;
  num? totalTransactionAmt = 0;
  num? totalTransferredAmt = 0;
  num? totalAmtToTransfer = 0;
  num? balanceAmtToTransfer = 0;
  num? newTransactionAmt = 0;
  Timestamp? transactionDate;
  num? onlinePayment;
  num? offlinePayment;

  HospitalTransactionModel(
      {this.id,
      this.hospitalId,
      this.commission,
      this.totalCommissionReceived,
      this.totalCommissionPending,
      this.commissionPaid,
      this.totalTransactionAmt,
      this.totalTransferredAmt,
      this.totalAmtToTransfer,
      this.balanceAmtToTransfer,
      this.newTransactionAmt,
      this.transactionDate,
      this.onlinePayment,
      this.offlinePayment});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'hospitalId': hospitalId,
      'commission': commission,
      'totalCommissionReceived': totalCommissionReceived,
      'totalCommissionPending': totalCommissionPending,
      'commissionPaid': commissionPaid,
      'totalTransactionAmt': totalTransactionAmt,
      'totalTransferredAmt': totalTransferredAmt,
      'totalAmtToTransfer': totalAmtToTransfer,
      'balanceAmtToTransfer': balanceAmtToTransfer,
      'newTransactionAmt': newTransactionAmt,
      'transactionDate': transactionDate,
      'onlinePayment': onlinePayment,
      'offlinePayment': offlinePayment,
    };
  }

  factory HospitalTransactionModel.fromMap(Map<String, dynamic> map) {
    return HospitalTransactionModel(
      id: map['id'] != null ? map['id'] as String : null,
      hospitalId: map['hospitalId'] != null ? map['hospitalId'] as String : null,
      commission: map['commission'] != null ? map['commission'] as num : null,
      totalCommissionReceived: map['totalCommissionReceived'] != null
          ? map['totalCommissionReceived'] as num
          : null,
      totalCommissionPending: map['totalCommissionPending'] != null
          ? map['totalCommissionPending'] as num
          : null,
      commissionPaid:
          map['commissionPaid'] != null ? map['commissionPaid'] as num : null,
      totalTransactionAmt: map['totalTransactionAmt'] != null
          ? map['totalTransactionAmt'] as num
          : null,
      totalTransferredAmt: map['totalTransferredAmt'] != null
          ? map['totalTransferredAmt'] as num
          : null,
      totalAmtToTransfer: map['totalAmtToTransfer'] != null
          ? map['totalAmtToTransfer'] as num
          : null,
      balanceAmtToTransfer: map['balanceAmtToTransfer'] != null
          ? map['balanceAmtToTransfer'] as num
          : null,
      newTransactionAmt: map['newTransactionAmt'] != null
          ? map['newTransactionAmt'] as num
          : null,
      onlinePayment:
          map['onlinePayment'] != null ? map['onlinePayment'] as num : null,
      offlinePayment:
          map['offlinePayment'] != null ? map['offlinePayment'] as num : null,
      transactionDate: map['transactionDate'] != null
          ? map['transactionDate'] as Timestamp
          : null,
    );
  }

  HospitalTransactionModel copyWith({
    String? id,
    String? hospitalId,
    num? commission,
    num? totalCommissionReceived,
    num? totalCommissionPending,
    num? commissionPaid,
    num? totalTransactionAmt,
    num? totalTransferredAmt,
    num? totalAmtToTransfer,
    num? balanceAmtToTransfer,
    num? newTransactionAmt,
    num? onlinePayment,
    num? offlinePayment,
    Timestamp? transactionDate,
  }) {
    return HospitalTransactionModel(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      commission: commission ?? this.commission,
      totalCommissionReceived:
          totalCommissionReceived ?? this.totalCommissionReceived,
      totalCommissionPending:
          totalCommissionPending ?? this.totalCommissionPending,
      commissionPaid: commissionPaid ?? this.commissionPaid,
      totalTransactionAmt: totalTransactionAmt ?? this.totalTransactionAmt,
      totalTransferredAmt: totalTransferredAmt ?? this.totalTransferredAmt,
      totalAmtToTransfer: totalAmtToTransfer ?? this.totalAmtToTransfer,
      balanceAmtToTransfer: balanceAmtToTransfer ?? this.balanceAmtToTransfer,
      newTransactionAmt: newTransactionAmt ?? this.newTransactionAmt,
      transactionDate: transactionDate ?? this.transactionDate,
      onlinePayment: onlinePayment ?? this.onlinePayment,
      offlinePayment: offlinePayment ?? this.offlinePayment,
    );
  }
}
