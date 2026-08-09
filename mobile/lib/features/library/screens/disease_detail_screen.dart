// Presents localized disease symptoms, treatments, and prevention guidance.

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/circular_back_button.dart';
import '../../../../data/data_sources/library_data_source.dart';
import '../../../../data/models/disease_detail_model.dart';

class DiseaseDetailScreen extends StatefulWidget {
  const DiseaseDetailScreen({super.key, required this.diseaseName, required this.diseaseId});
  final String diseaseName;
  final String diseaseId;

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late Future<DiseaseDetailModel?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    _detailFuture = LibraryDataSource.getDetail(widget.diseaseId, locale);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AppAssets.bgLibrary,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  floating: false,
                  leading: const CircularBackButton(),
                  iconTheme: IconThemeData(
                    color: innerBoxIsScrolled ? theme.colorScheme.onSurface : Colors.white,
                  ),
                  centerTitle: true,
                  title: innerBoxIsScrolled
                      ? Text(
                          widget.diseaseName,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                  expandedHeight: 150,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Container(
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.98),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Text(
                      widget.diseaseName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: l10n.tabSymptoms),
                          Tab(text: l10n.tabTreatment),
                          Tab(text: l10n.tabPrevention),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<DiseaseDetailModel?>(
                      future: _detailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                          return Center(
                            child: Text(
                              l10n.diseaseInfoPending,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final data = snapshot.data!;
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInfoList(context, data.symptoms, Icons.fiber_manual_record),
                            _buildInfoList(context, data.treatment, Icons.check_circle_outline),
                            _buildInfoList(context, data.prevention, Icons.shield_outlined),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList(BuildContext context, List<String> items, IconData icon) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 30),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  items[index],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
