// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/model/admin_model.dart';
import 'package:healthycart/features/location_picker/domain/model/location_model.dart';
import 'package:healthycart/utils/constants/enums.dart';

class HospitalModel extends Admin {
  HospitalModel({
    super.adminType,
    super.id,
    super.placemark,
    super.phoneNo,
    this.hospitalName,
    this.address,
    this.ownerName,
    this.uploadLicense,
    this.image,
    this.selectedCategoryId,
    this.requested,
    this.isActive,
    this.createdAt,
    this.keywords,
    this.fcmToken,
    this.email,
    this.rejectionReason,
    this.ishospitalON,
    this.dayTransaction,
    this.accountHolderName,
    this.bankName,
    this.ifscCode,
    this.accountNumber,
  });

  final String? hospitalName;
  final String? address;
  final String? ownerName;
  final String? uploadLicense;
  final String? image;
  final List<String>? selectedCategoryId;
  final int? requested;
  final bool? isActive;
  final bool? ishospitalON;
  final Timestamp? createdAt;
  final List<String>? keywords;
  final String? rejectionReason;
  final String? fcmToken;
  final String? email;
  final String? dayTransaction;
  String? accountHolderName;
  String? bankName;
  String? ifscCode;
  String? accountNumber;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hospitalName': hospitalName,
      'address': address,
      'ownerName': ownerName,
      'uploadLicense': uploadLicense,
      'image': image,
      'selectedCategoryId': selectedCategoryId,
      'requested': requested,
      'isActive': isActive,
      'ishospitalON': ishospitalON,
      'createdAt': createdAt,
      'keywords': keywords,
      'email': email,
      'dayTransaction': dayTransaction,
      'fcmToken': fcmToken,
      'rejectionReason': rejectionReason,
      ...super.toMap()
    };
  }

  Map<String, dynamic> toFormMap() {
    return {
      'id': id,
      'hospitalName': hospitalName,
      'address': address,
      'ownerName': ownerName,
      'uploadLicense': uploadLicense,
      'image': image,
      'selectedCategoryId': selectedCategoryId,
      'requested': requested,
      'isActive': isActive,
      'ishospitalON': ishospitalON,
      'createdAt': createdAt,
      'keywords': keywords,
      'email': email,
      'dayTransaction': dayTransaction,
      'rejectionReason': rejectionReason,
      ...super.toMap()
    };
  }

  Map<String, dynamic> toEditMap() {
    return {
      'hospitalName': hospitalName,
      'address': address,
      'ownerName': ownerName,
      'uploadLicense': uploadLicense,
      'image': image,
      'email': email,
      'keywords': keywords,
    };
  }

  Map<String, dynamic> toBankDetailsMap() {
    return <String, dynamic>{
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'accountNumber': accountNumber,
    };
  }

  factory HospitalModel.initial() {
    return HospitalModel();
  }

  factory HospitalModel.fromMap(Map<String, dynamic> map) {
    return HospitalModel(
      adminType: Admin.getAdminType(
        map['adminType'] ?? '',
      ), // Ensure you're getting adminType from map
      phoneNo: map['phoneNo'] as String,
      id: map['id'] as String?,
      placemark: map['placemark'] != null
          ? PlaceMark.fromMap(map['placemark'] as Map<String, dynamic>)
          : null,
      hospitalName: map['hospitalName'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      address: map['address'] as String?,
      ownerName: map['ownerName'] as String?,
      uploadLicense: map['uploadLicense'] as String?,
      image: map['image'] as String?,
      selectedCategoryId: map['selectedCategoryId'] != null
          ? List<String>.from((map['selectedCategoryId'] as List<dynamic>))
          : null,
      email: map['email'] != null ? map['email'] as String : null,
      dayTransaction: map['dayTransaction'] != null
          ? map['dayTransaction'] as String
          : null,
      fcmToken: map['fcmToken'] != null ? map['fcmToken'] as String : null,
      requested: map['requested'] != null ? map['requested'] as int : null,
      isActive: map['isActive'] as bool?,
      ishospitalON: map['ishospitalON'] as bool?,
      createdAt: map['createdAt'] as Timestamp?,
      keywords: map['keywords'] != null
          ? List<String>.from((map['keywords'] as List<dynamic>))
          : null,
      accountHolderName: map['accountHolderName'] != null
          ? map['accountHolderName'] as String
          : null,
      bankName: map['bankName'] != null ? map['bankName'] as String : null,
      ifscCode: map['ifscCode'] != null ? map['ifscCode'] as String : null,
      accountNumber:
          map['accountNumber'] != null ? map['accountNumber'] as String : null,
    );
  }

  HospitalModel copyWith({
    String? hospitalName,
    String? address,
    String? ownerName,
    String? uploadLicense,
    String? image,
    AdminType? adminType,
    PlaceMark? placemark,
    String? phoneNo,
    String? id,
    List<String>? selectedCategoryId,
    int? requested,
    bool? isActive,
    bool? ishospitalON,
    Timestamp? createdAt,
    String? fcmToken,
    String? email,
    List<String>? keywords,
    String? rejectionReason,
    String? dayTransaction,
    String? accountHolderName,
    String? bankName,
    String? ifscCode,
    String? accountNumber,
  }) {
    return HospitalModel(
      id: id ?? super.id,
      phoneNo: phoneNo ?? super.phoneNo,
      adminType: adminType ?? super.adminType,
      placemark: placemark ?? super.placemark,
      hospitalName: hospitalName ?? this.hospitalName,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      uploadLicense: uploadLicense ?? this.uploadLicense,
      image: image ?? this.image,
      fcmToken: fcmToken ?? this.fcmToken,
      email: email ?? this.email,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      requested: requested ?? this.requested,
      isActive: isActive ?? this.isActive,
      ishospitalON: ishospitalON ?? this.ishospitalON,
      createdAt: createdAt ?? this.createdAt,
      keywords: keywords ?? this.keywords,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      dayTransaction: dayTransaction ?? this.dayTransaction,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}
