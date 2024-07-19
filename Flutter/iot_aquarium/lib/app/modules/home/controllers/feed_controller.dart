import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedController extends GetxController {
  DatabaseReference controlRef =
      FirebaseDatabase.instance.ref().child("control");

  var valveDisabled = false.obs;

  Rx<TimeOfDay> selectedTime1 = TimeOfDay.now().obs;
  Rx<TimeOfDay> selectedTime2 = TimeOfDay.now().obs;
  Rx<TimeOfDay> selectedTime3 = TimeOfDay.now().obs;

  Future<void> selectTime(int alarm) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (alarm == 1 && picked != null && picked != selectedTime1.value) {
      selectedTime1.value = picked;
      print(selectedTime1.value.format(Get.context!));
    } else if (alarm == 2 && picked != null && picked != selectedTime2.value) {
      selectedTime2.value = picked;
      print(selectedTime2.value.format(Get.context!));
    } else if (alarm == 3 && picked != null && picked != selectedTime3.value) {
      selectedTime3.value = picked;
      print(selectedTime3.value.format(Get.context!));
    }
  }

  void sendAlarmToRTDB() {
    String alarm =
        "${timeOfDayToString(selectedTime1.value)};${timeOfDayToString(selectedTime2.value)};${timeOfDayToString(selectedTime3.value)}";
    Map<String, String> data = {"alarm": alarm};
    controlRef.update(data).then((value) {
      Get.defaultDialog(
        title: "Success",
        middleText: "Berhasil mengirim data alarm",
      );
      print('Alarm sent successfully!');
    }).catchError((error) {
      Get.defaultDialog(
        title: "Error",
        middleText: "Gagal mengirim data alarm",
      );
      print('Error sending alarm: $error');
    });
  }

  void getAlarmFromRTDB() async {
    final alarm = await controlRef.child("alarm").get();
    if (alarm.exists) {
      String strAlarm = alarm.value.toString();
      List<String> parts = strAlarm.split(';');
      selectedTime1.value = stringToTimeOfDay(parts[0]);
      selectedTime2.value = stringToTimeOfDay(parts[1]);
      selectedTime3.value = stringToTimeOfDay(parts[2]);
      print(alarm.value.toString());
    } else {
      print('No data available.');
    }
  }

  String timeOfDayToString(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay stringToTimeOfDay(String formattedString) {
    List<String> parts = formattedString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  void openValve() {
    Map<String, String> data = {"valve": "ON"};
    controlRef.update(data).then((value) {
      Get.defaultDialog(
        title: "Success",
        middleText: "Berhasil membuka katup",
      );
      valveDisabled.value = true;
      Timer(const Duration(seconds: 5), () => valveDisabled.value = false);
      print('Valve status sent successfully!');
    }).catchError((error) {
      Get.defaultDialog(
        title: "Error",
        middleText: "Gagal membuka katup",
      );
      print('Error sending valve status: $error');
    });
  }

  @override
  void onInit() {
    getAlarmFromRTDB();
    super.onInit();
  }
}
