import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drms/app_scaffold.dart';
import 'proposal_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryPurple = Color(0xff6C63FF);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Disaster Relief",
      currentRoute: 'home',
      body: Container(
        color: const Color(0xffF3F4F6),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          children: [

            /* ---------------- WELCOME CARD ---------------- */

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [primaryPurple, Color(0xff5A54D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.waving_hand_rounded,
                        color: Colors.white, size: 34),
                    SizedBox(height: 12),
                    Text(
                      "Welcome to the DRMS Mobile App",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Using this app, you can:\n\n"
                      "• Submission of the incident report - PR Submission\n"
                      "• Initiation of a proposal by Submitting Beneficiary Details \n\n"
                      "Below are the proposal categories:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // const SizedBox(height: 24),

            // /* ---------------- PR SUBMISSION CARD ---------------- */

            // _ActivityCard(
            //   icon: Icons.report_problem_rounded,
            //   title: "PR Submission",
            //   subtitle: "Submit Preliminary Incident Report",
            //   color: Color(0xffEF4444),
            //   onTap: () {
            //     // Navigate to PR screen
            //   },
            // ),

            // const SizedBox(height: 20),

            /* ---------------- PROPOSAL SECTION TITLE ---------------- */

            // const Text(
            //   "Submit Assistance Proposal",
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w700,
            //     color: Color(0xff1E3A8A),
            //   ),
            // ),

            const SizedBox(height: 24),

            /* ---------------- PROPOSAL CATEGORY CARDS ---------------- */

            ..._categories.map(
              (item) => _ActivityCard(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                color: item.color,
                onTap: () {
                  Get.to(
                    () => ProposalEntryScreen(
                      categoryTitle: item.title,
                      assistanceHead: item.assistanceHeadCode,
                      icon: item.icon,
                    ),
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

/* ---------------- REUSABLE ACTIVITY CARD ---------------- */

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 26,
                  color: Color(0xff9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- PROPOSAL CATEGORY MODEL ---------------- */

class ProposalCategory {
  final IconData icon;
  final String title;
  final String assistanceHeadCode;
  final Color color;
  final String subtitle;

  ProposalCategory({
    required this.icon,
    required this.title,
    required this.assistanceHeadCode,
    required this.color,
    required this.subtitle,
  });
}

/* ---------------- DRMS 6 PROPOSALS ---------------- */

final List<ProposalCategory> _categories = [
  ProposalCategory(
    icon: Icons.volunteer_activism_rounded,
    title: "Gratuitous Relief",
    assistanceHeadCode: "AH-GR",
    color: Color(0xffF59E0B),
    subtitle: "Ex-gratia assistance for affected families",
  ),
  ProposalCategory(
    icon: Icons.pets_rounded,
    title: "Animal Husbandry",
    assistanceHeadCode: "AH-LS",
    color: Color(0xff7C3AED),
    subtitle: "Support for livestock loss",
  ),
  ProposalCategory(
    icon: Icons.agriculture_rounded,
    title: "Agriculture & Horticulture",
    assistanceHeadCode: "AH-AG",
    color: Color(0xff16A34A),
    subtitle: "Crop damage assistance",
  ),
  ProposalCategory(
    icon: Icons.set_meal_rounded,
    title: "Fishery",
    assistanceHeadCode: "AH-FS",
    color: Color(0xff0EA5E9),
    subtitle: "Damaged boats & nets assistance",
  ),
  ProposalCategory(
    icon: Icons.handyman_rounded,
    title: "Handloom & Handicrafts",
    assistanceHeadCode: "AH-HD",
    color: Color(0xffDC2626),
    subtitle: "Support for artisan tool loss",
  ),
  ProposalCategory(
    icon: Icons.house_rounded,
    title: "Housing Damage",
    assistanceHeadCode: "AH-HU",
    color: Color(0xff2563EB),
    subtitle: "Fully / partially damaged house aid",
  ),
];