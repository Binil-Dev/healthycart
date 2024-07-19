import 'package:healthycart/core/general/typdef.dart';
import 'package:healthycart/features/add_hospital_form_page/domain/model/hospital_model.dart';
import 'package:healthycart/features/hospital_doctor/domain/model/add_doctor_model.dart';
import 'package:healthycart/features/hospital_profile/domain/models/transaction_model.dart';

abstract class IProfileFacade {
  FutureResult<String> setActiveHospital({
    required bool ishospitalON,
    required String hospitalId,
  });

  FutureResult<List<DoctorAddModel>> getHospitalAllDoctorDetails({
    required String hospitalId,
    required String? searchText,
  });
  void clearFetchData();
  FutureResult<List<TransferTransactionsModel>> getAdminTransactionList(
      {required String hospitalId});
  FutureResult<String> addBankDetails(
      {required HospitalModel bankDetails, required String hospitalId});
  void clearTransactionData();
}
