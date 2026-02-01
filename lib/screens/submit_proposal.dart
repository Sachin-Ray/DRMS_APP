import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'proposal_entry_screen.dart';

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

class SubmitProposalScreen extends StatelessWidget {
  const SubmitProposalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Submit Proposal",
      currentRoute: 'submit_proposal',
      body: Container(
        color: const Color(0xffF3F4F6),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _InfoBanner(),
            ),

            SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final item = _categories[index];

                  return _CategoryCard(
                    item: item,
                    onTap: () {
                      Get.to(
                        () => ProposalEntryScreen(
                          categoryTitle: item.title,
                          assistanceHead: item.assistanceHeadCode,
                          icon: item.icon,
                        ),
                      );
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

/* ---------------- TOP INFO BANNER ---------------- */

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  static const Color primaryPurple = Color(0xff6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.playlist_add_check_rounded,
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
                    "Submit Assistance Proposal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Select a category below to proceed with SDRF/NDRF norms.",
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
    );
  }
}

/* ---------------- CATEGORY CARD (IMAGE STYLE) ---------------- */

class _CategoryCard extends StatelessWidget {
  final ProposalCategory item;
  final VoidCallback onTap;

  const _CategoryCard({required this.item, required this.onTap});

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
                // ✅ ICON BOX (SOFT)
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, size: 28, color: item.color),
                ),

                const SizedBox(width: 14),

                // ✅ TITLE + SUBTITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ RIGHT ARROW
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

/* ---------------- CATEGORY LIST ---------------- */

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
    subtitle: "Support for livestock loss and cattle camps",
  ),
  ProposalCategory(
    icon: Icons.agriculture_rounded,
    title: "Agriculture & Horticulture",
    assistanceHeadCode: "AH-AG",
    color: Color(0xff16A34A),
    subtitle: "Financial aid for crop loss assistance",
  ),
  ProposalCategory(
    icon: Icons.set_meal_rounded,
    title: "Fishery",
    assistanceHeadCode: "AH-FS",
    color: Color(0xff0EA5E9),
    subtitle: "Assistance for damaged nets and boats",
  ),
  ProposalCategory(
    icon: Icons.handyman_rounded,
    title: "Handloom & Handicrafts",
    assistanceHeadCode: "AH-HD",
    color: Color(0xffDC2626),
    subtitle: "Aid for damaged tools and artisan goods",
  ),
  ProposalCategory(
    icon: Icons.house_rounded,
    title: "Housing Damage",
    assistanceHeadCode: "AH-HU",
    color: Color(0xff2563EB),
    subtitle: "Support for partially/fully damaged houses",
  ),
];
