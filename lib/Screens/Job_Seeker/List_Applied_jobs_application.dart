import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Top_Side_Nav.dart';
import 'List_applied_jobs_provider.dart';

class SmoothScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: ClampingScrollPhysics());
  }
}

class ListAppliedJobsScreen extends StatefulWidget {
  const ListAppliedJobsScreen({super.key});

  @override
  State<ListAppliedJobsScreen> createState() => _ListAppliedJobsScreenState();
}

class _ListAppliedJobsScreenState extends State<ListAppliedJobsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedCompany = 'All';
  DateTimeRange? _appliedRange;
  DateTimeRange? _createdRange;
  final List<String> _statusOptions = ['All', 'pending', 'accepted', 'rejected'];
  List<String> _companyOptions = ['All'];
  String _sortBy = 'applied_desc';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _pickDateRange(bool isApplied) async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: isApplied ? _appliedRange : _createdRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        ),
        child: child!,
      ),
    );
    if (result != null) {
      setState(() {
        if (isApplied) _appliedRange = result;
        else _createdRange = result;
      });
    }
  }

  bool _inRange(DateTime date, DateTimeRange? range) {
    if (range == null) return true;
    return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
        date.isBefore(range.end.add(const Duration(days: 1)));
  }

  List<dynamic> _sortApplications(List<dynamic> applications) {
    final sortedList = List<dynamic>.from(applications);
    switch (_sortBy) {
      case 'applied_desc':
        sortedList.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        break;
      case 'applied_asc':
        sortedList.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
        break;
      case 'title_asc':
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'company_asc':
        sortedList.sort((a, b) => a.company.compareTo(b.company));
        break;
      case 'status':
        sortedList.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
    return sortedList;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'All';
      _selectedCompany = 'All';
      _appliedRange = null;
      _createdRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: SmoothScrollBehavior(),
      child: MainLayout(
        activeIndex: 2,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ChangeNotifierProvider<ListAppliedJobsProvider>(
      create: (_) => ListAppliedJobsProvider()..loadHistory(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Consumer<ListAppliedJobsProvider>(
          builder: (ctx, prov, _) {
            if (prov.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                    SizedBox(height: 16),
                    Text('Loading applications...', style: TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
              );
            }

            if (prov.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(prov.error!, style: const TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => prov.loadHistory(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            _companyOptions = ['All'] + prov.applications.map((a) => a.company).toSet().toList();

            final filtered = prov.applications.where((app) {
              final query = _searchController.text.toLowerCase();
              return (_selectedStatus == 'All' || app.status == _selectedStatus) &&
                  (_selectedCompany == 'All' || app.company == _selectedCompany) &&
                  _inRange(app.appliedAt, _appliedRange) &&
                  _inRange(app.createdAt, _createdRange) &&
                  (query.isEmpty ||
                      app.title.toLowerCase().contains(query) ||
                      app.company.toLowerCase().contains(query) ||
                      app.jobId.toLowerCase().contains(query));
            }).toList();

            final sortedFiltered = _sortApplications(filtered);

            return Column(
              children: [
                // Header
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Stats Row
                        Row(
                          children: [
                            const Text(
                              'Applied Jobs',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${sortedFiltered.length} Jobs',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            _buildViewToggle(),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Quick Stats
                        Row(
                          children: [
                            _buildStatCard('Pending', prov.applications.where((a) => a.status == 'pending').length, const Color(0xFFF59E0B)),
                            const SizedBox(width: 12),
                            _buildStatCard('Accepted', prov.applications.where((a) => a.status == 'accepted').length, const Color(0xFF10B981)),
                            const SizedBox(width: 12),
                            _buildStatCard('Rejected', prov.applications.where((a) => a.status == 'rejected').length, const Color(0xFFEF4444)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search & Filter Row
                        Row(
                          children: [
                            // Search
                            Expanded(
                              flex: 3,
                              child: _buildSearchField(),
                            ),
                            const SizedBox(width: 12),
                            // Status Filter
                            _buildFilterDropdown('Status', _selectedStatus, _statusOptions, (v) => setState(() => _selectedStatus = v)),
                            const SizedBox(width: 12),
                            // Company Filter
                            _buildFilterDropdown('Company', _selectedCompany, _companyOptions, (v) => setState(() => _selectedCompany = v)),
                            const SizedBox(width: 12),
                            // Date Filters
                            _buildDateChip('Applied', _appliedRange, () => _pickDateRange(true)),
                            const SizedBox(width: 8),
                            _buildDateChip('Created', _createdRange, () => _pickDateRange(false)),
                            const SizedBox(width: 12),
                            // Sort
                            _buildSortDropdown(),
                            const SizedBox(width: 12),
                            // Clear Filters
                            if (_searchController.text.isNotEmpty || _selectedStatus != 'All' || _selectedCompany != 'All' || _appliedRange != null || _createdRange != null)
                              _buildClearButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _isGridView ? _buildGridView(sortedFiltered) : _buildTableView(sortedFiltered),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildToggleButton(Icons.table_rows, !_isGridView, () => setState(() => _isGridView = false)),
          _buildToggleButton(Icons.grid_view, _isGridView, () => setState(() => _isGridView = true)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
            const SizedBox(height: 4),
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options, Function(String) onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 16),
        items: options.map((s) => DropdownMenuItem(
          value: s,
          child: Text(s == 'All' ? 'All $label' : s, style: const TextStyle(fontSize: 14)),
        )).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        underline: const SizedBox(),
        icon: const Icon(Icons.sort, color: Color(0xFF64748B)),
        items: const [
          DropdownMenuItem(value: 'applied_desc', child: Text('Latest Applied')),
          DropdownMenuItem(value: 'applied_asc', child: Text('Oldest Applied')),
          DropdownMenuItem(value: 'title_asc', child: Text('Title A-Z')),
          DropdownMenuItem(value: 'company_asc', child: Text('Company A-Z')),
          DropdownMenuItem(value: 'status', child: Text('Status')),
        ],
        onChanged: (v) => setState(() => _sortBy = v!),
      ),
    );
  }

  Widget _buildDateChip(String label, DateTimeRange? range, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: range != null ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: range != null ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: range != null ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              range == null ? label : '${DateFormat.MMMd().format(range.start)}-${DateFormat.MMMd().format(range.end)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: range != null ? const Color(0xFF6366F1) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: _clearFilters,
        icon: const Icon(Icons.clear, color: Color(0xFFEF4444)),
        tooltip: 'Clear filters',
      ),
    );
  }

  Widget _buildGridView(List<dynamic> applications) {
    if (applications.isEmpty) return _buildEmptyState();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: applications.length,
      itemBuilder: (context, index) => _buildJobCard(applications[index]),
    );
  }

  Widget _buildJobCard(dynamic app) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(app.jobId, style: const TextStyle(fontSize: 12, fontFamily: 'mono', color: Color(0xFF64748B)))),
                _buildStatusBadge(app.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(app.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(app.company, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateInfo('Applied', app.appliedAt),
                const SizedBox(height: 4),
                _buildDateInfo('Created', app.createdAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Row(
      children: [
        Icon(label == 'Applied' ? Icons.send : Icons.add, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text('$label: ${DateFormat.MMMd().format(date)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildTableView(List<dynamic> applications) {
    if (applications.isEmpty) return _buildEmptyState();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('JOB ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5))),
                Expanded(flex: 3, child: Text('TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5))),
                Expanded(flex: 3, child: Text('COMPANY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('APPLIED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('CREATED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : const Color(0xFFFAFBFC),
                    border: Border(bottom: BorderSide(color: index == applications.length - 1 ? Colors.transparent : const Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(app.jobId, style: const TextStyle(fontSize: 13, fontFamily: 'mono', color: Color(0xFF64748B)))),
                      Expanded(flex: 3, child: Text(app.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
                      Expanded(flex: 3, child: Text(app.company, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)))),
                      Expanded(flex: 2, child: Text(DateFormat.MMMd().format(app.appliedAt), style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
                      Expanded(flex: 2, child: Text(DateFormat.MMMd().format(app.createdAt), style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
                      Expanded(flex: 2, child: _buildStatusBadge(app.status)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.work_outline, size: 64, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          const Text('No applications found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters or search terms', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear all filters'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'accepted': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      default: return const Color(0xFF64748B);
    }
  }
}