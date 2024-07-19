import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controllers/temp_controller.dart';
import '../../../controllers/auth_controller.dart';

class RealTimeGraphTempView extends GetView<TempController> {
  final authC = Get.find<AuthController>();

  String textTitle(int value) {
    String text = controller.temperatureStream.elementAt(value).key.toString();
    text = text.substring(text.length - 8, text.length - 3);
    return text;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;

    switch (value) {
      case 0:
        text = textTitle(0);
        break;
      case 1:
        text = textTitle(1);
        break;
      case 2:
        text = textTitle(2);
        break;
      case 3:
        text = textTitle(3);
        break;
      case 4:
        text = textTitle(4);
        break;
      case 5:
        text = textTitle(5);
        break;
      case 6:
        text = textTitle(6);
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Realtime Temperature"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => authC.logOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: Colors.lightBlue,
            margin: const EdgeInsets.all(50),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(
                    Icons.thermostat,
                    size: 100,
                    color: Colors.white,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          "${controller.latestTemperature}",
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        "˚C",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              children: [
                const Text(
                  "Grafik Realtime",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Obx(
                    () => LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: controller.temperatureStream
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                    entry.key.toDouble(), entry.value.value))
                                .toList(),
                            isCurved: true,
                            color: Colors.blue,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: bottomTitleWidgets,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipBgColor: Colors.grey.shade300,
                            getTooltipItems:
                                (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map(
                                (barSpot) {
                                  return LineTooltipItem(
                                    '${barSpot.y.toStringAsFixed(2)}˚C',
                                    const TextStyle(color: Colors.blue),
                                  );
                                },
                              ).toList();
                            },
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        minX: 0,
                        maxX:
                            controller.temperatureStream.length.toDouble() - 1,
                        minY: 25,
                        maxY: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
