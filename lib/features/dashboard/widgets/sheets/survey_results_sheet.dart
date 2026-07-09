import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/app_silver_box.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../charts/rounded_pie_chart.dart';
import '../dashboard_section_card.dart';

class SurveyResultsSheet extends StatelessWidget {
  const SurveyResultsSheet({super.key, required this.assetPath});

  static const professorsAssetPath =
      'assets/data/survey/professors_survey_results.json';

  static const studentsAssetPath =
      'assets/data/survey/students_survey_results.json';

  final String assetPath;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String assetPath,
  }) {
    return showDashboardModalSheet<T>(
      context: context,
      title: title,
      direction: DashboardModalSheetDirection.bottom,
      background: DashboardModalSheetBackground.gradient,
      type: DashboardModalSheetType.fullScreen,
      child: SurveyResultsSheet(assetPath: assetPath),
    );
  }

  Future<SurveyResultsData> _loadData() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return SurveyResultsData.fromJson(decoded);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SurveyResultsData>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CupertinoActivityIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              'Maʼlumotlarni yuklashda xatolik yuz berdi',
              style: DashboardTextStyles.text(
                fontSize: 15,
                weight: FontWeight.w700,
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            for (var index = 0; index < data.questions.length; index++)
              AppSliverBox(
                top: index == 0 ? 144 : 14,
                bottom: index == data.questions.length - 1 ? 40 : 0,
                left: 26,
                right: 26,
                child: SurveyQuestionResultCard(
                  number: index + 1,
                  question: data.questions[index],
                ),
              ),
          ],
        );
      },
    );
  }
}

class SurveyResultsData {
  const SurveyResultsData({required this.title, required this.questions});

  final String title;
  final List<SurveyQuestionResult> questions;

  factory SurveyResultsData.fromJson(Map<String, dynamic> json) {
    return SurveyResultsData(
      title: json['title'] as String? ?? '',
      questions: ((json['questions'] as List?) ?? const []).map((item) {
        return SurveyQuestionResult.fromJson(item as Map<String, dynamic>);
      }).toList(),
    );
  }
}

class SurveyQuestionResult {
  const SurveyQuestionResult({
    required this.question,
    required this.positiveLabel,
    required this.positivePercent,
    required this.negativeLabel,
    required this.negativePercent,
  });

  final String question;
  final String positiveLabel;
  final double positivePercent;
  final String negativeLabel;
  final double negativePercent;

  factory SurveyQuestionResult.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionResult(
      question: json['question'] as String? ?? '',
      positiveLabel: json['positive_label'] as String? ?? 'Ijobiy',
      positivePercent: (json['positive_percent'] as num?)?.toDouble() ?? 0,
      negativeLabel: json['negative_label'] as String? ?? 'Salbiy',
      negativePercent: (json['negative_percent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SurveyQuestionResultCard extends StatelessWidget {
  const SurveyQuestionResultCard({
    super.key,
    required this.number,
    required this.question,
  });

  final int number;
  final SurveyQuestionResult question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18E5E7).withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ${question.question}',
            style: DashboardTextStyles.text(
              fontSize: 11,
              weight: FontWeight.w700,
              height: 1.14,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              SizedBox(
                width: 72,
                child: Center(
                  child: SurveyRatioDonut(
                    positivePercent: question.positivePercent,
                    negativePercent: question.negativePercent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SurveyAnswerRatioTile.positive(
                        percent: question.positivePercent,
                        label: question.positiveLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SurveyAnswerRatioTile.negative(
                        percent: question.negativePercent,
                        label: question.negativeLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SurveyRatioDonut extends StatelessWidget {
  const SurveyRatioDonut({
    super.key,
    required this.positivePercent,
    required this.negativePercent,
    this.size = 64,
    this.strokeWidth = 12,
    this.positiveColor = const Color(0xFF23D081),
    this.negativeColor = const Color(0xFFF23035),
  });

  final double positivePercent;
  final double negativePercent;
  final double size;
  final double strokeWidth;
  final Color positiveColor;
  final Color negativeColor;

  @override
  Widget build(BuildContext context) {
    return RoundedPieChart(
      segments: [
        RoundedPieChartSegment(
          label: 'Ijobiy',
          value: '${positivePercent.toStringAsFixed(1)}%',
          amount: positivePercent,
          color: positiveColor,
        ),
        RoundedPieChartSegment(
          label: 'Salbiy',
          value: '${negativePercent.toStringAsFixed(1)}%',
          amount: negativePercent,
          color: negativeColor,
        ),
      ],
      size: size,
      strokeWidth: strokeWidth,
      gapDegree: 4,
      startDegreeOffset: -90,
      showCenterValue: false,
      showLegend: false,
    );
  }
}

class SurveyAnswerRatioTile extends StatelessWidget {
  const SurveyAnswerRatioTile({
    super.key,
    required this.percent,
    required this.label,
    required this.color,
    required this.icon,
  });

  const SurveyAnswerRatioTile.positive({
    super.key,
    required this.percent,
    required this.label,
  }) : color = const Color(0xFF23D081),
       icon = CupertinoIcons.checkmark;

  const SurveyAnswerRatioTile.negative({
    super.key,
    required this.percent,
    required this.label,
  }) : color = const Color(0xFFF23035),
       icon = CupertinoIcons.xmark;

  final double percent;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 10),
            ),
            const SizedBox(width: 7),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: DashboardTextStyles.text(
                    fontSize: 13,
                    weight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardTextStyles.text(
                    fontSize: 10,
                    weight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
