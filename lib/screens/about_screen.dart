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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: SvgPicture.asset('assets/disaster_relief.svg', height: 70),
            ),
            Text(
              "Disaster Relief App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xff6C63FF)),
            ),
            SizedBox(height: 18),
            Text(
              "This app, developed for the Revenue and Disaster Management Department, Meghalaya, helps citizens and officials manage disaster assistance, relief, and communication.",
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            Text(
              "It streamlines requests and relief processes under the National Disaster Response Fund (NDRF) and State Disaster Response Fund (SDRF), making disaster management accessible, transparent, and faster.",
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            Text(
              "Coordinated by the Revenue Department, the platform brings together BDOs, DCs, and state offices for improved disaster response across Meghalaya.",
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
