import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';

class ContactOfficialsScreen extends StatelessWidget {
  const ContactOfficialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xff6C63FF);

    final List<Map<String, String>> officials = [
      {"name": "Mr. Arvind Dey", "designation": "District Collector", "phone": "+91 98765 43210", "email": "arvind.dey@meghalaya.gov.in"},
      {"name": "Ms. Rina Marak", "designation": "Block Development Officer", "phone": "+91 87654 32109", "email": "rina.marak@meghalaya.gov.in"},
      {
        "name": "Mr. Samuel Sangma",
        "designation": "Relief & Rehabilitation Officer",
        "phone": "+91 99888 77665",
        "email": "samuel.sangma@meghalaya.gov.in",
      },
      {"name": "Dr. Anita Chyne", "designation": "Disaster Management Expert", "phone": "+91 98770 11223", "email": "anita.chyne@meghalaya.gov.in"},
      {"name": "Mr. John Roy", "designation": "Deputy Collector (Emergency)", "phone": "+91 77660 99887", "email": "john.roy@meghalaya.gov.in"},
    ];

    return AppScaffold(
      title: "Contact",
      currentRoute: 'contact_officials',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "We'd love to hear from you. Reach out with any queries or suggestions.",
              style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w400, letterSpacing: .05),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 28),

            // Main contact cards
            _SoftContactCard(
              icon: Icons.location_on_rounded,
              iconBg: LinearGradient(colors: [Color(0xff899efd), accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              title: "Location",
              content: "Secretariat Hills, Shillong - 793004, Meghalaya",
            ),
            SizedBox(height: 18),

            _SoftContactCard(
              icon: Icons.email_rounded,
              iconBg: LinearGradient(colors: [Color(0xfffdc7ff), accent.withOpacity(0.9)], begin: Alignment.topRight, end: Alignment.bottomLeft),
              title: "Email",
              content: "revenue-disaster@meghalaya.gov.in",
            ),
            SizedBox(height: 18),

            _SoftContactCard(
              icon: Icons.phone_rounded,
              iconBg: LinearGradient(colors: [Color(0xffb2f0df), accent], begin: Alignment.bottomLeft, end: Alignment.topRight),
              title: "Phone",
              content: "+91 364 2221234",
            ),

            SizedBox(height: 34),
            Text(
              "Key Officials",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color(0xff2D3142)),
            ),
            SizedBox(height: 12),
            Column(
              children: officials
                  .map(
                    (o) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _OfficialCard(name: o["name"]!, designation: o["designation"]!, phone: o["phone"]!, email: o["email"]!, accent: accent),
                    ),
                  )
                  .toList(),
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

  const _SoftContactCard({required this.icon, required this.iconBg, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(vertical: 26, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Color(0xff6C63FF).withOpacity(.08), blurRadius: 22, offset: Offset(0, 6)),
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: iconBg,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 26)),
          ),
          SizedBox(width: 22),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xff2D3142)),
                ),
                SizedBox(height: 7),
                Text(
                  content,
                  style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficialCard extends StatelessWidget {
  final String name;
  final String designation;
  final String phone;
  final String email;
  final Color accent;

  const _OfficialCard({required this.name, required this.designation, required this.phone, required this.email, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: accent.withOpacity(.03), blurRadius: 10, offset: Offset(0, 4))],
        border: Border.all(color: accent.withOpacity(.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading avatar (initials)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: accent.withOpacity(.12), shape: BoxShape.circle),
            child: Center(
              child: Text(
                _getInitials(name),
                style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 3),
                Text(designation, style: TextStyle(color: accent, fontSize: 14)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.grey, size: 16),
                    SizedBox(width: 5),
                    Text(phone, style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.grey, size: 16),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    return name.split(" ").where((part) => part.isNotEmpty).take(2).map((part) => part[0]).join().toUpperCase();
  }
}
