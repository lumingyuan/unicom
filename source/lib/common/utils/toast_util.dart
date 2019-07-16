import 'package:flutter/material.dart';
import 'package:toast/toast.dart' as Jaemobird;

class ToastUtil extends Dialog {
  static void shortToast(BuildContext context, String text,
      [bool success = false]) {
    Jaemobird.Toast.showToast(text, success: success, time: 2000);
  }

  static void showLoading(String text) {
    Jaemobird.Toast.showLoading(text);
  }

  static void hideLoading() {
    Jaemobird.Toast.hideLoading();
  }
}
