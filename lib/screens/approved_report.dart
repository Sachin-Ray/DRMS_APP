import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';

class ApprovedReportScreen extends StatelessWidget {
  const ApprovedReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data – replace with your approved list
    final reports = List.generate(5, (index) {
      return {
        "prNo": "PR/2026/01${index + 1}",
        "calamity": "Flood",
        "incidentDate": "05 Jan 2026",
        "district": "East Khasi Hills",
        "block": "Mylliem",
      };
    });

    return AppScaffold(
      title: "Approved Report",
      currentRoute: 'approved_report',
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
                      "Approved Preliminary Reports",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xffDCFCE7), borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      "${reports.length}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff15803D)),
                    ),
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 16, color: Color(0xff16A34A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "These reports have been approved. Tap to view or export.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xff6B7280)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // List of cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final item = reports[index];
                  return _ApprovedReportCard(
                    index: index + 1,
                    prNo: item["prNo"]!,
                    calamity: item["calamity"]!,
                    incidentDate: item["incidentDate"]!,
                    district: item["district"]!,
                    block: item["block"]!,
                    onView: () {
                      // open view / pdf
                    },
                    onDownload: () {
                      // download / share pdf
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

class _ApprovedReportCard extends StatelessWidget {
  final int index;
  final String prNo;
  final String calamity;
  final String incidentDate;
  final String district;
  final String block;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const _ApprovedReportCard({
    required this.index,
    required this.prNo,
    required this.calamity,
    required this.incidentDate,
    required this.district,
    required this.block,
    required this.onView,
    required this.onDownload,
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
                      backgroundColor: const Color(0xffDCFCE7),
                      child: Text(
                        index.toString(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff166534)),
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
                      decoration: BoxDecoration(color: const Color(0xffDCFCE7), borderRadius: BorderRadius.circular(999)),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: Color(0xff16A34A)),
                          SizedBox(width: 4),
                          Text(
                            "Approved",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff166534)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Calamity + date pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xffEFF6FF), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: Color(0xff1D4ED8)),
                          const SizedBox(width: 4),
                          Text(calamity, style: const TextStyle(fontSize: 12, color: Color(0xff1D4ED8))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 14, color: Color(0xff92400E)),
                          const SizedBox(width: 4),
                          Text(incidentDate, style: const TextStyle(fontSize: 12, color: Color(0xff92400E))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // District + Block row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined, size: 14, color: Color(0xff6B7280)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              district,
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
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff6B7280)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              block,
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
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text("View PR", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff2563EB)),
                    ),
                    TextButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text("Download PDF", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff0F766E)),
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
