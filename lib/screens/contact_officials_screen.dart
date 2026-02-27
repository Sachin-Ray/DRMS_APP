import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactOfficialsScreen extends StatelessWidget {
  const ContactOfficialsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xff6C63FF);

    return AppScaffold(
      title: "Contact",
      currentRoute: 'contact_officials',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "We'd love to hear from you. Reach out with any queries or suggestions.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                letterSpacing: .05,
              ),
            ),
            const SizedBox(height: 28),

            _SoftContactCard(
              icon: Icons.location_on_rounded,
              iconBg: const LinearGradient(
                colors: [Color(0xff899efd), accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              title: "Location",
              content: "Secretariat Hills, Shillong - 793004, Meghalaya",
              onTap: () => _launchUrl(
                "https://www.google.com/maps/search/?api=1&query=Secretariat+Hills+Shillong",
              ),
            ),

            const SizedBox(height: 18),

            _SoftContactCard(
              icon: Icons.email_rounded,
              iconBg: LinearGradient(
                colors: [const Color(0xfffdc7ff), accent.withOpacity(0.9)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              title: "Email",
              content: "revenue-disaster@meghalaya.gov.in",
              onTap: () => _launchUrl(
                "mailto:revenue-disaster@meghalaya.gov.in",
              ),
            ),

            const SizedBox(height: 18),

            _SoftContactCard(
              icon: Icons.phone_rounded,
              iconBg: const LinearGradient(
                colors: [Color(0xffb2f0df), accent],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              title: "Phone",
              content: "+91 364 2221234",
              onTap: () => _launchUrl(
                "tel:+913642221234",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftContactCard extends StatelessWidget {
  final IconData icon;
  final Gradient iconBg;
  final String title;
  final String content;
  final VoidCallback? onTap;

  const _SoftContactCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff6C63FF).withOpacity(.08),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: iconBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ),

            const SizedBox(width: 22),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xff2D3142),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
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
