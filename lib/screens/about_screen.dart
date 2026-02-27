import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "About",
      currentRoute: 'about',
     body: CustomScrollView(
  slivers: [
    /// ================= MAIN CONTENT =================
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App icon circle
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff6C63FF).withOpacity(0.08),
                border: Border.all(
                  color: const Color(0xff6C63FF).withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: SvgPicture.asset(
                'assets/disaster_relief.svg',
                height: 80,
              ),
            ),

            const SizedBox(height: 18),

            // Title
            const Text(
              "Disaster & Relief \nMonitoring System App",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xff6C63FF),
              ),
            ),

            const SizedBox(height: 20),

            // Description card
            _AboutTextCard(
              text:
                  "This app, developed for the Revenue and Disaster Management Department, Meghalaya, helps citizens and officials manage disaster assistance, relief, and communication.\n\nIt streamlines requests and relief processes under the National Disaster Response Fund (NDRF) and State Disaster Response Fund (SDRF), making disaster management accessible, transparent, and faster.\n\nCoordinated by the Revenue Department, the platform brings together BDOs, DCs, and state offices for improved disaster response across Meghalaya.",
            ),
          ],
        ),
      ),
    ),

    /// ================= FOOTER AT BOTTOM =================
    SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: const [
          Spacer(),
          _NicBottomFooter(),
        ],
      ),
    ),
  ],
),
);
  }
}

//
// ================= TEXT CARD =================
//
class _AboutTextCard extends StatelessWidget {
  final String text;

  const _AboutTextCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          height: 1.55,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

//
// ================= NIC FOOTER =================
//
class _NicBottomFooter extends StatelessWidget {
  const _NicBottomFooter();

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xff6C63FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: accent.withOpacity(0.15))),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// NIC LOGO (smaller & responsive)
          Flexible(
            flex: 0,
            child: Image.asset(
              "assets/logo/nic_logo.png",
              height: 40, // reduced to prevent overflow
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 24),

          /// TEXT COLUMN (takes remaining space safely)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Designed & Developed by",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "National Informatics Centre",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff2D3142),
                  ),
                  softWrap: true,
                ),
                Text(
                  "Meghalaya",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
