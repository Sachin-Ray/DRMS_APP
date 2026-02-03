import 'package:drms/screens/about_screen.dart';
import 'package:drms/screens/contact_officials_creen.dart';
import 'package:drms/screens/home_screen.dart';
import 'package:drms/screens/pending_approvals.dart';
// import 'package:drms/screens/profile_screen.dart';
import 'package:drms/screens/report_incident_screen.dart';
import 'package:drms/screens/return_report.dart';
import 'package:drms/screens/submit_proposal.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

PageRouteBuilder<void> noAnimationRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

class AppDrawer extends StatefulWidget {
  final String currentRoute;
  const AppDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool reportsExpanded = false;
  bool approvalsExpanded = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xff6C63FF);
    const Color deepPurple = Color(0xff5A54D1);
    const Color pageBg = Color(0xffFAFAFC);

    return Drawer(
      backgroundColor: pageBg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: SvgPicture.asset(
                        'assets/disaster_relief.svg',
                        height: 32,
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder(
                      future: Session.instance.getUserDetails(),
                      builder: (_, snapshot) {
                        return Text(
                          snapshot.hasData
                              ? snapshot.data!.username.toUpperCase()
                              : 'Disaster Relief',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Welcome back!',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _modernDrawerTile(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  route: 'home',
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      noAnimationRoute(HomeScreen()),
                      (_) => false,
                    );
                  },
                ),

                SizedBox(height: 16),
                _sectionLabel('QUICK ACTIONS'),

                _modernDropdownTile(
                  icon: Icons.description_rounded,
                  label: 'Preliminary Reports',
                  isExpanded: reportsExpanded,
                  onTap: () {
                    setState(() {
                      reportsExpanded = !reportsExpanded;
                      approvalsExpanded = false;
                    });
                  },
                  children: [
                    _subMenuTile(
                      label: 'File Preliminary Report',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          noAnimationRoute(ReportIncidentScreen()),
                        );
                      },
                    ),
                    // _subMenuTile(
                    //   label: 'Submit Revised PR',
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.of(context).pushReplacement(
                    //       noAnimationRoute(ReturnReportScreen()),
                    //     );
                    //   },
                    // ),
                  ],
                ),

                SizedBox(height: 12),

                _modernDropdownTile(
                  icon: Icons.verified_rounded,
                  label: 'Proposal',
                  isExpanded: approvalsExpanded,
                  onTap: () {
                    setState(() {
                      approvalsExpanded = !approvalsExpanded;
                      reportsExpanded = false;
                    });
                  },
                  children: [
                    _subMenuTile(
                      label: 'Submit Proposal',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          noAnimationRoute(SubmitProposalScreen()),
                        );
                      },
                    ),
                    // _subMenuTile(
                    //   label: 'Drafted Proposal',
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.of(context).pushReplacement(
                    //       noAnimationRoute(PendingApprovalScreen()),
                    //     );
                    //   },
                    // ),
                  ],
                ),

                SizedBox(height: 16),
                _sectionLabel('OTHERS'),

                _modernDrawerTile(
                  icon: Icons.contacts_rounded,
                  label: 'Contact Officials',
                  route: 'contact',
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      noAnimationRoute(ContactOfficialsScreen()),
                    );
                  },
                ),

                // _modernDrawerTile(
                //   icon: Icons.person_rounded,
                //   label: 'Profile',
                //   route: 'profile',
                //   context: context,
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.of(context).pushReplacement(
                //       noAnimationRoute(ProfileScreen()),
                //     );
                //   },
                // ),
                _modernDrawerTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  route: 'about',
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                    ).pushReplacement(noAnimationRoute(AboutScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Color(0xff9CA3AF),
      ),
    ),
  );

  Widget _subMenuTile({required String label, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xffE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.circle, size: 6, color: Color(0xff6C63FF)),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernDropdownTile({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    const Color primaryPurple = Color(0xff6C63FF);
    const Color warmOrange = Color(0xffF4A261);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isExpanded ? warmOrange.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? warmOrange.withOpacity(0.15)
                          : primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isExpanded ? warmOrange : primaryPurple,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: Duration(milliseconds: 250),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: SizedBox(),
          secondChild: Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _modernDrawerTile({
    required IconData icon,
    required String label,
    required String route,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    const Color primaryPurple = Color(0xff6C63FF);
    final bool isActive = widget.currentRoute == route;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? primaryPurple.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: primaryPurple),
              SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
