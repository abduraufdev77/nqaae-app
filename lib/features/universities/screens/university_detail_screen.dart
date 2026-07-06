import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../models/university.dart';
import '../providers/university_providers.dart';
import '../widgets/nqaae_ui.dart';

const _sectionDate = '01.07.2026';

class UniversityDetailScreen extends ConsumerWidget {
  const UniversityDetailScreen({super.key, required this.sourceId});

  final int sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(universityDetailProvider(sourceId));

    return Scaffold(
      backgroundColor: NqaaeColors.page,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Oliy ta'lim tashkilotlari",
          style: GoogleFonts.openSans(
            color: NqaaeColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ),
      body: NqaaeBackground(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _StateMessage(
            icon: Icons.cloud_off_rounded,
            title: 'Backend data unavailable',
            message: error.toString(),
          ),
          data: (university) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
            children: [
              _Breadcrumb(university: university),
              const SizedBox(height: 16),
              _UniversityHero(university: university),
              const SizedBox(height: 18),
              _SummaryBand(university: university),
              const SizedBox(height: 22),
              _SpecializationSection(university: university),
              const SizedBox(height: 22),
              _DirectionsSection(university: university),
              const SizedBox(height: 22),
              _EducationTypesSection(university: university),
              const SizedBox(height: 22),
              _StudentContingentSection(university: university),
              const SizedBox(height: 22),
              _StaffSection(university: university),
              const SizedBox(height: 22),
              _ScienceSection(university: university),
              const SizedBox(height: 22),
              _RatingHighlightSection(university: university),
              const SizedBox(height: 22),
              _SurveySection(university: university),
              const SizedBox(height: 22),
              _InternationalSection(university: university),
              const SizedBox(height: 22),
              _InfrastructureSection(university: university),
              const SizedBox(height: 22),
              _AccreditationSection(university: university),
              const SizedBox(height: 22),
              _NationalRatingSection(university: university),
              const SizedBox(height: 22),
              _ContactsSection(university: university),
            ],
          ),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ochiq ma'lumotlar / Ta'lim tashkilotlari ro'yxati",
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: NqaaeColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          university.name,
          style: GoogleFonts.openSans(
            color: NqaaeColors.text,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.14,
          ),
        ),
      ],
    );
  }
}

class _UniversityHero extends StatelessWidget {
  const _UniversityHero({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 174,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF08234D),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -26,
                  right: -24,
                  child: Icon(
                    Icons.auto_awesome_motion_rounded,
                    size: 118,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Center(
                  child: NqaaeLogo(
                    sourceId: university.sourceId,
                    hasLogo: university.logoUrl != null,
                    fallback: university.name,
                    size: 138,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            university.name,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1.32,
            ),
          ),
          const SizedBox(height: 22),
          _HeroInfoRow(
            icon: Icons.account_balance_rounded,
            label: 'Mulkchilik shakli',
            value: university.ownership,
          ),
          const SizedBox(height: 14),
          _HeroInfoRow(
            icon: Icons.map_rounded,
            label: 'Hudud',
            value: university.region,
          ),
          const SizedBox(height: 14),
          _HeroInfoRow(
            icon: Icons.event_available_rounded,
            label: 'Tashkil etilgan yil',
            value: university.foundedYear?.toString(),
          ),
        ],
      ),
    );
  }
}

