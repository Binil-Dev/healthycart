import 'package:flutter/foundation.dart';
import 'package:healthycart/features/pending_page/domain/i_pending_facade.dart';
import 'package:healthycart/utils/app_details/app_details.dart';
import 'package:injectable/injectable.dart';

@injectable
class PendingProvider extends ChangeNotifier {
  PendingProvider(this._iPendingFacade);
  final IPendingFacade _iPendingFacade;
  
  Future<void> reDirectToWhatsApp({required message}) async {
    await _iPendingFacade.reDirectToWhatsApp(
        whatsAppLink:
            'https://wa.me/${AppDetails.whatsappNumber}?text=$message');
  }
}
