import 'package:drms/ReportIncidentScreen_Widgets/add_animal_husbandry_beneficiary_dialog.dart';
import 'package:drms/ReportIncidentScreen_Widgets/add_fishery_beneficiary_dialog.dart';
import 'package:drms/ReportIncidentScreen_Widgets/add_gr_beneficiary_dialog.dart';
import 'package:drms/ReportIncidentScreen_Widgets/add_handloom_beneficiary_dialog.dart';
import 'package:drms/ReportIncidentScreen_Widgets/add_housing_damage_beneficiary_dialog.dart';
import 'package:drms/ReportIncidentScreen_Widgets/exgratia_beneficiary_list.dart';
import 'package:drms/app_scaffold.dart';
import 'package:drms/model/ExGratiaBeneficiary.dart';
import 'package:drms/services/APIService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ProposalEntryScreen extends StatefulWidget {
  final String categoryTitle;
  final String assistanceHead;
  final IconData icon;

  const ProposalEntryScreen({
    super.key,
    required this.categoryTitle,
    required this.assistanceHead,
    required this.icon,
  });

  @override
  State<ProposalEntryScreen> createState() => _ProposalEntryScreenState();
}

class _ProposalEntryScreenState extends State<ProposalEntryScreen> {
  static const Color primaryBlue = Color(0xff2563EB);
  static const Color errorRed = Color(0xffDC2626);
  static const Color pageBg = Color(0xffF3F4F6);

  DateTime? selectedDate;
  String? selectedPR;

  bool isLoadingDates = true;
  bool isLoadingPRs = false;
  bool showBeneficiarySection = false;

  List<ExGratiaBeneficiary> beneficiaries = [];
  bool isLoadingBeneficiaries = false;

  final List<DateTime> highlightedDates = [];
  final List<String> prList = [];

  int currentPage = 1;
  final int pageSize = 20;

  bool hasMore = true;
  bool isFetchingMore = false;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadHighlightedDates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHighlightedDates() async {
    try {
      final dates = await APIService.instance.getFirDatesByBlockCode();
      highlightedDates.clear();

      if (dates != null) {
        for (final d in dates) {
          highlightedDates.add(DateFormat("dd-MM-yyyy").parse(d));
        }
      }
    } catch (_) {}

    if (mounted) setState(() => isLoadingDates = false);
  }

  Future<void> _loadBeneficiaries({bool loadMore = false}) async {
    if (selectedPR == null) return;

    if (loadMore) {
      if (!hasMore || isFetchingMore) return;
      setState(() => isFetchingMore = true);
    } else {
      setState(() {
        isLoadingBeneficiaries = true;
        beneficiaries.clear();
        currentPage = 1;
        hasMore = true;
      });
    }

    final list = await APIService.instance.getExGratiaFromFir(
      firNo: selectedPR!,
      assistanceHead: widget.assistanceHead,
      page: currentPage,
      size: pageSize,
    );

    if (!mounted) return;

    setState(() {
      beneficiaries.addAll(list);

      if (list.length < pageSize) {
        hasMore = false;
      } else {
        currentPage++;
      }

      isLoadingBeneficiaries = false;
      isFetchingMore = false;
    });
  }

  Future<void> _loadPRsForDate(DateTime date) async {
    setState(() {
      isLoadingPRs = true;
      prList.clear();
      selectedPR = null;
      showBeneficiarySection = false;
    });

    final apiDate = DateFormat("yyyy-MM-dd").format(date);

    final list = await APIService.instance.getAllFirFromDate(apiDate);
    if (list != null) prList.addAll(list);

    if (mounted) setState(() => isLoadingPRs = false);
  }

  Future<void> _pickYear() async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: 16,
              itemBuilder: (context, index) {
                final year = 2020 + index;

                return ListTile(
                  title: Text(
                    year.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context, year);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        _focusedDay = DateTime(selectedYear, _focusedDay.month, 1);
      });

