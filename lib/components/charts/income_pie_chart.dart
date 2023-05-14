import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncomeChart extends StatefulWidget {
  const IncomeChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IncomeChartState();
}

List<Map<String, dynamic>> calculation(List<Expense> income) {
  double salary = 0;
  double others = 0;

  if (income.isNotEmpty) {
    final incomeExpenses = income.where((e) => e.type == "income");
    if (incomeExpenses.isEmpty) return [];

    incomeExpenses.forEach((e) {
      switch (e.category) {
        case "Salary":
          salary += double.parse(e.amount);
          break;
        case "Others":
          others += double.parse(e.amount);
          break;
        default:
          break;
      }
    });

    final result = <Map<String, dynamic>>[];

    if (salary > 0) {
      result.add({
        "type": "Salary",
        "percentage": salary.toStringAsFixed(2),
        "color": Colors.orange,
      });
    }

    if (others > 0) {
      result.add({
        "type": "Others",
        "percentage": others.toStringAsFixed(2),
        "color": Colors.black,
      });
    }

    return result;
  } else {
    return [];
  }
}

class IncomeChartState extends State {
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
        case 'Salary':
          iconData = Icons.attach_money_rounded;
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
