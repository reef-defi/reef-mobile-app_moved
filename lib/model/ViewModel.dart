import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/model/tokens/token_model.dart';

import 'account/account.dart';

class ViewModel {
  final tokens = TokenModel();
  final accounts = AccountsModel();
  final signatureRequests = SignatureRequests();
}
