class UniversityListResponse {
  final List<University> items;
  final int page;
  final int pageSize;
  final int total;
  final int pages;

  const UniversityListResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.pages,
  });

  factory UniversityListResponse.fromJson(Map<String, dynamic> json) {
    return UniversityListResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => University.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
    );
  }
}

class University {
  final int sourceId;
  final String name;
  final String? detailUrl;
  final String? logoUrl;
  final String? region;
  final String? ownership;
  final String? category;
  final int? foundedYear;
  final String? phone;
  final String? website;
  final String? email;
  final String? address;
  final List<UniversityMetric> metrics;
  final List<EducationDirection> directions;
  final List<StudentBreakdown> studentBreakdowns;
  final List<SurveyResult> surveys;
  final List<Accreditation> accreditations;
  final List<AccreditationProgram> programs;

  const University({
    required this.sourceId,
    required this.name,
    this.detailUrl,
    this.logoUrl,
    this.region,
    this.ownership,
    this.category,
    this.foundedYear,
    this.phone,
    this.website,
    this.email,
    this.address,
    this.metrics = const [],
    this.directions = const [],
    this.studentBreakdowns = const [],
    this.surveys = const [],
    this.accreditations = const [],
    this.programs = const [],
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      sourceId: json['source_id'] as int,
      name: json['name'] as String? ?? '',
      detailUrl: json['detail_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      region: json['region'] as String?,
      ownership: json['ownership'] as String?,
      category: json['category'] as String?,
      foundedYear: json['founded_year'] as int?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map(
            (item) => UniversityMetric.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      directions: (json['directions'] as List<dynamic>? ?? [])
          .map(
            (item) => EducationDirection.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      studentBreakdowns: (json['student_breakdowns'] as List<dynamic>? ?? [])
          .map(
            (item) => StudentBreakdown.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      surveys: (json['surveys'] as List<dynamic>? ?? [])
          .map((item) => SurveyResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      accreditations: (json['accreditations'] as List<dynamic>? ?? [])
          .map((item) => Accreditation.fromJson(item as Map<String, dynamic>))
          .toList(),
      programs: (json['programs'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AccreditationProgram.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  List<UniversityMetric> get visibleMetrics {
    return metrics.where((metric) => metric.hasDisplayableValue).toList();
  }

  String? metricValue(String key) {
    for (final metric in visibleMetrics) {
      if (metric.key == key) return metric.value;
    }
    return null;
  }

  List<UniversityMetric> metricsForSection(String section) {
    return visibleMetrics
        .where((metric) => metric.section == section)
        .toList(growable: false);
  }

  List<UniversityMetric> get educationTypes =>
      metricsForSection('education_type');

  List<UniversityMetric> get ratingScores => metricsForSection('rating_score');

  Map<String, List<SurveyResult>> get surveysByGroup {
    final grouped = <String, List<SurveyResult>>{};
    for (final survey in surveys) {
      final group = survey.group.trim().isEmpty
          ? 'Survey'
          : survey.group.trim();
      grouped.putIfAbsent(group, () => <SurveyResult>[]).add(survey);
    }
    return grouped;
  }
}

class UniversityMetric {
  final String section;
  final String key;
  final String? value;
  final String? unit;
  final String? measuredAt;

  const UniversityMetric({
    required this.section,
    required this.key,
    this.value,
    this.unit,
    this.measuredAt,
  });

  factory UniversityMetric.fromJson(Map<String, dynamic> json) {
    return UniversityMetric(
      section: json['section'] as String? ?? '',
      key: json['key'] as String? ?? '',
      value: json['value']?.toString(),
      unit: json['unit'] as String?,
      measuredAt: json['measured_at'] as String?,
    );
  }

  bool get hasDisplayableValue {
    return isDisplayableSourceValue(value);
  }
}

bool isDisplayableSourceValue(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty || normalized == '-') {
    return false;
  }

  final lower = normalized.toLowerCase();
  if (RegExp(
    r'^#(?:null!|div/0!|value!|ref!|name\?|num!|n/a|getting_data)$',
  ).hasMatch(lower)) {
    return false;
  }
  if (lower.contains('tez kunda') ||
      lower.contains('soon') ||
      lower.contains('blur') ||
      lower.contains('asdad') ||
      lower.contains('adada')) {
    return false;
  }

  final compact = normalized.replaceAll(RegExp(r'\s+'), '');
  if (RegExp(r'^\d{10,}$').hasMatch(compact)) {
    return false;
  }

  return true;
}

class EducationDirection {
  final String name;
  final int? value;
  final double? percent;

  const EducationDirection({required this.name, this.value, this.percent});

  factory EducationDirection.fromJson(Map<String, dynamic> json) {
    return EducationDirection(
      name: json['name'] as String? ?? '',
      value: (json['value'] as num?)?.toInt(),
      percent: (json['percent'] as num?)?.toDouble(),
    );
  }
}

class StudentBreakdown {
  final String label;
  final String? value;

  const StudentBreakdown({required this.label, this.value});

  factory StudentBreakdown.fromJson(Map<String, dynamic> json) {
    return StudentBreakdown(
      label: json['label'] as String? ?? '',
      value: json['value']?.toString(),
    );
  }
}

class SurveyResult {
  final String group;
  final int? year;
  final String question;
  final double? positivePercent;
  final double? negativePercent;

  const SurveyResult({
    required this.group,
    this.year,
    required this.question,
    this.positivePercent,
    this.negativePercent,
  });

  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    return SurveyResult(
      group: json['group'] as String? ?? '',
      year: json['year'] as int?,
      question: json['question'] as String? ?? '',
      positivePercent: (json['positive_percent'] as num?)?.toDouble(),
      negativePercent: (json['negative_percent'] as num?)?.toDouble(),
    );
  }
}

class Accreditation {
  final String accreditationType;
  final String? status;
  final String? certificateNumber;
  final String? issuedDate;
  final String? expiresDate;
  final String? certificateUrl;
  final bool isCompleted;

  const Accreditation({
    required this.accreditationType,
    this.status,
    this.certificateNumber,
    this.issuedDate,
    this.expiresDate,
    this.certificateUrl,
    this.isCompleted = false,
  });

  factory Accreditation.fromJson(Map<String, dynamic> json) {
    return Accreditation(
      accreditationType: json['accreditation_type'] as String? ?? '',
      status: json['status'] as String?,
      certificateNumber: json['certificate_number'] as String?,
      issuedDate: json['issued_date'] as String?,
      expiresDate: json['expires_date'] as String?,
      certificateUrl: json['certificate_url'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

class AccreditationProgram {
  final String programType;
  final String? code;
  final String? name;
  final String? country;
  final String? certificate;

  const AccreditationProgram({
    required this.programType,
    this.code,
    this.name,
    this.country,
    this.certificate,
  });

  factory AccreditationProgram.fromJson(Map<String, dynamic> json) {
    return AccreditationProgram(
      programType: json['program_type'] as String? ?? '',
      code: json['code'] as String?,
      name: json['name'] as String?,
      country: json['country'] as String?,
      certificate: json['certificate'] as String?,
    );
  }
}
