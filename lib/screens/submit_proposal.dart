import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'proposal_entry_screen.dart';

class ProposalCategory {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final String assistanceHeadCode;

  ProposalCategory({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.assistanceHeadCode,
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _InfoCard(),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900
                      ? 4
                      : MediaQuery.of(context).size.width > 600
                      ? 2
                      : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final item = _categories[index];
                  return _CategoryCard(
                    item: item,
                    onTap: () {
                      Get.to(
                        () => ProposalEntryScreen(categoryTitle: item.title, assistanceHead: item.assistanceHeadCode),
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

/* ---------------- INFO CARD ---------------- */

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(
                  Icons.playlist_add_check_rounded,
                  color: Color(0xff2563EB),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Select a category to submit assistance proposal",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              "Categories follow SDRF/NDRF norms for approved assistance.",
              style: TextStyle(fontSize: 13, color: Color(0xff6B7280)),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xffDC2626),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Proposal submission is allowed only after PR approval by DC.",
                    style: TextStyle(fontSize: 13, color: Color(0xffB91C1C)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- CATEGORY CARD ---------------- */

class _CategoryCard extends StatelessWidget {
  final ProposalCategory item;
  final VoidCallback onTap;

  const _CategoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 18, color: const Color(0xff15803D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xff4B5563)),
              ),
              const Spacer(),
              const Divider(height: 1),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    "Go To Assistance",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<ProposalCategory> _categories = [
  ProposalCategory(
    icon: Icons.volunteer_activism_rounded,
    title: "Gratuitous Relief",
    description:
        "Ex-gratia assistance to affected families including household goods.",
    route: '/gratuity_relief',
    assistanceHeadCode: "AH-GR",
  ),
  // ProposalCategory(
  //   icon: Icons.pets_rounded,
  //   title: "Animal Husbandry",
  //   description:
  //       "Assistance for livestock loss, feed, medicines, and cattle camps.",
  // ),
  // ProposalCategory(
  //   icon: Icons.health_and_safety_rounded,
  //   title: "Relief Measures",
  //   description:
  //       "Temporary shelter, food, medical care, water, and rescue services.",
  // ),
  ProposalCategory(
    icon: Icons.agriculture_rounded,
    title: "Agriculture & Horticulture Loss",
    description: "Financial aid for crop loss and damaged horticulture assets.",
    route: '/agriculture_horticulture',
     assistanceHeadCode: "AH-AG",
  ),
  ProposalCategory(
    icon: Icons.set_meal_rounded,
    title: "Fishery",
    description: "Repair or replacement of boats, nets, and fishery equipment.",
    route: '/fishery',
    assistanceHeadCode: "AH-FS",
  ),
  ProposalCategory(
    icon: Icons.handyman_rounded,
    title: "Handloom & Handicrafts",
    description: "Aid for damaged tools, materials, and artisan equipment.",
    route: '/handloom_handicrafts',
    assistanceHeadCode: "AH-HU",
  ),
  ProposalCategory(
    icon: Icons.house_rounded,
    title: "Housing Damage",
    description:
        "Support for fully or partially damaged houses and cattle sheds.",
    route: '/housing_damage',
    assistanceHeadCode: "AH-HD",
  ),
  // ProposalCategory(
  //   icon: Icons.apartment_rounded,
  //   title: "Infrastructure Damage",
  //   description:
  //       "Restoration of roads, bridges, power, water, schools, PHCs.",
  // ),
];
