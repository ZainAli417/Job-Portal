import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'Job_Detail_Dialog.dart';

class LiveJobsForSeeker extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  const LiveJobsForSeeker({Key? key, required this.jobs}) : super(key: key);

  @override
  State<LiveJobsForSeeker> createState() => _LiveJobsForSeekerState();
}

class _LiveJobsForSeekerState extends State<LiveJobsForSeeker>
    with TickerProviderStateMixin {
  // Controllers & animations
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _debounceTimer;

  // Data
  List<Map<String, dynamic>> _filteredJobs = [];

  // Filters
  String? _selectedCompany;
  String? _selectedDepartment;
  String? _selectedLocation;
  String? _selectedJobType;
  String? _selectedExperience;
  String? _selectedSalaryType;
  String? _selectedRank;
  String? _selectedClearance;
  RangeValues _salaryRange = const RangeValues(0, 200000);
  final Set<String> _selectedBenefits = {};
  String _selectedSortOption = 'newest';

  // UI State
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _filteredJobs = List.from(widget.jobs);
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
    _searchController.addListener(_onSearchChanged);
    _initializeSalaryRange();
  }

  void _initializeSalaryRange() {
    final salaries = widget.jobs.map(_parseSalary).whereType<double>().toList();
    if (salaries.isNotEmpty) {
      final min = salaries.reduce((a, b) => a < b ? a : b);
      final max = salaries.reduce((a, b) => a > b ? a : b);
      _salaryRange = RangeValues(min, max);
    }
  }

  double? _parseSalary(Map<String, dynamic> job) {
    final s = job['salary']?.toString() ?? '';
    final m = RegExp(r'\d+(?:,\d{3})*').firstMatch(s);
    return m != null ? double.tryParse(m.group(0)!.replaceAll(',', '')) : null;
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), _applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs = widget.jobs.where((job) {
        // Search filter
        if (query.isNotEmpty) {
          final searchText =
          '${job['title']} ${job['company']} ${job['description']} ${(job['skills'] as List?)?.join(' ') ?? ''}'
              .toLowerCase();
          if (!searchText.contains(query)) return false;
        }

        // Dropdown filters
        if (_selectedCompany != null && job['company'] != _selectedCompany)
          return false;
        if (_selectedDepartment != null &&
            job['department'] != _selectedDepartment) return false;
        if (_selectedLocation != null && job['location'] != _selectedLocation)
          return false;
        if (_selectedJobType != null && job['nature'] != _selectedJobType)
          return false;
        if (_selectedExperience != null &&
            job['experience'] != _selectedExperience) return false;
        if (_selectedSalaryType != null &&
            job['salaryType'] != _selectedSalaryType) return false;
        if (_selectedRank != null && job['rankRequirement'] != _selectedRank)
          return false;
        if (_selectedClearance != null &&
            job['securityClearance'] != _selectedClearance) return false;

        // Salary range
        final sal = _parseSalary(job);
        if (sal != null && (sal < _salaryRange.start || sal > _salaryRange.end))
          return false;

        // Benefits
        if (_selectedBenefits.isNotEmpty) {
          final benefits =
              (job['benefits'] as List?)?.cast<String>().toSet() ?? {};
          if (!_selectedBenefits.any(benefits.contains)) return false;
        }

        return true;
      }).toList();
      _sortResults();
    });
  }

  void _sortResults() {
    switch (_selectedSortOption) {
      case 'newest':
        _filteredJobs.sort((a, b) =>
            ((b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0)).compareTo(
                (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0)));
        break;
      case 'oldest':
        _filteredJobs.sort((a, b) =>
            ((a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0)).compareTo(
                (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0)));
        break;
      case 'company':
        _filteredJobs
            .sort((a, b) => (a['company'] ?? '').compareTo(b['company'] ?? ''));
        break;
    }
  }

  List<String> _getUnique(String field) {
    return widget.jobs
        .map((j) => j[field] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _getUniqueList(String field) {
    final all = <String>{};
    for (var j in widget.jobs) {
      (j[field] as List?)?.cast<String>().forEach(all.add);
    }
    return all.toList()..sort();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCompany = _selectedDepartment = _selectedLocation =
          _selectedJobType = _selectedExperience =
          _selectedSalaryType = _selectedRank = _selectedClearance = null;
      _selectedBenefits.clear();
      _salaryRange = const RangeValues(0, 200000);
      _selectedSortOption = 'newest';
    });
    _applyFilters();
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedCompany != null) count++;
    if (_selectedDepartment != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedJobType != null) count++;
    if (_selectedExperience != null) count++;
    if (_selectedSalaryType != null) count++;
    if (_selectedRank != null) count++;
    if (_selectedClearance != null) count++;
    if (_selectedBenefits.isNotEmpty) count++;
    return count;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Row(
          children: [
            // Left Sidebar - Filters Panel
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isSidebarCollapsed ? 60 : 350,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: _isSidebarCollapsed
                  ? _buildCollapsedSidebar()
                  : _buildExpandedSidebar(),
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Header with Search and Sort
                  _buildTopHeader(),

                  // Job Cards List
                  Expanded(
                    child: _buildJobsList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedSidebar() {
    return Column(
      children: [
        // Expand button
        Container(
          height: 60,
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: IconButton(
            onPressed: () => setState(() => _isSidebarCollapsed = false),
            icon: const Icon(Icons.menu, color: Color(0xFF374151)),
            tooltip: 'Expand Filters',
          ),
        ),

        // Filter count indicator
        if (_activeFiltersCount > 0)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.filter_list, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text('$_activeFiltersCount',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedSidebar() {
    return Column(
      children: [
        // Sidebar Header
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Icon(Icons.tune, size: 24, color: const Color(0xFF374151)),
              const SizedBox(width: 12),
              Text('Filters & Search',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151))),
              const Spacer(),
              if (_activeFiltersCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$_activeFiltersCount',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: () => setState(() => _isSidebarCollapsed = true),
                icon: const Icon(Icons.chevron_left, color: Color(0xFF374151)),
                tooltip: 'Collapse Filters',
              ),
            ],
          ),
        ),

        // Scrollable Filters Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Section
                _buildSearchSection(),
                const SizedBox(height: 24),

                // Clear Filters Button
                if (_activeFiltersCount > 0) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear All Filters'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Basic Filters
                _buildFilterSection('Basic Filters', [
                  _buildDropdown(
                      'Company',
                      _selectedCompany,
                      _getUnique('company'),
                          (v) => setState(() => _selectedCompany = v)),
                  const SizedBox(height: 12),
                  _buildDropdown(
                      'Location',
                      _selectedLocation,
                      _getUnique('location'),
                          (v) => setState(() => _selectedLocation = v)),
                  const SizedBox(height: 12),
                  _buildDropdown(
                      'Job Type',
                      _selectedJobType,
                      _getUnique('nature'),
                          (v) => setState(() => _selectedJobType = v)),
                ]),

                const SizedBox(height: 24),

                // Advanced Filters
                _buildFilterSection('Advanced Filters', [
                  _buildDropdown(
                      'Department',
                      _selectedDepartment,
                      _getUnique('department'),
                          (v) => setState(() => _selectedDepartment = v)),
                  const SizedBox(height: 12),
                  _buildDropdown(
                      'Experience Level',
                      _selectedExperience,
                      _getUnique('experience'),
                          (v) => setState(() => _selectedExperience = v)),
                  const SizedBox(height: 12),
                  _buildDropdown(
                      'Salary Type',
                      _selectedSalaryType,
                      _getUnique('salaryType'),
                          (v) => setState(() => _selectedSalaryType = v)),
                ]),

                const SizedBox(height: 24),

                // Salary Range
                _buildSalaryRangeSection(),

                const SizedBox(height: 24),

                // Benefits
                _buildBenefitsSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Results count
          Text(
            '${_filteredJobs.length} job${_filteredJobs.length == 1 ? '' : 's'} found',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151)),
          ),

          const Spacer(),

          // Active jobs badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${_filteredJobs.length} Active',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981))),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedSortOption,
                  underline: const SizedBox(),
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF64748B)),
                  items: const [
                    DropdownMenuItem(
                        value: 'newest', child: Text('Newest First')),
                    DropdownMenuItem(
                        value: 'oldest', child: Text('Oldest First')),
                    DropdownMenuItem(
                        value: 'company', child: Text('Company A→Z')),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedSortOption = val!);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CompactJobCard(jobData: _filteredJobs[index]),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search Jobs',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search jobs, companies, skills...',
              hintStyle: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF64748B)),
              prefixIcon: const Icon(Icons.search,
                  size: 20, color: Color(0xFF64748B)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear,
                    size: 18, color: Color(0xFF64748B)),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSalaryRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Salary Range',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${(_salaryRange.start / 1000).round()}k',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151))),
                  Text('\$${(_salaryRange.end / 1000).round()}k',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151))),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  thumbColor: const Color(0xFF3B82F6),
                  overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: RangeSlider(
                  values: _salaryRange,
                  min: 0,
                  max: 200000,
                  divisions: 40,
                  onChanged: (r) {
                    setState(() => _salaryRange = r);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Benefits',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getUniqueList('benefits').map((benefit) {
            final isSelected = _selectedBenefits.contains(benefit);
            return InkWell(
              onTap: () {
                setState(() {
                  isSelected
                      ? _selectedBenefits.remove(benefit)
                      : _selectedBenefits.add(benefit);
                });
                _applyFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFD1D5DB)),
                ),
                child: Text(
                    benefit.length > 15
                        ? '${benefit.substring(0, 15)}...'
                        : benefit,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text('All ${label}s',
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF9CA3AF))),
            isExpanded: true,
            underline: const SizedBox(),
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151)),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('All ${label}s',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF9CA3AF))),
              ),
              ...items.map(
                      (item) => DropdownMenuItem(value: item, child: Text(item))),
            ],
            onChanged: (v) {
              onChanged(v);
              _applyFilters();
            },
          ),
        ),
      ],
    );
  }
}
/// Compact Job Card with clean, lightweight design
class CompactJobCard extends StatefulWidget {
  final Map<String, dynamic> jobData;
  const CompactJobCard({super.key, required this.jobData});

