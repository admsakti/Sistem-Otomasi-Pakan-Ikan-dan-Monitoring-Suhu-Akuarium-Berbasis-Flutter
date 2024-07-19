import 'package:get/get.dart';

import '../views/realtime_graph_temp_view.dart';
import '../views/feed_control_view.dart';

class HomeController extends GetxController {
  final screens = [
    RealTimeGraphTempView(),
    FeedControlView(),
  ];

  final RxInt currentIndex = 0.obs;
}
