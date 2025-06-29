import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'Job_Detail_Dialog.dart';

class LiveJobsForSeeker extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  const LiveJobsForSeeker({super.key, required this.jobs});

  @override
  State<LiveJobsForSeeker> createState() => _LiveJobsForSeekerState();
}

class _LiveJobsForSeekerState extends State<LiveJobsForSeeker> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  List<Map<String, dynamic>> _filteredJobs = [];
  bool _showFilters = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Filter states
  final Set<String> _selectedCompanies = {};
  final Set<String> _selectedDepartments = {};
  final Set<String> _selectedLocations = {};
  final Set<String> _selectedJobTypes = {};
  final Set<String> _selectedExperienceLevels = {};
  String _selectedSortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _filteredJobs = List.from(widget.jobs);
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }


  void _filterJobs() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredJobs = widget.jobs.where((job) {
        // Search filter
        if (query.isNotEmpty) {
          final title = (job['title'] as String? ?? '').toLowerCase();
          final company = (job['company'] as String? ?? '').toLowerCase();
          final description = (job['description'] as String? ?? '').toLowerCase();
          final skills = (job['skills'] as List<dynamic>?)?.map((s) => s.toString().toLowerCase()).join(' ') ?? '';

          final searchMatch = title.contains(query) ||
              company.contains(query) ||
              description.contains(query) ||
              skills.contains(query);

          if (!searchMatch) return false;
        }

        // Company filter
        if (_selectedCompanies.isNotEmpty) {
          final company = job['company'] as String? ?? '';
          if (!_selectedCompanies.contains(company)) return false;
        }

        // Department filter
        if (_selectedDepartments.isNotEmpty) {
          final department = job['department'] as String? ?? '';
          if (!_selectedDepartments.contains(department)) return false;
        }

        // Location filter
        if (_selectedLocations.isNotEmpty) {
          final location = job['location'] as String? ?? '';
          if (!_selectedLocations.contains(location)) return false;
        }

        // Job type filter
        if (_selectedJobTypes.isNotEmpty) {
          final jobType = job['nature'] as String? ?? '';
          if (!_selectedJobTypes.contains(jobType)) return false;
        }

        // Experience filter
        if (_selectedExperienceLevels.isNotEmpty) {
          final experience = job['experience'] as String? ?? '';
          if (!_selectedExperienceLevels.contains(experience)) return false;
        }

        return true;
      }).toList();

      // Sort jobs
      _sortJobs();
    });
  }


  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCompanies.clear();
      _selectedDepartments.clear();
      _selectedLocations.clear();
      _selectedJobTypes.clear();
      _selectedExperienceLevels.clear();
      _selectedSortOption = 'newest';
      _searchController.clear();
    });
    _filterJobs();
  }

  List<String> _getUniqueValues(String field) {
    return widget.jobs
        .map((job) => job[field] as String? ?? '')
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchAndFilters(),
                if (_showFilters) _buildFilterSection(),
                _buildJobCount(),
                Expanded(child: _buildJobsList()),
              ],
            ),
          ),
        );
      },
    );
  }
  void _sortJobs() {
    switch (_selectedSortOption) {
      case 'newest':
        _filteredJobs.sort((a, b) {
          final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
          final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
        break;
      case 'oldest':
        _filteredJobs.sort((a, b) {
          final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
          final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
          return aTime.compareTo(bTime);
        });
        break;
      case 'company':
        _filteredJobs.sort((a, b) {
          final aCompany = a['company'] as String? ?? '';
          final bCompany = b['company'] as String? ?? '';
          return aCompany.compareTo(bCompany);
        });
        break;
    }
  }
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterJobs();
    });

    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(
            Icons.work_outline,
            size: 28,
            color: const Color(0xFF1E293B),
          ),
          const SizedBox(width: 12),
          Text(
            'Live Jobs',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: Text(
              '${widget.jobs.length} Active',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSearchBar()),
          const SizedBox(width: 12),
          _buildFilterButton(),
          const SizedBox(width: 8),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearching ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          width: _isSearching ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: 'Search jobs, companies, skills...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isSearching ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: _isSearching
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () {
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
            color: const Color(0xFF64748B),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    final hasActiveFilters = _selectedCompanies.isNotEmpty ||
        _selectedDepartments.isNotEmpty ||
        _selectedLocations.isNotEmpty ||
        _selectedJobTypes.isNotEmpty ||
        _selectedExperienceLevels.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleFilters,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _showFilters ? const Color(0xFF3B82F6) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasActiveFilters ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.tune,
                  color: _showFilters ? Colors.white : const Color(0xFF64748B),
                  size: 20,
                ),
                if (hasActiveFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      initialValue: _selectedSortOption,
      onSelected: (value) {
        setState(() {
          _selectedSortOption = value;
        });
        _filterJobs();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.sort,
          color: Color(0xFF64748B),
          size: 20,
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'newest',
          child: Text('Newest First'),
        ),
        const PopupMenuItem(
          value: 'oldest',
          child: Text('Oldest First'),
        ),
        const PopupMenuItem(
          value: 'company',
          child: Text('Company A-Z'),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return AnimatedBuilder(
      animation: _filterAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(_filterAnimationController),
          child: FadeTransition(
            opacity: _filterAnimationController,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearAllFilters,
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips('Companies', _getUniqueValues('company'), _selectedCompanies),
                  _buildFilterChips('Departments', _getUniqueValues('department'), _selectedDepartments),
                  _buildFilterChips('Locations', _getUniqueValues('location'), _selectedLocations),
                  _buildFilterChips('Job Types', _getUniqueValues('nature'), _selectedJobTypes),
                  _buildFilterChips('Experience', _getUniqueValues('experience'), _selectedExperienceLevels),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(String title, List<String> options, Set<String> selected) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: options.map((option) {
              final isSelected = selected.contains(option);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(option);
                    } else {
                      selected.add(option);
                    }
                  });
                  _filterJobs();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }








  Widget _buildJobCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        '${_filteredJobs.length} ${_filteredJobs.length == 1 ? 'job' : 'jobs'} found',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    if (_filteredJobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredJobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: Opacity(
                opacity: value,
                child: CompactJobCard(jobData: _filteredJobs[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear all filters',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF3B82F6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF003366).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF003366).withOpacity(0.3)),
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
                              colors: [primaryColor, primaryColor.withOpacity(0.8)],
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