  @override
  State<CompactJobCard> createState() => _CompactJobCardState();
}

class _CompactJobCardState extends State<CompactJobCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getRelativeTime(Timestamp? ts) {
    if (ts == null) return '';
    return timeago.format(ts.toDate(), locale: 'en_short');
  }

  void _showDetails() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDetailModal(jobData: widget.jobData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.jobData;
    final isActive = (job['status'] as String? ?? 'active') == 'active';
    final title = job['title'] as String? ?? 'No Title';
    final department = job['department'] as String? ?? 'N/A';
    final company = job['company'] as String? ?? 'Unknown Company';
    final location = job['location'] as String? ?? 'Unknown Location';
    final description = job['description'] as String? ?? '';
    final responsibilities = job['responsibilities'] as String? ?? '';
    final skills = (job['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final logoUrl = job['logoUrl'] as String?;
    final postedAgo = _getRelativeTime(job['timestamp'] as Timestamp?);
    final primaryColor = Theme.of(context).primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: _showDetails,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: _isHovered ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (_, scale, child) => Transform.scale(
            scale: scale,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1 : 0.65,
              child: child,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [Colors.white, Colors.grey.shade50]
                    : [Colors.grey.shade100, Colors.grey.shade200],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? primaryColor.withOpacity(0.6)
                    : Colors.grey.shade200,
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? primaryColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: _isHovered ? 20 : 8,
                  offset: Offset(0, _isHovered ? 8 : 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade100, Colors.white],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: logoUrl != null && logoUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: logoUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.business_center,
                                  color: Color(0xFF64748B),
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$company • $department',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                location,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (postedAgo.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF003366).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Color(0xFF003366).withOpacity(0.3)),
                            ),
                            child: Text(
                              '$postedAgo ago',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003366),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description.isNotEmpty)
                          _buildDetailSection(
                            'Job Description',
                            Icons.description,
                            Text(
                              description,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        if (responsibilities.isNotEmpty)
                          _buildDetailSection(
                            'Key Responsibilities',
                            Icons.checklist,
                            Text(
                              responsibilities,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        const SizedBox(height: 5),
                        if (skills.isNotEmpty) ...[
                          Text(
                            'Skills Required',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: skills.take(4).map((skill) {
                                  return _ModernChip(
                                    text: skill,
                                    color: Colors.blue.shade600,
                                  );
                                }).toList(),
                              ),
                              if (skills.length > 4)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '+${skills.length - 4} more',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Details',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}

/// Modern chip widget with enhanced styling
class _ModernChip extends StatelessWidget {
  final String text;
  final Color color;

  const _ModernChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Light color background for chips
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
