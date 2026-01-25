import 'package:drms/app_scaffold.dart';
import 'package:drms/screens/report_incident_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnReportScreen extends StatelessWidget {
  const ReturnReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data – replace with your actual returned list
    final reports = List.generate(5, (index) {
      return {
        "prNo": "PR/2026/00${index + 1}",
        "calamity": "Landslide",
        "incidentDate": "12 Jan 2026",
        "reportDate": "13 Jan 2026",
        "block": "Mylliem",
      };
    });

    return AppScaffold(
      title: "Returned Report",
      currentRoute: 'returned_report',
      body: Container(
        color: const Color(0xffF3F4F6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + count
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Preliminary Reports Returned From DC",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  //   decoration: BoxDecoration(color: const Color(0xffEEF2FF), borderRadius: BorderRadius.circular(999)),
                  //   child: Text(
                  //     "${reports.length}",
                  //     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4F46E5)),
                  //   ),
                  // ),
                ],
              ),
            ),

            // Subtitle / filter row
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.info_outline, size: 16, color: Color(0xff6B7280)),
            //       const SizedBox(width: 6),
            //       Expanded(
            //         child: Text(
            //           "Tap a report to view details or edit and re-submit.",
            //           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xff6B7280)),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 8),

            // List of cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final item = reports[index];
                  return _ReturnedReportCard(
                    index: index + 1,
                    prNo: item["prNo"]!,
                    calamity: item["calamity"]!,
                    incidentDate: item["incidentDate"]!,
                    reportDate: item["reportDate"]!,
                    block: item["block"]!,
                    onView: () {
                      // open view
                    },
                    onEdit: () {
                      Get.to(() => ReportIncidentScreen());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnedReportCard extends StatelessWidget {
  final int index;
  final String prNo;
  final String calamity;
  final String incidentDate;
  final String reportDate;
  final String block;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _ReturnedReportCard({
    required this.index,
    required this.prNo,
    required this.calamity,
    required this.incidentDate,
    required this.reportDate,
    required this.block,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        shadowColor: Colors.black.withOpacity(0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onView,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: index + PR + status chip
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xffEEF2FF),
                      child: Text(
                        index.toString(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff4F46E5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prNo,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff111827)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(999)),
                      child: const Text(
                        "Returned",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff92400E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Calamity + block pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xffEFF6FF), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xff1D4ED8)),
                          const SizedBox(width: 4),
                          Text(calamity, style: const TextStyle(fontSize: 12, color: Color(0xff1D4ED8))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xffECFDF3), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff15803D)),
                          const SizedBox(width: 4),
                          Text(block, style: const TextStyle(fontSize: 12, color: Color(0xff166534))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dates row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 14, color: Color(0xff6B7280)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Incident: $incidentDate",
                              style: const TextStyle(fontSize: 12, color: Color(0xff4B5563)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_outlined, size: 14, color: Color(0xff6B7280)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Reported: $reportDate",
                              style: const TextStyle(fontSize: 12, color: Color(0xff4B5563)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),

                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                      label: const Text("View PR", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff2563EB)),
                    ),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text("Edit & Re-submit", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff15803D)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
