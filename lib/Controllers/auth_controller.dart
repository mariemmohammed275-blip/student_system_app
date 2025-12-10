import 'package:get/get.dart';

class AuthController extends GetxController {
  var token = ''.obs;

  void saveToken(String newToken) {
    token.value = newToken;
  }

  void logout() {
    token.value = "";
  }
}
