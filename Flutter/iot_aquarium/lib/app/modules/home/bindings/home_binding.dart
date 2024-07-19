import 'package:get/get.dart';
import 'package:iot_aquarium/app/modules/home/controllers/feed_controller.dart';

import '../controllers/home_controller.dart';
import '../controllers/temp_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<TempController>(
      () => TempController(),
    );
    Get.lazyPut<FeedController>(
      () => FeedController(),
    );
  }
}
