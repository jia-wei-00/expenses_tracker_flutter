import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesChart extends StatefulWidget {
  const ExpensesChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExpensesChartState();
}

List<Map<String, dynamic>> calculation(List<Expense> expenses) {
  num food = 0;
  num transport = 0;
  num health = 0;
  num entertain = 0;
  num living = 0;
  num household = 0;
  num others = 0;

  if (expenses.isNotEmpty) {
    final incomeExpenses = expenses.where((e) => e.type == "expense");
    if (incomeExpenses.isEmpty) return [];

    incomeExpenses.forEach((e) {
      switch (e.category) {
        case "Food":
          food += num.parse(e.amount);
          break;
        case "Transportation":
          transport += num.parse(e.amount);
          break;
        case "Healthcare":
          health += num.parse(e.amount);
          break;
        case "Entertainment":
          entertain += num.parse(e.amount);
          break;
        case "Living":
          living += num.parse(e.amount);
          break;
        case "Household":
          household += num.parse(e.amount);
          break;
        case "Others":
          others += num.parse(e.amount);
          break;
        default:
          break;
      }
    });

    final result = <Map<String, dynamic>>[];

    if (food > 0) {
      result.add({
        "type": "Food",
        "percentage": food.toStringAsFixed(2),
        "color": Colors.blue,
      });
    }

    if (transport > 0) {
      result.add({
        "type": "Transportation",
        "percentage": transport.toStringAsFixed(2),
        "color": Colors.black,
      });
    }

    if (health > 0) {
      result.add({
        "type": "Healthcare",
        "percentage": health.toStringAsFixed(2),
        "color": Colors.green,
      });
    }

    if (entertain > 0) {
      result.add({
        "type": "Entertainment",
        "percentage": entertain.toStringAsFixed(2),
        "color": Colors.orange,
      });
    }

    if (living > 0) {
      result.add({
        "type": "Living",
        "percentage": living.toStringAsFixed(2),
        "color": Colors.purple,
      });
    }

    if (household > 0) {
      result.add({
        "type": "Household",
        "percentage": household.toStringAsFixed(2),
        "color": Colors.brown,
      });
    }

    if (others > 0) {
      result.add({
        "type": "Others",
        "percentage": others.toStringAsFixed(2),
        "color": Colors.red,
      });
    }

    return result;
  } else {
    return [];
  }
}

class ExpensesChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expensesHistoryBloc = context.watch<ExpensesHistoryBloc>();

    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections(calculation(expensesHistoryBloc.state)),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(List data) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      final item = data[i];
      final value = item['percentage'] as String;
      final title = 'RM$value';
      final type = item['type'] as String;
      final color = item['color'] as Color;
      IconData iconData;

      switch (type) {
        case 'Entertainment':
          iconData = Icons.gamepad_rounded;
          break;
        case 'Food':
          iconData = Icons.restaurant_menu_rounded;
          break;
        case 'Healthcare':
          iconData = Icons.medication_rounded;
          break;
        case 'Transportation':
          iconData = Icons.local_gas_station_rounded;
          break;
        case 'Living':
          iconData = Icons.living_rounded;
          break;
        case 'Household':
          iconData = Icons.house_rounded;
          break;
        case 'Others':
          iconData = Icons.question_mark_rounded;
          break;
        default:
          throw Exception('Invalid type: $type');
      }

      return PieChartSectionData(
        color: color,
        value: double.parse(value),
        title: title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgeWidget: _Badge(
          iconData,
          size: widgetSize,
          borderColor: Colors.black,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });
  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size - 10,
        color: Colors.black,
      ),
    );
  }
}
