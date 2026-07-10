import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../universities/models/university.dart';
import 'accreditation_section.dart';
import 'buildings_facilities_section.dart';
import 'charts/distribution_by_programs_chart.dart';
import 'charts/rounded_pie_chart.dart';
import 'charts/student_distribution_chart.dart';
import 'institute_summary_card.dart';
import 'international_activity_section.dart';
import 'national_rating_section.dart';
import 'professors_composition_section.dart';
import 'scientific_potential_section.dart';
import 'specialization_section.dart';
import 'student_contingent_section.dart';
import 'survey_results_section.dart';
import 'sheets/survey_results_sheet.dart';
import 'total_students_section.dart';
import 'types_of_education_section.dart';

class UniversityDashboardContent extends StatelessWidget {
  const UniversityDashboardContent({super.key, required this.university});

  final University university;

  static const _chartColors = [
    AppColors.primary,
    Color(0xFF18E5E7),
    AppColors.accent,
    Color(0xFFFF986B),
    Color(0xFF8B7CF6),
  ];

  static const _studentLevels = ['Bakalavr', 'Magistratura', 'Doktorantura'];

  static const _educationLabels = [
    'Kunduzgi',
    'Masofaviy',
    'Sirtqi',
    'Kechki',
    'Ikkinchi oliy',
  ];

  static const _scienceLabels = [
    'Ilmiy dajali kadrlar ulushi',
    'Ilmiy grantlar hajmi',
    'Xalqaro va milliy ilmiy loyihalar soni',
    'Spin-off korxonalar aylanmasi',
    'Spin-off korxonalar soni',
    'Patentlar soni',
  ];

  static const _scopusLabels = [
    'Top 1%',
    'Top 10%',
    'Toifasiz',
    'Q1',
    'Q2',
    'Q3',
    'Q4',
  ];

