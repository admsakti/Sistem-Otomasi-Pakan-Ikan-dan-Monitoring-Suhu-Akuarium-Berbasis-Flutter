import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class TempController extends GetxController {
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  var latestTemperature = RxDouble(0.0);

  final _temperatureStream = RxList<MapEntry<String, double>>();
  RxList<MapEntry<String, double>> get temperatureStream => _temperatureStream;

  void _startTemperatureStream() {
    databaseRef.child("temperature").onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          List<MapEntry<dynamic, dynamic>> dataList = data.entries.toList();
          dataList.sort((a, b) => a.key.compareTo(b.key));
          List<MapEntry<String, double>> convertDataList =
              convertList(dataList);
          List<MapEntry<String, double>> last10Entries =
              getLast7Entries(convertDataList);
          // print(last10Entries);
          _temperatureStream.clear();
          _temperatureStream.assignAll(last10Entries);
          latestTemperature.value = _temperatureStream.last.value;
        }
      },
    );
  }

  List<MapEntry<String, double>> convertList(
      List<MapEntry<dynamic, dynamic>> originalList) {
    List<MapEntry<String, double>> resultList = [];

    for (var entry in originalList) {
      resultList.add(MapEntry<String, double>(
          entry.key.toString(), entry.value.toDouble()));
    }

    return resultList;
  }

  List<MapEntry<String, double>> getLast7Entries(
      List<MapEntry<String, double>> originalList) {
    if (originalList.length >= 7) {
      return originalList.sublist(originalList.length - 7);
    } else {
      return originalList;
    }
  }

  @override
  void onInit() {
    _startTemperatureStream();
    super.onInit();
  }
}
