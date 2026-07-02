import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userRole == 'admin';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, authState),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeBanner(authState, isAdmin),
                const SizedBox(height: 20),
                _buildStatCards(context, isAdmin),
                const SizedBox(height: 20),
                _buildChartSection(context),
                const SizedBox(height: 20),
                if (isAdmin) _buildUniversityList(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'NQAAE',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        GestureDetector(
          onTap: () => ref.read(authProvider.notifier).logout(),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner(AuthState authState, bool isAdmin) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textDarkSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.userName ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isAdmin ? AppColors.primary : AppColors.accent)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? '🛡️ Administrator' : '🏫 University Specialist',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isAdmin
                          ? AppColors.primaryLight
                          : AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.6),
                  AppColors.accent.withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, bool isAdmin) {
    final stats = isAdmin
        ? [
            _StatData(
              'Total Universities',
              '127',
              Icons.account_balance_rounded,
              AppColors.primary,
              '+3 this year',
            ),
            _StatData(
              'Total Students',
              '1.2M',
              Icons.people_rounded,
              AppColors.accent,
              '+8.4%',
            ),
            _StatData(
              'Accredited',
              '89',
              Icons.verified_rounded,
              AppColors.success,
              '70%',
            ),
            _StatData(
              'Avg Rating',
              '3.8',
              Icons.star_rounded,
              AppColors.warning,
              '↑ 0.2',
            ),
          ]
        : [
            _StatData(
              'Students',
              '12,450',
              Icons.people_rounded,
              AppColors.primary,
              '+320 this year',
            ),
            _StatData(
              'Faculty',
              '680',
              Icons.person_rounded,
              AppColors.accent,
              '42 PhD',
            ),
            _StatData(
              'Programs',
              '48',
              Icons.book_rounded,
              AppColors.success,
              '6 new',
            ),
            _StatData(
              'Rating',
              '4.1',
              Icons.star_rounded,
              AppColors.warning,
              '↑ 0.3',
            ),
          ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((s) => _buildStatCard(s)).toList(),
    );
  }

  Widget _buildStatCard(_StatData data) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
              Text(
                data.change,
                style: TextStyle(
                  fontSize: 11,
                  color: data.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                data.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textDarkSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Enrollment Trend',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          height: 200,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      if (value.toInt() < months.length) {
                        return Text(
                          months[value.toInt()],
                          style: const TextStyle(
                            color: AppColors.textDarkSecondary,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3.1),
                    FlSpot(1, 3.4),
                    FlSpot(2, 3.2),
                    FlSpot(3, 3.8),
                    FlSpot(4, 3.6),
                    FlSpot(5, 4.1),
                  ],
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityList(BuildContext context) {
    final universities = [
      ('Tashkent State Technical University', '4.2', '12,450'),
      ('National University of Uzbekistan', '4.5', '18,200'),
      ('Tashkent Medical Academy', '4.0', '8,300'),
      ('Westminster University Tashkent', '4.7', '3,100'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Universities',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...universities.map(
          (u) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.$1,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${u.$3} students',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textDarkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        u.$2,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  _StatData(this.label, this.value, this.icon, this.color, this.change);
}