  @override
  Widget build(BuildContext context) {
    final total = _metricValue('summary', ['Jami talabalar']);
    final bachelor = _breakdownValue('Bakalavr');
    final master = _breakdownValue('Magistratura');

    final sections = <Widget>[
      InstituteSummaryCard(
        name: university.name,
        items: [
          InstituteInfoItem(
            value: _textOrDash(university.ownership),
            label: 'Mulkchilik',
            icon: Iconsax.teacher,
          ),
          InstituteInfoItem(
            value: _textOrDash(university.region),
            label: 'Hudud',
            icon: Iconsax.location,
          ),
          InstituteInfoItem(
            value: university.foundedYear?.toString() ?? '—',
            label: 'Tashkil etilgan',
            icon: Iconsax.calendar,
          ),
        ],
      ),
    ];

    _add(
      sections,
      TotalStudentsSection(
        total: total,
        segments: [
          for (var index = 0; index < _studentLevels.length; index++)
            RoundedPieChartSegment(
              label: _studentLevels[index],
              value: _breakdownValue(_studentLevels[index]),
              amount: _number(_breakdownValue(_studentLevels[index])),
              color: _chartColors[index],
            ),
        ],
        professors: _metricValue('summary', [
          "Professor-o'qituvchilar",
          'Professor-o‘qituvchilar',
        ]),
        nationalRanking: _metricValue('summary', ['Milliy reyting']),
      ),
    );

    final specializationMetrics = university.metricsForSection(
      'specialization',
    );
    final specializationCategory = _valueByKey(
      specializationMetrics,
      'OTT toifasi',
    );
    final specializationPriority = _valueByKey(
      specializationMetrics,
      'Ustuvor yo’nalishlar',
    );
    _add(
      sections,
      SpecializationSection(
        date: specializationMetrics.firstOrNull?.measuredAt ?? '',
        items: [
          SpecializationItem(
            color: AppColors.accent,
            icon: Iconsax.building,
            eyebrow: 'OTT toifasi',
            title: specializationCategory,
          ),
          SpecializationItem(
            color: AppColors.primary,
            icon: Iconsax.book,
            eyebrow: 'Ustuvor yo‘nalishlar',
            title: specializationPriority,
          ),
        ],
        chart: DistributionByProgramsChart(
          items: [
            for (var index = 0; index < university.directions.length; index++)
              ProgramDistributionItem(
                label: university.directions[index].name,
                value:
                    '${_compact(university.directions[index].percent ?? 0)}%',
                amount: university.directions[index].percent ?? 0,
                color: _chartColors[index % _chartColors.length],
              ),
          ],
          totalValue: total,
          size: 220,
          gapWidth: 4,
          cornerRadius: 10,
          centerCornerRadius: 45,
        ),
      ),
    );

    final educationValues = <String, double>{
      for (final label in _educationLabels)
        label: label == 'Ikkinchi oliy'
            ? university.educationTypes
                  .where(
                    (metric) =>
                        _normalize(metric.key).contains('ikkinchi oliy'),
                  )
                  .fold(0, (sum, metric) => sum + _number(metric.value))
            : _number(_metricValue('education_type', [label])),
    };
    final educationTotal = educationValues.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    _add(
      sections,
      TypesOfEducationSection(
        date: university.educationTypes.firstOrNull?.measuredAt ?? '',
        cardTitle: 'Jami talabalar',
        showButton: false,
        items: [
          for (var index = 0; index < _educationLabels.length; index++)
            StudentDistributionChartItem(
              label: _educationLabels[index],
              value: _compact(educationValues[_educationLabels[index]] ?? 0),
              percent: educationTotal == 0
                  ? 0
                  : (educationValues[_educationLabels[index]] ?? 0) /
                        educationTotal *
                        100,
              color: _chartColors[index],
            ),
        ],
      ),
    );

    _add(
      sections,
      StudentContingentSection(
        date: university.educationTypes.firstOrNull?.measuredAt ?? '',
        total: total,
        bachelor: bachelor,
        master: master,
        compactMetrics: [
          StudentContingentMetric(
            value: _metricValue('student', ['Qabul qilinganlar']),
            label: 'Qabul qilinganlar',
          ),
          StudentContingentMetric(
            value: _metricValue('metric', ['Tamomlash darajasi']),
            label: 'Tamomlash darajasi',
          ),
          StudentContingentMetric(
            value: _metricValue('student', ['Bitiruvchilar soni']),
            label: 'Bitiruvchilar soni',
          ),
          StudentContingentMetric(
            value: _metricValue('student', [
              'Bitiruvchilar bandlik darajasi',
              'Bitiruvchilar sifat indeksi',
            ]),
            label: 'Bitiruvchilar bandlik darajasi',
          ),
        ],
        graduateQuality: _metricValue('student', [
          'Bitiruvchilar sifat indeksi',
        ]),
      ),
    );

    const staffSpecs = [
      ("Jami professor va o’qituvchilar soni", Iconsax.teacher),
      ('O’rtacha yosh', Iconsax.briefcase),
      ('Talaba/Professor o’qituvchi nisbati', Iconsax.people),
      ('Ilmiy darajali professor-o’qituvchilar', Iconsax.award),
    ];
    _add(
      sections,
      ProfessorsCompositionSection(
        date:
            university.metricsForSection('staff').firstOrNull?.measuredAt ?? '',
        items: [
          for (final spec in staffSpecs)
            ProfessorCompositionItem(
              icon: spec.$2,
              value: _metricValue('staff', [spec.$1]),
              label: spec.$1,
            ),
        ],
      ),
    );

    _add(
      sections,
      ScientificPotentialSection(
        metrics: [
          for (final label in _scienceLabels)
            ScientificPotentialMetric(
              value: _metricValue('metric', [label]),
              label: label,
            ),
        ],
        spinOffCount: _metricValue('rating', [
          'Scopusdagi maqolalar soni',
          'Scopusdagi maqolalar jami soni',
        ]),
        rankings: [
          for (final label in _scopusLabels)
            ScientificPotentialRanking(
              label: label,
              value: _metricValue('scopus_ranking', [label]),
            ),
        ],
      ),
    );

    _add(
      sections,
      SurveyResultsSection(
        items: [
          SurveyResultItem(
            label: 'Professorlar va o‘qituvchilar',
            data: _surveyData('Professorlar va o‘qituvchilar', [
              'professor',
              'o‘qituvchi',
            ]),
          ),
          SurveyResultItem(
            label: 'Talabalar',
            data: _surveyData('Talabalar', ['talaba']),
          ),
        ],
      ),
    );

    const internationalSpecs = [
      ('Xorijiy talabalar soni', AppColors.primary, Icons.public),
      (
        'Xorijiy professor-o‘qituvchilar soni',
        Color(0xFF0FAAA6),
        Icons.business_center_rounded,
      ),
      ('Qo‘shma dasturlar', Color(0xFF13747D), Icons.assignment_rounded),
    ];
    _add(
      sections,
      InternationalActivitySection(
        date:
            university
                .metricsForSection('international')
                .firstOrNull
                ?.measuredAt ??
            '',
        items: [
          for (final spec in internationalSpecs)
            InternationalActivityItem(
              value: _metricValue('international', [spec.$1]),
              label: spec.$1,
              color: spec.$2,
              icon: spec.$3,
            ),
        ],
      ),
    );

    const buildingSpecs = [
      ('O’quv binolari soni', Icons.apartment_rounded),
      ('O’quv binolari quvvati', Icons.article_rounded),
      ('Talabalar turar joylari soni', Icons.meeting_room_rounded),
      ('Talabalar turar joylari quvvati', Icons.domain_rounded),
    ];
    _add(
      sections,
      BuildingsFacilitiesSection(
        date:
            university
                .metricsForSection('infrastructure')
                .firstOrNull
                ?.measuredAt ??
            '',
        items: [
          for (final spec in buildingSpecs)
            BuildingFacilityItem(
              value: _metricValue('infrastructure', [spec.$1]),
              label: spec.$1,
              icon: spec.$2,
            ),
        ],
      ),
    );

    _add(sections, AccreditationSection(items: _accreditationItems()));

    _add(
      sections,
      NationalRatingSection(
        metrics: [
          NationalRatingMetric(
            value: _metricValue('rating', ['Milliy reytingdagi o’rni']),
            label: 'Milliy reytingdagi o‘rni',
            assetName: 'assets/icons/bachelor.svg',
            gradient: AppColors.blueGradient,
          ),
          NationalRatingMetric(
            value: _metricValue('rating', ['Umumiy ballar']),
            label: 'Umumiy ballar',
            assetName: 'assets/icons/master.svg',
            gradient: AppColors.accentGradient,
          ),
        ],
      ),
    );

    return Column(
      key: const ValueKey('selected-university-dashboard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  List<AccreditationItem> _accreditationItems() {
    return [
      _accreditationItem(AccreditationType.complexStateAccreditation),
      _accreditationItem(AccreditationType.specialStateAccreditation),
      _accreditationItem(AccreditationType.internationalAccreditation),
    ];
  }

  SurveyResultsData _surveyData(String title, List<String> aliases) {
    final normalizedAliases = aliases.map(_normalize).toList();
    final results = university.surveys.where((survey) {
      final group = _normalize(survey.group);
      return normalizedAliases.any(group.contains);
    });
    return SurveyResultsData(
      title: title,
      questions: [
        for (final result in results)
          SurveyQuestionResult(
            question: result.question,
            positiveLabel: 'Ijobiy',
            positivePercent: result.positivePercent ?? 0,
            negativeLabel: 'Salbiy',
            negativePercent: result.negativePercent ?? 0,
          ),
      ],
    );
  }

  AccreditationItem _accreditationItem(AccreditationType type) {
    Accreditation? source;
    for (final accreditation in university.accreditations) {
      if (_typeFor(accreditation.accreditationType) == type) {
        source = accreditation;
        break;
      }
    }
    final programType = type == AccreditationType.specialStateAccreditation
        ? 'special'
        : 'foreign';
    final programCount = university.programs
        .where((program) => program.programType == programType)
        .length;
    final completed =
        source?.isCompleted == true ||
        (type != AccreditationType.complexStateAccreditation &&
            programCount > 0);

    return AccreditationItem(
      type: type,
      status: completed
          ? AccreditationStatus.completed
          : AccreditationStatus.pending,
      pendingSteps: [
        AccreditationStep(label: 'Holati:', value: _textOrZero(source?.status)),
      ],
      statusText: source?.status,
      certificateNumber: source?.certificateNumber,
      givenDate: source?.issuedDate,
      validUntil: source?.expiresDate,
      certificateUrl: source?.certificateUrl,
      accreditedProgramsCount: programCount.toString(),
    );
  }

  void _add(List<Widget> sections, Widget section) {
    sections
      ..add(const SizedBox(height: 56))
      ..add(section);
  }

  String _metricValue(String section, List<String> aliases) {
    final metrics = university.metricsForSection(section);
    for (final alias in aliases) {
      final normalizedAlias = _normalize(alias);
      for (final metric in metrics) {
        if (_normalize(metric.key) == normalizedAlias &&
            isDisplayableSourceValue(metric.value)) {
          return metric.value!.trim();
        }
      }
    }
    return '0';
  }

  String _valueByKey(List<UniversityMetric> metrics, String key) {
    final normalizedKey = _normalize(key);
    for (final metric in metrics) {
      if (_normalize(metric.key) == normalizedKey &&
          isDisplayableSourceValue(metric.value)) {
        return metric.value!.trim();
      }
    }
    return '0';
  }

  String _breakdownValue(String label) {
    final normalizedLabel = _normalize(label);
    for (final item in university.studentBreakdowns) {
      if (_normalize(item.label) == normalizedLabel &&
          isDisplayableSourceValue(item.value)) {
        return item.value!.trim();
      }
    }
    return '0';
  }

  String _textOrDash(String? value) =>
      isDisplayableSourceValue(value) ? value!.trim() : '—';

  String _textOrZero(String? value) =>
      isDisplayableSourceValue(value) ? value!.trim() : '0';

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll('‘', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  double _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  String _compact(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  AccreditationType _typeFor(String value) {
    final normalized = _normalize(value);
    if (normalized.contains('international') ||
        normalized.contains('foreign') ||
        normalized.contains('xorij')) {
      return AccreditationType.internationalAccreditation;
    }
    if (normalized.contains('special') || normalized.contains('maxsus')) {
      return AccreditationType.specialStateAccreditation;
    }
    return AccreditationType.complexStateAccreditation;
  }
}
