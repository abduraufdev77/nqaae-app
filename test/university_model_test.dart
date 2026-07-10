import 'package:flutter_test/flutter_test.dart';
import 'package:nqaae_app/features/universities/models/university.dart';

void main() {
  test('spreadsheet error tokens are not displayable source values', () {
    expect(isDisplayableSourceValue('#VALUE!'), isFalse);
    expect(isDisplayableSourceValue('#N/A'), isFalse);
    expect(isDisplayableSourceValue('#REF!'), isFalse);
    expect(isDisplayableSourceValue('#DIV/0!'), isFalse);
  });

  test('parses university detail json', () {
    final university = University.fromJson({
      'source_id': 89,
      'name': 'Muhammad al-Xorazmiy universiteti',
      'region': 'Samarqand viloyati',
      'ownership': 'Davlat',
      'metrics': [
        {'section': 'summary', 'key': 'Jami talabalar', 'value': '3636'},
      ],
      'directions': [
        {'name': 'Amaliy fanlar', 'percent': 52},
      ],
      'surveys': [
        {
          'group': 'Talabalar',
          'year': 2026,
          'question': 'Taʼlim sifatini qanday baholaysiz?',
          'positive_percent': 95.7,
          'negative_percent': 4.3,
        },
      ],
      'accreditations': [
        {
          'accreditation_type': 'complex',
          'status': "Akkreditatsiyadan o'tgan",
          'is_completed': true,
          'certificate_number': 'OT №123',
          'certificate_url': 'https://nqaae.uz/certificate.pdf',
        },
      ],
    });

    expect(university.sourceId, 89);
    expect(university.region, 'Samarqand viloyati');
    expect(university.metrics.single.key, 'Jami talabalar');
    expect(university.directions.single.percent, 52);
    expect(university.surveys.single.positivePercent, 95.7);
    expect(university.accreditations.single.isCompleted, isTrue);
    expect(
      university.accreditations.single.certificateUrl,
      'https://nqaae.uz/certificate.pdf',
    );
  });

  test('filters source soon and placeholder metrics from display data', () {
    final university = University(
      sourceId: 89,
      name: 'Test university',
      metrics: const [
        UniversityMetric(
          section: 'summary',
          key: 'Jami talabalar',
          value: '3636',
        ),
        UniversityMetric(
          section: 'staff',
          key: 'Jami professor va o’qituvchilar soni',
          value: '123123123142',
        ),
        UniversityMetric(section: 'rating', key: 'Milliy reyting', value: ''),
        UniversityMetric(
          section: 'science',
          key: 'Patentlar soni',
          value: 'Tez kunda',
        ),
        UniversityMetric(
          section: 'science',
          key: 'Spin-off',
          value: '541asdadada',
        ),
      ],
    );

    expect(university.visibleMetrics.map((metric) => metric.key), [
      'Jami talabalar',
    ]);
    expect(university.metricValue('Jami talabalar'), '3636');
    expect(university.metricValue('Patentlar soni'), isNull);
  });

  test('groups survey results by group name in source order', () {
    final university = University(
      sourceId: 89,
      name: 'Test university',
      surveys: const [
        SurveyResult(
          group: "Professor-o’qituvchilar",
          year: 2026,
          question: 'Question 1',
          positivePercent: 89.2,
          negativePercent: 10.8,
        ),
        SurveyResult(
          group: 'Talabalar',
          year: 2026,
          question: 'Question 2',
          positivePercent: 95.7,
          negativePercent: 4.3,
        ),
        SurveyResult(
          group: "Professor-o’qituvchilar",
          year: 2026,
          question: 'Question 3',
          positivePercent: 90.8,
          negativePercent: 9.2,
        ),
      ],
    );

    final grouped = university.surveysByGroup;

    expect(grouped.keys.toList(), ["Professor-o’qituvchilar", 'Talabalar']);
    expect(grouped["Professor-o’qituvchilar"]!.length, 2);
    expect(grouped['Talabalar']!.single.negativePercent, 4.3);
  });
}
