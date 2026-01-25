import 'package:drms/app_scaffold.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Profile data
  String name = "Amit Kumar";
  String designation = "Assistant Manager (IT)";
  String organization = "IIM Shillong";
  String email = "amit.kumar@iimshillong.ac.in";
  String phone = "+91-9876543210";
  String photoUrl = "https://avatars.githubusercontent.com/u/38918525";

  String state = "Meghalaya";
  String district = "East Khasi Hills";
  String block = "Mylliem";
  String village = "Nongthymmai";

  // To hold edits while in edit mode
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController districtCtrl;
  late TextEditingController blockCtrl;
  late TextEditingController villageCtrl;

  bool editMode = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    nameCtrl = TextEditingController(text: name);
    emailCtrl = TextEditingController(text: email);
    phoneCtrl = TextEditingController(text: phone);
    stateCtrl = TextEditingController(text: state);
    districtCtrl = TextEditingController(text: district);
    blockCtrl = TextEditingController(text: block);
    villageCtrl = TextEditingController(text: village);
  }

  void _startEdit() {
    setState(() {
      editMode = true;
      _initControllers(); // Reload with latest values
    });
  }

  void _saveEdit() {
    setState(() {
      name = nameCtrl.text;
      email = emailCtrl.text;
      phone = phoneCtrl.text;
      state = stateCtrl.text;
      district = districtCtrl.text;
      block = blockCtrl.text;
      village = villageCtrl.text;
      editMode = false;
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    blockCtrl.dispose();
    villageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Profile",
      currentRoute: 'profile',
      // actions: [
      //   IconButton(icon: Icon(editMode ? Icons.save : Icons.edit), tooltip: editMode ? "Save" : "Edit", onPressed: editMode ? _saveEdit : _startEdit),
      // ],
      floatingActionButton: FloatingActionButton(
        onPressed: editMode ? _saveEdit : _startEdit,
        backgroundColor: Color(0xff6C63FF),
        child: Icon(editMode ? Icons.save : Icons.edit, color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xff6C63FF),
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty ? Icon(Icons.person, color: Colors.white, size: 54) : null,
                ),
                SizedBox(height: 16),
                _profileField(
                  label: "Name",
                  value: name,
                  ctrl: nameCtrl,
                  editing: editMode,
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xff2D3142)),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Contact Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff2D3142)),
                ),
                Divider(height: 28, color: Color(0xffF5F5F7)),
                Row(
                  children: [
                    Icon(Icons.email_rounded, color: Color(0xff6C63FF)),
                    SizedBox(width: 12),
                    Flexible(
                      child: _profileField(label: "", value: email, ctrl: emailCtrl, editing: editMode),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, color: Color(0xff6C63FF)),
                    SizedBox(width: 12),
                    Flexible(
                      child: _profileField(label: "", value: phone, ctrl: phoneCtrl, editing: editMode),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded, color: Color(0xff6C63FF)),
                    SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _profileField(label: "State", value: state, ctrl: stateCtrl, editing: editMode),
                          SizedBox(height: 2),
                          _profileField(label: "District", value: district, ctrl: districtCtrl, editing: editMode),
                          SizedBox(height: 2),
                          _profileField(label: "Block", value: block, ctrl: blockCtrl, editing: editMode),
                          SizedBox(height: 2),
                          _profileField(label: "Village", value: village, ctrl: villageCtrl, editing: editMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _profileField({
    required String label,
    required String value,
    required TextEditingController ctrl,
    required bool editing,
    TextStyle? textStyle,
  }) {
    if (!editing) {
      // READ-ONLY
      final style = textStyle ?? TextStyle(fontSize: 15, color: Color(0xff2D3142), fontWeight: FontWeight.w500);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty && label != "Name") Text(label, style: TextStyle(fontSize: 13, color: Color(0xff9098A5))),
          Text(value, style: style),
        ],
      );
    } else {
      // EDITABLE
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) Text(label, style: TextStyle(fontSize: 13, color: Color(0xff9098A5))),
          TextField(
            controller: ctrl,
            style: textStyle ?? TextStyle(fontSize: 15, color: Color(0xff2D3142), fontWeight: FontWeight.w500),
          ),
        ],
      );
    }
  }
}