      // ✅ Close calendar and reopen with new year
      Navigator.pop(context);
      _pickDate();
    }
  }

  List<ExGratiaBeneficiary> get filteredBeneficiaries {
    if (searchQuery.isEmpty) return beneficiaries;

    return beneficiaries.where((b) {
      return b.beneficiaryName.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.categoryTitle,
      currentRoute: 'proposal_entry',
      body: Container(
        color: pageBg,
        child: ListView(
          children: [
            _topInfoBanner(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: _incidentDetailsCard(),
            ),

            if (showBeneficiarySection)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _beneficiaryTableCard(),
              ),
          ],
        ),
      ),
    );
  }

  /* ---------------- TOP MODERN INFO BANNER ---------------- */

  Widget _topInfoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [primaryBlue, Color(0xff1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Proposal Entry Instructions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Please select Date of Incidence and PR/FIR No. before adding beneficiaries.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- INCIDENT DETAILS CARD ---------------- */

  Widget _incidentDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Incident Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildRequiredLabel("Date of Incidence"),
          const SizedBox(height: 10),
          _datePicker(),
          const SizedBox(height: 8),
          _dateHint(),

          const SizedBox(height: 18),

          _buildRequiredLabel("Preliminary Report No."),
          const SizedBox(height: 10),
          _prDropdown(),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedPR == null ? null : _openBeneficiaryModal,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text(
                "Add Beneficiary",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- DATE PICKER ---------------- */

  Widget _datePicker() {
    return InkWell(
      onTap: isLoadingDates ? null : _pickDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xffF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: primaryBlue,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat("dd/MM/yyyy").format(selectedDate!)
                    : "Select Date of Incidence",
                style: TextStyle(
                  color: selectedDate != null
                      ? const Color(0xff111827)
                      : const Color(0xff9CA3AF),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2035),

              // ✅ FIX: Focused day must be controlled
              focusedDay: _focusedDay,

              selectedDayPredicate: (d) => isSameDay(d, selectedDate),

              // ✅ Date Select Works
              onDaySelected: (day, _) {
                Navigator.pop(context);

                setState(() {
                  selectedDate = day;
                  _focusedDay = day; // ✅ Update focus also
                });

                _loadPRsForDate(day);
              },

              // ✅ Month Swipe Works
              onPageChanged: (day) {
                setState(() {
                  _focusedDay = day;
                });
              },

              // ✅ YEAR PICKER SHORTCUT ON HEADER TITLE
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  return InkWell(
                    onTap: () => _pickYear(),
                    child: Text(
                      DateFormat("MMMM yyyy").format(day),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },

                defaultBuilder: (context, day, _) {
                  final isHighlighted = highlightedDates.any(
                    (d) =>
                        d.year == day.year &&
                        d.month == day.month &&
                        d.day == day.day,
                  );

                  if (isHighlighted) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),

              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xffDBEAFE),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),

              headerStyle: const HeaderStyle(
                titleCentered: true,

                // ✅ Fix "2 weeks" crash
                formatButtonVisible: false,

                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ---------------- PR DROPDOWN ---------------- */

  Widget _prDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPR,
      decoration: _inputDecoration("Select PR No."),
      items: prList
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        setState(() {
          selectedPR = v;
          showBeneficiarySection = true;
        });
        _loadBeneficiaries();
      },
    );
  }

  /* ---------------- BENEFICIARY TABLE CARD ---------------- */

  Widget _beneficiaryTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_alt_outlined,
                    color: primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "List of Beneficiaries",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xff111827),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Beneficiary Name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xffF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          if (isLoadingBeneficiaries)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (beneficiaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("No records found"),
            )
          else
            Column(
              children: [
                ExGratiaBeneficiaryList(
                  list: filteredBeneficiaries,
                  onEdit: _editBeneficiary,
                  onDelete: _deleteBeneficiary,
                  icon: widget.icon,
                ),

                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: ElevatedButton(
                      onPressed: isFetchingMore
                          ? null
                          : () => _loadBeneficiaries(loadMore: true),
                      child: isFetchingMore
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Load More"),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /* ---------------- EDIT + DELETE ---------------- */

  void _editBeneficiary(ExGratiaBeneficiary b) {}

  Future<void> _deleteBeneficiary(ExGratiaBeneficiary b) async {}

  /* ---------------- OPEN MODAL ---------------- */

  void _openBeneficiaryModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        if (widget.categoryTitle == "Handloom & Handicrafts") {
          return AddHandloomBeneficiaryDialog(
            blocks: [],
            villages: [],
            onSave: (Map<String, dynamic> p1) {},
          );
        }
        if (widget.categoryTitle == "Fishery") {
          return AddFisheryBeneficiaryDialog(
            blocks: [],
            villages: [],
            firNo: selectedPR!,
          );
        }
        if (widget.categoryTitle == "Animal Husbandry") {
          return AddAnimalHusbandryBeneficiaryDialog(
            blocks: [],
            villages: [],
            firNo: selectedPR!,
          );
        }
        if (widget.categoryTitle == "Housing Damage") {
          return AddHousingDamageBeneficiaryDialog(
            blocks: [],
            villages: [],
            firNo: selectedPR!,
          );
        }
        return AddBeneficiaryDialog(
          blocks: [],
          villages: [],
          firNo: selectedPR!,
        );
      },
    ).then((result) {
      if (result == true) _loadBeneficiaries();
    });
  }

  /* ---------------- INPUT DECORATION ---------------- */

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xff9CA3AF)),
      filled: true,
      fillColor: const Color(0xffF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }

  /* ---------------- REQUIRED LABEL ---------------- */

  Widget _buildRequiredLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xff111827),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          "*",
          style: TextStyle(color: errorRed, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /* ---------------- DATE HINT ---------------- */

  Widget _dateHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Highlighted dates indicate incidents already reported.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
