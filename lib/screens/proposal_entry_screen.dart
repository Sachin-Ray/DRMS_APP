import 'package:drms/ReportIncidentScreen_Widgets/add_beneficiary_dialog.dart';
import 'package:drms/app_scaffold.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/APIService.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ProposalEntryScreen extends StatefulWidget {
  final String categoryTitle;

  const ProposalEntryScreen({super.key, required this.categoryTitle});

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

  // List<ExGratiaBeneficiary> beneficiaries = [];
  // bool showBeneficiarySection = false;
  bool allDocumentsUploaded = true;

  final List<DateTime> highlightedDates = [];
  final List<String> prList = [];

  /// Dummy beneficiaries (replace later with API)
  final List<Map<String, dynamic>> beneficiaries = [];

  @override
  void initState() {
    super.initState();
    _loadHighlightedDates();
  }

  /* ---------------- API ---------------- */

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

  /* ---------------- UI ---------------- */

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

            /// 🔥 HIDDEN → SHOWN ONLY AFTER PR SELECT
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

  /* ---------------- TOP BANNER ---------------- */

  Widget _topInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0EA5B7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Please select Date of Incidence and FIR/Preliminary Report No. before creating or modifying details.",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- INCIDENT DETAILS ---------------- */

  Widget _incidentDetailsCard() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: primaryBlue),
                SizedBox(width: 6),
                Text(
                  "Incident Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRequiredLabel("Date of Incidence"),
            SizedBox(height: 8),
            _datePicker(),
            const SizedBox(height: 8),
            _dateHint(),
            const SizedBox(height: 16),
            _buildRequiredLabel("Preliminary Report No. "),
            SizedBox(height: 8),
            _prDropdown(),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                // onPressed: showBeneficiarySection
                //     ? _openBeneficiaryModal
                //     : null,
                onPressed: _openBeneficiaryModal,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("Add Beneficiary"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: isLoadingDates ? null : _pickDate,
      child: _inputBox(
        icon: Icons.calendar_today,
        text: selectedDate == null
            ? "DD-MM-YYYY"
            : DateFormat("dd-MM-yyyy").format(selectedDate!),
      ),
    );
  }

  Widget _buildRequiredLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xff2D3142),
          ),
        ),
        SizedBox(width: 4),
        Text(
          "*",
          style: TextStyle(
            color: errorRed,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 🔑 IMPORTANT
            children: [
              const Text(
                "Select Date of Incidence",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 340, // ✅ CONTROLLED HEIGHT
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2035),
                  focusedDay: selectedDate ?? DateTime.now(),
                  selectedDayPredicate: (d) => isSameDay(d, selectedDate),

                  onDaySelected: (day, _) {
                    Navigator.pop(context);
                    setState(() => selectedDate = day);
                    _loadPRsForDate(day);
                  },

                  calendarBuilders: CalendarBuilders(
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

                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: primaryBlue),
                      shape: BoxShape.circle,
                    ),
                    
                  ),

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedPR,
      decoration: _inputDecoration("Select PR No."),
      items: prList
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
      },
    );
  }

  Widget _beneficiaryTableCard() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people, size: 20, color: primaryBlue),
                SizedBox(width: 6),
                Text(
                  "List Of Beneficiaries",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
          ),

          const Divider(),

          if (beneficiaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                "No records found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // void _openBeneficiaryModal() {
  //   showDialog(
  //     context: context,
  //     builder: (_) => Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       child: const Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Text(
  //           "Add Beneficiary",
  //           style: TextStyle(fontWeight: FontWeight.w600),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _openBeneficiaryModal() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AddBeneficiaryDialog(
        blocks: [],
        villages: [],
        onSave: (payload) {
          print("FINAL BENEFICIARY PAYLOAD:");
          print(payload);
        },
      );
    },
  );
}


  Widget _inputBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xffF5F5F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
  

  Widget _dateHint() {
    return Row(
      children: const [
        Icon(Icons.lightbulb_outline, size: 14, color: Colors.yellow),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            "Date of incidence has been highlighted in the calendar",
            style: TextStyle(fontSize: 11, color: Color(0xff92400E)),
          ),
        ),
      ],
    );
  }
}
