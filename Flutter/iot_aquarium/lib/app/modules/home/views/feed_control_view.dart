import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/feed_controller.dart';
import '../../../controllers/auth_controller.dart';

class FeedControlView extends GetView<FeedController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed Alarm & Controls"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => authC.logOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: Colors.lightBlue,
            margin: const EdgeInsets.all(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          'Alarm 1: ${controller.selectedTime1.value.format(context)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => controller.selectTime(1),
                        child: const Text('Select Alarm 1'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          'Alarm 2: ${controller.selectedTime2.value.format(context)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => controller.selectTime(2),
                        child: const Text('Select Alarm 2'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          'Alarm 3: ${controller.selectedTime3.value.format(context)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => controller.selectTime(3),
                        child: const Text('Select Alarm 3'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ElevatedButton(
                      onPressed: () => controller.sendAlarmToRTDB(),
                      child: const Text("Kirim Alarm"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Obx(
              () => ElevatedButton(
                onPressed: () {
                  if (controller.valveDisabled.value) {
                    Null;
                    print("Disabled!");
                  } else {
                    controller.openValve();
                    print("Open Valve!");
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      controller.valveDisabled.value
                          ? Colors.grey
                          : Colors.lightBlue),
                ),
                child: const Text(
                  "Open Valve Manual",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