class _HeroInfoRow extends StatelessWidget {
  const _HeroInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (!isDisplayableSourceValue(value)) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NqaaeColors.teal.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _RaisedIcon(icon: icon, color: NqaaeColors.teal, size: 62),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.openSans(
                    color: NqaaeColors.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value!.trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
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

class _SummaryBand extends StatelessWidget {
  const _SummaryBand({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricSpec(
        icon: Icons.school_rounded,
        label: 'Jami talabalar',
        value: university.metricValue('Jami talabalar'),
      ),
      _MetricSpec(
        icon: Icons.medical_services_rounded,
        label: "Professor-o'qituvchilar",
        value: university.metricValue("Professor-o'qituvchilar"),
      ),
      _MetricSpec(
        icon: Icons.star_rounded,
        label: 'Milliy reyting',
        value: university.metricValue('Milliy reyting'),
      ),
    ].where((item) => isDisplayableSourceValue(item.value)).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: NqaaeColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SummaryItem(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.item});

  final _MetricSpec item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RaisedIcon(icon: item.icon, color: NqaaeColors.blue, size: 64),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  color: NqaaeColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  color: NqaaeColors.muted,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpecializationSection extends StatelessWidget {
  const _SpecializationSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final metrics = university.metricsForSection('specialization');
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Ixtisoslashuv'),
        _GradientPanel(
          child: Column(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                _GradientInfoBlock(
                  icon: i == 0
                      ? Icons.account_balance_rounded
                      : Icons.menu_book_rounded,
                  label: metrics[i].key,
                  value: metrics[i].value!,
                ),
                if (i != metrics.length - 1)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.28),
                    height: 28,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DirectionsSection extends StatelessWidget {
  const _DirectionsSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final directions = university.directions
        .where((item) => item.percent != null && item.percent! > 0)
        .toList(growable: false);
    if (directions.isEmpty) return const SizedBox.shrink();

    return _WhiteCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: -0.18,
                child: const Icon(
                  Icons.article_rounded,
                  color: NqaaeColors.teal,
                  size: 36,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Ta'lim yo'nalishlari tarkibi",
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(height: 420, child: _DonutChart(directions: directions)),
        ],
      ),
    );
  }
}

class _EducationTypesSection extends StatelessWidget {
  const _EducationTypesSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final items = university.educationTypes;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "Ta'lim turlari boyicha"),
        _WhiteCard(
          child: SizedBox(
            height: 350,
            child: _AreaChart(
              items: items
                  .map(
                    (item) => _ChartPoint(
                      label: item.key,
                      value: _numeric(item.value),
                    ),
                  )
                  .where((item) => item.value > 0)
                  .toList(),
              valueSuffix: '',
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentContingentSection extends StatelessWidget {
  const _StudentContingentSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final breakdowns = university.studentBreakdowns
        .where((item) => isDisplayableSourceValue(item.value))
        .toList(growable: false);
    if (breakdowns.isEmpty) return const SizedBox.shrink();

    final degreeLabels = ['bakalavr', 'magistratura', 'doktorantura'];
    final degreeItems = breakdowns
        .where(
          (item) => degreeLabels.any(
            (label) => item.label.toLowerCase().contains(label),
          ),
        )
        .toList(growable: false);
    final extraItems = breakdowns
        .where((item) => !degreeItems.contains(item))
        .toList(growable: false);
    final total = degreeItems.fold<double>(
      0,
      (sum, item) => sum + _numeric(item.value),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Talabalar kontigenti'),
        if (degreeItems.isNotEmpty)
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RaisedIcon(
                      icon: Icons.groups_2_rounded,
                      color: NqaaeColors.teal,
                      size: 72,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatNumber(total),
                            style: GoogleFonts.openSans(
                              color: NqaaeColors.blue,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Jami talabalar',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 34),
                ...degreeItems.map(
                  (item) => _StudentBar(item: item, total: total),
                ),
              ],
            ),
          ),
        if (extraItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...extraItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PlainMetricCard(
                icon: _iconForLabel(item.label),
                label: item.label,
                value: item.value,
                iconColor: NqaaeColors.blue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StudentBar extends StatelessWidget {
  const _StudentBar({required this.item, required this.total});

  final StudentBreakdown item;
  final double total;

  @override
  Widget build(BuildContext context) {
    final value = _numeric(item.value);
    final percent = total <= 0 ? 0 : value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.openSans(
                    color: NqaaeColors.muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_dash(item.value)} (${(percent * 100).round()}%)',
                style: GoogleFonts.openSans(
                  color: percent > 0.35 ? NqaaeColors.teal : NqaaeColors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 1).toDouble(),
              minHeight: 38,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 0.35 ? NqaaeColors.teal : NqaaeColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffSection extends StatelessWidget {
  const _StaffSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final metrics = university.metricsForSection('staff');
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "Professor-o'qituvchilar tarkibi"),
        ...metrics.map(
          (metric) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _TopBorderMetricCard(
              icon: Icons.groups_rounded,
              label: metric.key,
              value: metric.value,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScienceSection extends StatelessWidget {
  const _ScienceSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final metrics = university.metricsForSection('metric');
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Ilmiy salohiyat'),
        ...metrics.map(
          (metric) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PlainMetricCard(
              icon: _iconForLabel(metric.key),
              label: metric.key,
              value: metric.value,
              iconColor: NqaaeColors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingHighlightSection extends StatelessWidget {
  const _RatingHighlightSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final scopus = university
        .metricsForSection('rating')
        .where((item) {
          return item.key.toLowerCase().contains('scopus');
        })
        .toList(growable: false);
    if (scopus.isEmpty) return const SizedBox.shrink();

    return _GradientPanel(
      child: Column(
        children: [
          _GradientInfoBlock(
            icon: Icons.workspace_premium_rounded,
            label: scopus.first.key,
            value: scopus.first.value!,
            large: true,
          ),
          const Divider(height: 30, color: Colors.white30),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: const [
              _StaticRatingMini(label: 'Top 1%', value: '0'),
              _StaticRatingMini(label: 'Top 10%', value: '0'),
              _StaticRatingMini(label: 'Q1', value: '4'),
              _StaticRatingMini(label: 'Q2', value: '2'),
              _StaticRatingMini(label: 'Q3', value: '2'),
              _StaticRatingMini(label: 'Q4', value: '22'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurveySection extends StatelessWidget {
  const _SurveySection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final groups = university.surveysByGroup;
    if (groups.isEmpty) return const SizedBox.shrink();
    final year = university.surveys
        .map((item) => item.year)
        .whereType<int>()
        .fold<int?>(null, (prev, next) {
          if (prev == null || next > prev) return next;
          return prev;
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Umummilliy so'rovnoma\nnatijalari",
          style: GoogleFonts.openSans(
            color: NqaaeColors.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.16,
          ),
        ),
        const SizedBox(height: 14),
        if (year != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFD),
              border: Border.all(color: NqaaeColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$year',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: NqaaeColors.blue,
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),
        const _GradientDivider(),
        const SizedBox(height: 16),
        ...groups.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _SurveyTile(title: entry.key, items: entry.value),
          ),
        ),
      ],
    );
  }
}

class _SurveyTile extends StatelessWidget {
  const _SurveyTile({required this.title, required this.items});

  final String title;
  final List<SurveyResult> items;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: _WhiteCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: GoogleFonts.openSans(
              color: NqaaeColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          trailing: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: NqaaeColors.blue,
              size: 32,
            ),
          ),
          children: items
              .map((item) => _SurveyQuestionCard(item: item))
              .toList(),
        ),
      ),
    );
  }
}

class _SurveyQuestionCard extends StatelessWidget {
  const _SurveyQuestionCard({required this.item});

  final SurveyResult item;

  @override
  Widget build(BuildContext context) {
    final positive = item.positivePercent ?? 0;
    final negative = item.negativePercent ?? math.max(0, 100 - positive);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: NqaaeColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 18,
              height: 1.18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const _GradientDivider(),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth > 430;
              final chart = SizedBox(
                width: horizontal ? 178 : 150,
                height: horizontal ? 178 : 150,
                child: CustomPaint(
                  painter: _SurveyDonutPainter(
                    positive: positive,
                    negative: negative,
                  ),
                ),
              );
              final values = Column(
                children: [
                  _SurveyPercentBox(
                    icon: Icons.check_rounded,
                    color: const Color(0xFF62A9A9),
                    background: const Color(0xFFEFF7F7),
                    percent: positive,
                    label: 'Ijobiy',
                  ),
                  const SizedBox(height: 12),
                  _SurveyPercentBox(
                    icon: Icons.close_rounded,
                    color: const Color(0xFFF36B61),
                    background: const Color(0xFFFFF1EE),
                    percent: negative,
                    label: 'Salbiy',
                  ),
                ],
              );
              if (!horizontal) {
                return Column(
                  children: [chart, const SizedBox(height: 18), values],
                );
              }
              return Row(
                children: [
                  chart,
                  const SizedBox(width: 22),
                  Expanded(child: values),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SurveyPercentBox extends StatelessWidget {
  const _SurveyPercentBox({
    required this.icon,
    required this.color,
    required this.background,
    required this.percent,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double percent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${_formatPercent(percent)}\n$label',
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InternationalSection extends StatelessWidget {
  const _InternationalSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final metrics = university.metricsForSection('international');
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Xalqaro faoliyat'),
        ...metrics.map(
          (metric) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _SoftBlueMetricCard(
              icon: _iconForLabel(metric.key),
              label: metric.key,
              value: metric.value,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfrastructureSection extends StatelessWidget {
  const _InfrastructureSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final metrics = university.metricsForSection('infrastructure');
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Bino va inshoatlar'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 620 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: columns == 2 ? 1.15 : 1.1,
              children: metrics
                  .map(
                    (metric) => _TealTile(
                      icon: Icons.apartment_rounded,
                      label: metric.key,
                      value: metric.value,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AccreditationSection extends StatelessWidget {
  const _AccreditationSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    if (university.accreditations.isEmpty && university.programs.isEmpty) {
      return const SizedBox.shrink();
    }

    final accreditation = university.accreditations.isNotEmpty
        ? university.accreditations.first
        : null;
    final specialPrograms = university.programs
        .where((item) => item.programType == 'special')
        .toList();
    final foreignPrograms = university.programs
        .where((item) => item.programType == 'foreign')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Akkreditatsiya'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: const [
              _AccreditationTab(
                text: 'Kompleks davlat akkreditatsiya',
                selected: true,
              ),
              _AccreditationTab(text: 'Maxsus davlat akkreditatsiya'),
              _AccreditationTab(text: 'Xorijiy akkreditatsiya'),
            ],
          ),
        ),
        if (accreditation != null) ...[
          const SizedBox(height: 22),
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kompleks davlat akkreditatsiya holati',
                  style: GoogleFonts.openSans(
                    color: NqaaeColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.10),
                    border: Border.all(color: NqaaeColors.teal, width: 1.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.check_rounded,
                          color: Color(0xFF8AC0C0),
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _dash(accreditation.status),
                        style: GoogleFonts.openSans(
                          color: NqaaeColors.teal,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AccreditationField(
                        label: 'Sertifikat raqami:',
                        value: accreditation.certificateNumber,
                      ),
                      _AccreditationField(
                        label: 'Berilgan sana:',
                        value: accreditation.issuedDate,
                      ),
                      _AccreditationField(
                        label: 'Amal qilish muddati:',
                        value: accreditation.expiresDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (specialPrograms.isNotEmpty || foreignPrograms.isNotEmpty) ...[
          const SizedBox(height: 22),
          _ProgramTableSection(
            title: "Maxsus davlat akkreditatsiyadan o'tgan ta'lim dasturlari",
            programs: specialPrograms.isNotEmpty
                ? specialPrograms
                : foreignPrograms,
          ),
        ],
      ],
    );
  }
}

class _ProgramTableSection extends StatelessWidget {
  const _ProgramTableSection({required this.title, required this.programs});

  final String title;
  final List<AccreditationProgram> programs;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.openSans(
              color: NqaaeColors.text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppColors.primary.withValues(alpha: 0.16),
                ),
                dataRowMinHeight: 70,
                dataRowMaxHeight: 96,
                columns: const [
                  DataColumn(label: Text("Ta'lim dasturi kodi")),
                  DataColumn(label: Text("Ta'lim dasturi nomi")),
                ],
                rows: programs
                    .map(
                      (program) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 100,
                              child: Text(_dash(program.code)),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 330,
                              child: Text(_dash(program.name)),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NationalRatingSection extends StatelessWidget {
  const _NationalRatingSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final scores = university.ratingScores;
    final visibleRating = university.metricsForSection('rating');
    if (scores.isEmpty && visibleRating.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "Milliy reyting ko'rsatkichlari"),
        if (visibleRating.isNotEmpty)
          _GradientPanel(
            child: Column(
              children: visibleRating
                  .map(
                    (metric) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _GradientInfoBlock(
                        icon: Icons.workspace_premium_rounded,
                        label: metric.key,
                        value: metric.value!,
                        large: true,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (scores.isNotEmpty) ...[
          const SizedBox(height: 18),
          _WhiteCard(
            child: SizedBox(
              height: 250,
              child: _AreaChart(
                items: scores
                    .map(
                      (item) => _ChartPoint(
                        label: item.key,
                        value: _numeric(item.value),
                      ),
                    )
                    .toList(),
                valueSuffix: ' ball',
                rotateLabels: false,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactsSection extends StatelessWidget {
  const _ContactsSection({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final contacts = [
      _MetricSpec(
        icon: Icons.phone_rounded,
        label: 'Telefon raqami',
        value: university.phone,
      ),
      _MetricSpec(
        icon: Icons.language_rounded,
        label: 'Rasmiy veb-sayt',
        value: university.website,
      ),
      _MetricSpec(
        icon: Icons.email_rounded,
        label: 'Elektron pochta',
        value: university.email,
      ),
      _MetricSpec(
        icon: Icons.location_city_rounded,
        label: 'Yuridik manzili',
        value: university.address,
      ),
    ].where((item) => isDisplayableSourceValue(item.value)).toList();

    if (contacts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "Bog'lanish va manzil", showDate: false),
        ...contacts.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ContactCard(item: item),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.item});

  final _MetricSpec item;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: NqaaeColors.blue, size: 36),
          ),
          const SizedBox(height: 24),
          Text(
            item.label,
            style: GoogleFonts.openSans(
              color: NqaaeColors.muted,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value!.trim(),
            softWrap: true,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.showDate = true});

  final String title;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.openSans(
                    color: NqaaeColors.text,
                    fontSize: 29,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (showDate)
                Text(
                  _sectionDate,
                  style: GoogleFonts.openSans(
                    color: NqaaeColors.blue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const _GradientDivider(),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return NqaaeSection(padding: padding, child: child);
  }
}

class _GradientPanel extends StatelessWidget {
  const _GradientPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: NqaaeColors.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _GradientInfoBlock extends StatelessWidget {
  const _GradientInfoBlock({
    required this.icon,
    required this.label,
    required this.value,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.16),
            size: large ? 88 : 116,
          ),
          Row(
            children: [
              _RaisedIcon(
                icon: icon,
                color: NqaaeColors.teal,
                size: large ? 76 : 64,
                outlined: true,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: large ? 22 : 17,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value.trim(),
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: large ? 32 : 24,
                        fontWeight: FontWeight.w900,
                        height: 1.16,
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

class _PlainMetricCard extends StatelessWidget {
  const _PlainMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NqaaeColors.border),
      ),
      child: Row(
        children: [
          _RaisedIcon(icon: icon, color: iconColor, size: 76),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dash(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.openSans(
                    color: NqaaeColors.muted,
                    fontSize: 18,
                    height: 1.14,
                    fontWeight: FontWeight.w800,
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

class _TopBorderMetricCard extends StatelessWidget {
  const _TopBorderMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 22),
          padding: const EdgeInsets.fromLTRB(18, 44, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: const Border(
              top: BorderSide(color: NqaaeColors.teal, width: 7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dash(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  color: NqaaeColors.muted,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.14,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 18,
          child: _RaisedIcon(icon: icon, color: NqaaeColors.teal, size: 76),
        ),
      ],
    );
  }
}

class _SoftBlueMetricCard extends StatelessWidget {
  const _SoftBlueMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 26),
          padding: const EdgeInsets.fromLTRB(24, 46, 24, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF8AB9EB), width: 1.4),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  icon,
                  color: NqaaeColors.blue.withValues(alpha: 0.11),
                  size: 72,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dash(value),
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 19,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 28,
          top: 0,
          child: _RaisedIcon(icon: icon, color: NqaaeColors.blue, size: 76),
        ),
      ],
    );
  }
}

class _TealTile extends StatelessWidget {
  const _TealTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NqaaeColors.teal,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.16),
              size: 74,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RaisedIcon(
                icon: icon,
                color: NqaaeColors.teal,
                size: 58,
                outlined: true,
              ),
              const Spacer(),
              Text(
                _dash(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.04,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RaisedIcon extends StatelessWidget {
  const _RaisedIcon({
    required this.icon,
    required this.color,
    required this.size,
    this.outlined = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: outlined
            ? Border.all(color: Colors.white.withValues(alpha: 0.48), width: 2)
            : Border.all(color: Colors.white.withValues(alpha: 0.28), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    );
  }
}

class _GradientDivider extends StatelessWidget {
  const _GradientDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(gradient: NqaaeColors.gradient),
    );
  }
}

class _AccreditationTab extends StatelessWidget {
  const _AccreditationTab({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          color: selected ? AppColors.darkBg : NqaaeColors.muted,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AccreditationField extends StatelessWidget {
  const _AccreditationField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (!isDisplayableSourceValue(value)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.openSans(
              color: NqaaeColors.muted,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value!,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticRatingMini extends StatelessWidget {
  const _StaticRatingMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.directions});

  final List<EducationDirection> directions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = math.min(constraints.maxWidth * 0.74, 250).toDouble();
        return Column(
          children: [
            SizedBox(
              width: chartSize,
              height: chartSize,
              child: CustomPaint(painter: _DonutPainter(directions)),
            ),
            const SizedBox(height: 18),
            ...directions.map(
              (direction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 64,
                      color: _chartColor(directions.indexOf(direction)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            direction.name,
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${direction.percent!.round()}%',
                            style: GoogleFonts.openSans(
                              color: NqaaeColors.muted,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.directions);

  final List<EducationDirection> directions;

  @override
  void paint(Canvas canvas, Size size) {
    final total = directions.fold<double>(
      0,
      (sum, item) => sum + (item.percent ?? 0),
    );
    if (total == 0) return;

    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (var i = 0; i < directions.length; i++) {
      final sweep = ((directions[i].percent ?? 0) / total) * math.pi * 2;
      paint.color = _chartColor(i);
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start,
        sweep - 0.035,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.directions != directions;
  }
}

class _AreaChart extends StatelessWidget {
  const _AreaChart({
    required this.items,
    required this.valueSuffix,
    this.rotateLabels = true,
  });

  final List<_ChartPoint> items;
  final String valueSuffix;
  final bool rotateLabels;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _AreaChartPainter(
        items: items,
        valueSuffix: valueSuffix,
        rotateLabels: rotateLabels,
      ),
      size: Size.infinite,
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.items,
    required this.valueSuffix,
    required this.rotateLabels,
  });

  final List<_ChartPoint> items;
  final String valueSuffix;
  final bool rotateLabels;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final maxValue = items.map((item) => item.value).fold<double>(0, math.max);
    final total = items.fold<double>(0, (sum, item) => sum + item.value);
    final left = 24.0;
    final right = size.width - 24;
    final top = 44.0;
    final bottom = size.height - (rotateLabels ? 76 : 40);
    final width = right - left;
    final height = bottom - top;
    final step = items.length == 1 ? 0.0 : width / (items.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < items.length; i++) {
      final x = items.length == 1 ? size.width / 2 : left + step * i;
      final visual = maxValue <= 0 ? 0.0 : items[i].value / maxValue;
      final y = bottom - math.max(0.12, visual) * height;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(left, bottom);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(right, bottom);
    path.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFABD8FF), Color(0x33ABD8FF)],
      ).createShader(Rect.fromLTRB(left, top, right, bottom));
    canvas.drawPath(path, fillPaint);

    final baseline = Paint()
      ..color = const Color(0xFFD9E7F0)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), baseline);

    final linePaint = Paint()
      ..color = NqaaeColors.blue
      ..strokeWidth = 1;
    final pointPaint = Paint()..color = const Color(0xFF184A68);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawLine(point, Offset(point.dx, bottom), linePaint);
      canvas.drawCircle(point, 7, pointPaint);

      final percent = total <= 0 ? 0.0 : (items[i].value / total) * 100;
      _paintText(
        canvas,
        rotateLabels
            ? '${_formatPercent(percent)}\n${_formatNumber(items[i].value)}'
            : '${_formatNumber(items[i].value)}$valueSuffix',
        Offset(point.dx, point.dy - 32),
        fontSize: rotateLabels ? 15 : 11,
        color: const Color(0xFF184A68),
        weight: FontWeight.w900,
        align: TextAlign.center,
      );

      canvas.save();
      final labelOffset = Offset(point.dx, bottom + (rotateLabels ? 42 : 24));
      canvas.translate(labelOffset.dx, labelOffset.dy);
      if (rotateLabels) canvas.rotate(-math.pi / 4);
      _paintText(
        canvas,
        items[i].label,
        Offset.zero,
        fontSize: rotateLabels ? 15 : 10,
        color: const Color(0xFF184A68),
        weight: FontWeight.w800,
        align: TextAlign.center,
      );
      canvas.restore();
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center, {
    required double fontSize,
    required Color color,
    required FontWeight weight,
    TextAlign align = TextAlign.start,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.openSans(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1.18,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: 130);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.valueSuffix != valueSuffix;
  }
}

class _SurveyDonutPainter extends CustomPainter {
  _SurveyDonutPainter({required this.positive, required this.negative});

  final double positive;
  final double negative;

  @override
  void paint(Canvas canvas, Size size) {
    final total = math.max(positive + negative, 1);
    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF62A9A9);
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      (positive / total) * math.pi * 2 - 0.12,
      false,
      paint,
    );
    paint.color = const Color(0xFFF36B61);
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2 + (positive / total) * math.pi * 2,
      (negative / total) * math.pi * 2 - 0.12,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SurveyDonutPainter oldDelegate) {
    return oldDelegate.positive != positive || oldDelegate.negative != negative;
  }
}

class _MetricSpec {
  const _MetricSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
}

class _ChartPoint {
  const _ChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _WhiteCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: NqaaeColors.teal, size: 42),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.openSans(
                  color: NqaaeColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: NqaaeColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForLabel(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('qabul')) return Icons.assignment_turned_in_rounded;
  if (lower.contains('tamom') || lower.contains('bitir')) {
    return Icons.school_rounded;
  }
  if (lower.contains('grant') || lower.contains('loyiha')) {
    return Icons.work_rounded;
  }
  if (lower.contains('patent')) return Icons.business_center_rounded;
  if (lower.contains('xorij')) return Icons.public_rounded;
  if (lower.contains('dastur')) return Icons.article_rounded;
  return Icons.groups_rounded;
}

Color _chartColor(int index) {
  const colors = [
    NqaaeColors.teal,
    Color(0xFF5197D8),
    NqaaeColors.gold,
    Color(0xFFE67E22),
    Color(0xFF8E6BBF),
  ];
  return colors[index % colors.length];
}

double _numeric(String? value) {
  if (value == null) return 0;
  final match = RegExp(r'\d+(?:[ .]\d+)*(?:\.\d+)?').firstMatch(value);
  final normalized =
      match?.group(0)?.replaceAll(' ', '').replaceAll(',', '') ?? '';
  return double.tryParse(normalized) ?? 0;
}

String _dash(String? value) {
  return isDisplayableSourceValue(value) ? value!.trim() : '-';
}

String _formatNumber(double value) {
  final rounded = value.round();
  final text = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
  }
  return buffer.toString();
}

String _formatPercent(double value) {
  final fixed = value.toStringAsFixed(
    value.truncateToDouble() == value ? 0 : 1,
  );
  return '$fixed%';
}
