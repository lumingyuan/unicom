import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'dart:async';

typedef ConfirmCallback = void Function(int index);

class SinglePicker extends StatelessWidget {
  final List<String> data;
  final ConfirmCallback onConfirm;

  SinglePicker(this.data, this.onConfirm);

  static Future<int> show(BuildContext context, List<String> data,
      ConfirmCallback onConfirm) async {
    int index = await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SinglePicker(data, onConfirm),
            ),
          );
        });
    return index;
  }

  @override
  Widget build(BuildContext context) {
    Picker picker = new Picker(
        adapter: PickerDataAdapter(pickerdata: this.data),
        hideHeader: false,
        itemExtent: 40,
        height: 200,
        confirmText: '确定',
        cancelText: '取消',
        onConfirm: (Picker picker, List<int> data) {
          this.onConfirm(data[0]);
        },
        onSelect: (Picker picker, int index, List<int> data) {});
    return Container(
      child: picker.makePicker(),
    );
  }
}
