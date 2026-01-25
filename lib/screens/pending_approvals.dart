import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data – replace with your pending list
    final reports = List.generate(5, (index) {
      return {
        "prNo": "PR/2026/02${index + 1}",
        "calamity": "Landslide",
        "incidentDate": "10 Jan 2026",
        "district": "East Khasi Hills",
        "block": "Mylliem",
      };
    });

    return AppScaffold(
      title: "Pending Approval",
      currentRoute: 'pending_approval',
      body: Container(
        color: const Color(0xffF3F4F6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + count
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Text(
            //           "Preliminary Reports Pending Approval",
            //           style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            //         ),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //         decoration: BoxDecoration(color: const Color(0xffE0F2FE), borderRadius: BorderRadius.circular(999)),
            //         child: Text(
            //           "${reports.length}",
            //           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff0369A1)),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // // Subtitle
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.assignment_outlined, size: 16, color: Color(0xff6B7280)),
            //       const SizedBox(width: 6),
            //       Expanded(
            //         child: Text(
            //           "Review each preliminary report, then approve or reject with remarks.",
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
                  return _PendingApprovalCard(
                    index: index + 1,
                    prNo: item["prNo"]!,
                    calamity: item["calamity"]!,
                    incidentDate: item["incidentDate"]!,
                    district: item["district"]!,
                    block: item["block"]!,
                    onView: () {
                      // open view / pdf
                    },
                    onApprove: () {
                      // show confirmation / API approve
                    },
                    onReject: () {
                      // show reject dialog with remarks
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

class _PendingApprovalCard extends StatelessWidget {
  final int index;
  final String prNo;
  final String calamity;
  final String incidentDate;
  final String district;
  final String block;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingApprovalCard({
    required this.index,
    required this.prNo,
    required this.calamity,
    required this.incidentDate,
    required this.district,
    required this.block,
    required this.onView,
    required this.onApprove,
    required this.onReject,
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
                      backgroundColor: const Color(0xffE0F2FE),
                      child: Text(
                        index.toString(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff0369A1)),
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
                      child: const Row(
                        children: [
                          Icon(Icons.hourglass_bottom_rounded, size: 14, color: Color(0xff92400E)),
                          SizedBox(width: 4),
                          Text(
                            "Pending",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff92400E)),
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

                // Actions row: View + Approve + Reject
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text("View PR", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff2563EB)),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text("Reject", style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xffB91C1C)),
                        ),
                        TextButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text("Approve", style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(foregroundColor: const Color(0xff16A34A)),
                        ),
                      ],
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
