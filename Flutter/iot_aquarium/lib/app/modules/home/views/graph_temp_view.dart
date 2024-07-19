import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controllers/temp_controller.dart';
import '../../../controllers/auth_controller.dart';

class GraphTempView extends GetView {
  final authC = Get.find<AuthController>();
  final tempC = Get.find<TempController>();

  String textTitle(int value) {
    String text = tempC.temperatureStream.elementAt(value).key.toString();
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
        title: const Text("Temperature Graph"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => authC.logOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        children: [
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
                            spots: tempC.temperatureStream
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
                        maxX: tempC.temperatureStream.length.toDouble() - 1,
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
