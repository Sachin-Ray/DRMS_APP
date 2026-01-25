import 'dart:convert';

import 'package:drms/app_scaffold.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Calamity.dart';
import 'package:drms/model/Infrastructure.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/screens/home_screen.dart';
import 'package:drms/services/APIService.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PublicPropertyDamageRow {
  Infrastructure? infrastructure;
  TextEditingController totalController = TextEditingController();
}

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  List<PublicPropertyDamageRow> publicPropertyRows = [];

  // Controllers
  final TextEditingController populationController = TextEditingController();
  final TextEditingController cropController = TextEditingController();
  final TextEditingController reliefController = TextEditingController();
  final TextEditingController responseController = TextEditingController();
  final TextEditingController forecastController = TextEditingController();
  final TextEditingController otherInfoController = TextEditingController();

  // File picker state
  List<File> selectedImages = [];
  List<String> filePaths = [];
  final ImagePicker _picker = ImagePicker();
  bool isPicking = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int noOfVillages = 0;

  // Person/animal fields
  bool isDead = false, isMissing = false, isInjured = false;
  bool isAnimalAffected = false, isAnimalLost = false, isAnimalDead = false;
  final deadController = TextEditingController();
  final missingController = TextEditingController();
  final injuredController = TextEditingController();
  final animalAffectedController = TextEditingController();
  final animalLostController = TextEditingController();
  final animalDeadController = TextEditingController();

  // House damage fields
  bool houseFully = false, housePartially = false;
  final houseFullyController = TextEditingController();
  final housePartiallyController = TextEditingController();

  // Colors
  static const Color primaryPurple = Color(0xff6C63FF);
  static const Color errorRed = Color(0xffE76F51);

  // Calamity data
  List<Calamity> calamityList = [];
  Calamity? selectedCalamity;
  bool isCalamityLoading = true;

  // Block data
  List<Block> blockList = [];
  Block? selectedBlock;
  bool isBlockLoading = false;

  // Village data
  List<Village> villageList = [];
  List<Village> selectedVillages = [];
  bool isVillageLoading = false;

  List<Infrastructure> infrastructureList = [];
  bool isInfrastructureLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalamities();
    _loadBlocksIfNeeded();
    _loadVillagesForBDO();
    _loadInfrastructures();
  }

  Future<void> _loadCalamities() async {
    final list = await APIService.instance.getAllCalamities();
    if (mounted) {
      setState(() {
        calamityList = list ?? [];
        isCalamityLoading = false;
      });
    }
  }

  Future<void> _loadBlocksIfNeeded() async {
    final user = await Session.instance.getUserDetails();
    if (user == null) return;

    if (user.roles == 'ROLE_DEPT') {
      setState(() => isBlockLoading = true);

      final blocks = await APIService.instance.getAllBlocks(user.districtcode);

      if (!mounted) return;

      setState(() {
        blockList = blocks ?? [];
        isBlockLoading = false;
      });
    }
  }

  Future<void> _loadVillagesByBlock(int blockCode) async {
    setState(() {
      isVillageLoading = true;
      villageList.clear();
      selectedVillages.clear();
    });

    final villages = await APIService.instance.getAllVillages(blockCode);

    if (!mounted) return;

    setState(() {
      villageList = villages ?? [];
      isVillageLoading = false;

      // ✅ AUTO-SELECT if only ONE village
      if (villageList.length == 1) {
        selectedVillages = [villageList.first];
        noOfVillages = 1;
      }
    });
  }

  Future<void> _loadVillagesForBDO() async {
    final user = await Session.instance.getUserDetails();
    if (user != null && user.roles == 'ROLE_BDO') {
      _loadVillagesByBlock(user.blockcode);
    }
  }

  Future<void> _loadInfrastructures() async {
    final list = await APIService.instance.getInfrastructures();
    if (!mounted) return;

    setState(() {
      infrastructureList = list ?? [];
      isInfrastructureLoading = false;
    });
  }

  // File picker functions
  // Future<void> _pickImages() async {
  //   if (isPicking) return;

  //   setState(() => isPicking = true);

  //   try {
  //     final List<XFile?>? xFiles = await _picker.pickMultiImage(
  //       maxWidth: 1200,
  //       maxHeight: 1200,
  //       imageQuality: 85,
  //       limit: 5 - selectedImages.length,
  //     );

  //     if (xFiles != null && xFiles.isNotEmpty) {
  //       for (var xFile in xFiles) {
  //         if (xFile != null) {
  //           final file = File(xFile.path);
  //           final fileSize = await file.length();
  //           if (fileSize <= 2 * 1024 * 1024) {
  //             setState(() {
  //               selectedImages.add(file);
  //             });
  //           } else {
  //             if (mounted) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text("Image too large. Max 2MB allowed."),
  //                   backgroundColor: Colors.orange,
  //                 ),
  //               );
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Failed to pick images")));
  //     }
  //   } finally {
  //     if (mounted) setState(() => isPicking = false);
  //   }
  // }
  Future<void> _pickImages() async {
    if (isPicking) return;

    setState(() => isPicking = true);

    try {
      final List<XFile?>? xFiles = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        limit: 5 - selectedImages.length,
      );

      if (xFiles != null && xFiles.isNotEmpty) {
        for (var xFile in xFiles) {
          if (xFile != null) {
            await _addImage(File(xFile.path));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pick images")));
      }
    } finally {
      if (mounted) setState(() => isPicking = false);
    }
  }

  Future<void> _takePhoto() async {
    if (isPicking || selectedImages.length >= 5) return;

    setState(() => isPicking = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        await _addImage(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to capture photo")));
      }
    } finally {
      if (mounted) setState(() => isPicking = false);
    }
  }

  Future<void> _addImage(File file) async {
    final fileSize = await file.length();

    if (fileSize > 2 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image too large. Max 2MB allowed."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedImages.length >= 5) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can upload maximum 5 photos."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      selectedImages.add(file);
    });
  }

  // Future<void> _pickAnyFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
  //     allowMultiple: true,
  //     withData: true,
  //   );

  //   if (result != null) {
  //     for (var file in result.files) {
  //       final fileSize = file.size;
  //       if (fileSize <= 2 * 1024 * 1024) {
  //         setState(() {
  //           filePaths.add(file.path ?? '');
  //         });
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text("File too large. Max 2MB allowed."),
  //             backgroundColor: Colors.orange,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // void _removeFile(int index) {
  //   setState(() {
  //     filePaths.removeAt(index);
  //   });
  // }

  // Handlers
  void _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: selectedDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _pickTime() async {
    TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (t != null) setState(() => selectedTime = t);
  }

  Future<void> submitIncidentReport() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text("Uploading..."),
        content: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
    );

    try {
      final user = await Session.instance.getUserDetails();

      //  FILES
      final List<Map<String, dynamic>> filesPayload = [];
      for (final file in selectedImages) {
        final bytes = await file.readAsBytes();
        filesPayload.add({
          "filename": file.path.split('/').last,
          "contentType": "image/jpeg",
          "base64Data": base64Encode(bytes),
        });
      }

      // INFRASTRUCTURE MAP
      final Map<String, int> infrastructureMap = {};
      for (final row in publicPropertyRows) {
        if (row.infrastructure != null && row.totalController.text.isNotEmpty) {
          infrastructureMap[row.infrastructure!.infrastructureId.toString()] =
              int.parse(row.totalController.text);
        }
      }

      // VILLAGES
      final List<String> villageCodes = selectedVillages
          .map((v) => v.villagecode)
          .toList();

      // FINAL PAYLOAD
      final payload = {
        "calamityId": selectedCalamity!.calamityId,
        "blockcode": user!.roles == 'ROLE_BDO'
            ? user.blockcode
            : selectedBlock!.blockcode,
        "dateOfCalamityOccurence":
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
        "time_of_calamity_occurenceDate": selectedTime!.format(context),
        "no_villages_affected": villageCodes.length,
        "human_population_affected":
            int.tryParse(populationController.text) ?? 0,

        "people_dead": isDead ? int.parse(deadController.text) : 0,
        "people_missing": isMissing ? int.parse(missingController.text) : 0,
        "people_injured": isInjured ? int.parse(injuredController.text) : 0,

        "animals_dead": isAnimalDead ? int.parse(animalDeadController.text) : 0,
        "animals_lost": isAnimalLost ? int.parse(animalLostController.text) : 0,
        "animals_affected": isAnimalAffected
            ? int.parse(animalAffectedController.text)
            : 0,

        "crop_affected": cropController.text,
        "house_fully": houseFully ? int.parse(houseFullyController.text) : 0,
        "house_partially": housePartially
            ? int.parse(housePartiallyController.text)
            : 0,

        "relief_measure": reliefController.text,
        "immediate_response": responseController.text,
        "forecast": forecastController.text,
        "other_info": otherInfoController.text,

        "infrastructures": infrastructureMap,
        "villages": villageCodes,
        "files": filesPayload,
      };

      final result = await APIService.instance.submitIncidentReport(payload);

      Navigator.pop(context);

      if (result == null) {
        _showErrorDialog("Unable to submit report. Please try again.");
        return;
      }

      final String status = result['status']?.toString() ?? '';
      final String message = result['message']?.toString() ?? '';
      final String prNumber = result['data']?.toString() ?? '';

      if (status == "SUCCESS") {
        _showSuccessDialog(prNumber);
      } else {
        _showErrorDialog(
          message.isNotEmpty ? message : "Failed to submit report",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(e.toString());
    }
  }

  @override
  void dispose() {
    populationController.dispose();
    cropController.dispose();
    reliefController.dispose();
    responseController.dispose();
    forecastController.dispose();
    otherInfoController.dispose();
    deadController.dispose();
    missingController.dispose();
    injuredController.dispose();
    animalAffectedController.dispose();
    animalLostController.dispose();
    animalDeadController.dispose();
    houseFullyController.dispose();
    housePartiallyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Report Incident",
      currentRoute: 'report_incident',
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, Color(0xff5A54D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Disaster Incident Report",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Please provide accurate information about the incident",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    _buildSectionCard(
                      title: "Basic Information",
                      icon: Icons.info_outline_rounded,
                      children: [
                        _buildRequiredLabel("Type and Nature of Calamity"),
                        SizedBox(height: 8),
                        DropdownButtonFormField<Calamity>(
                          initialValue: selectedCalamity,
                          decoration: _inputDecoration("Select calamity type"),
                          isExpanded: true,
                          items: calamityList
                              .map(
                                (c) => DropdownMenuItem<Calamity>(
                                  value: c,
                                  child: Text(c.calamityName),
                                ),
                              )
                              .toList(),
                          onChanged: isCalamityLoading
                              ? null
                              : (v) => setState(() => selectedCalamity = v),
                          validator: (value) =>
                              value == null ? "This field is required" : null,
                        ),

                        SizedBox(height: 20),
                        Row(
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRequiredLabel("Date"),
                                  SizedBox(height: 8),
                                  InkWell(
                                    onTap: _pickDate,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xffF5F5F7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffE5E7EB),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            color: primaryPurple,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              selectedDate != null
                                                  ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                                  : "Select date",
                                              style: TextStyle(
                                                color: selectedDate != null
                                                    ? Color(0xff2D3142)
                                                    : Color(0xff9CA3AF),
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRequiredLabel("Time"),
                                  SizedBox(height: 8),
                                  InkWell(
                                    onTap: _pickTime,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xffF5F5F7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffE5E7EB),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            color: primaryPurple,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              selectedTime != null
                                                  ? selectedTime!.format(
                                                      context,
                                                    )
                                                  : "Select time",
                                              style: TextStyle(
                                                color: selectedTime != null
                                                    ? Color(0xff2D3142)
                                                    : Color(0xff9CA3AF),
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildRequiredLabel("Affected Block"),
                        SizedBox(height: 8),

                        FutureBuilder(
                          future: Session.instance.getUserDetails(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox();
                            }

                            final user = snapshot.data!;

                            // For ROLE_BDO -> block comes from login
                            if (user.roles == 'ROLE_BDO') {
                              return TextFormField(
                                enabled: false,
                                initialValue: user.blockname,
                                decoration: _inputDecoration("Block name"),
                                style: TextStyle(color: Color(0xff6B7280)),
                              );
                            }
                            // For ROLE_DEPT -> fetch block list
                            return DropdownButtonFormField<Block>(
                              initialValue: selectedBlock,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                isBlockLoading
                                    ? "Loading blocks..."
                                    : "Select block",
                              ),
                              items: blockList
                                  .map(
                                    (b) => DropdownMenuItem<Block>(
                                      value: b,
                                      child: Text(b.blockname),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isBlockLoading
                                  ? null
                                  : (v) {
                                      setState(() {
                                        selectedBlock = v;
                                      });

                                      if (v != null) {
                                        _loadVillagesByBlock(v.blockcode);
                                      }
                                    },

                              validator: (v) =>
                                  v == null ? "This field is required" : null,
                            );
                          },
                        ),

                        SizedBox(height: 20),
                        _buildRequiredLabel("Villages Affected"),
                        SizedBox(height: 8),

                        MultiSelectDialogField<Village>(
                          items: villageList
                              .map(
                                (v) =>
                                    MultiSelectItem<Village>(v, v.villagename),
                              )
                              .toList(),
                          initialValue: selectedVillages,
                          searchable: true,
                          title: Text("Select Villages"),
                          buttonIcon: Icon(
                            Icons.location_city_rounded,
                            color: primaryPurple,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffF5F5F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xffE5E7EB)),
                          ),
                          buttonText: Text(
                            isVillageLoading
                                ? "Loading villages..."
                                : selectedVillages.isEmpty
                                ? "Select villages"
                                : "${selectedVillages.length} village(s) selected",
                            style: TextStyle(
                              color: selectedVillages.isEmpty
                                  ? Color(0xff9CA3AF)
                                  : Color(0xff2D3142),
                              fontSize: 15,
                            ),
                          ),
                          onConfirm: (values) {
                            setState(() {
                              selectedVillages = values;
                              noOfVillages = values.length;
                            });
                          },
                          validator: (values) =>
                              values == null || values.isEmpty
                              ? "Select at least one village"
                              : null,
                        ),

                        if (noOfVillages > 0) ...[
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$noOfVillages village${noOfVillages > 1 ? 's' : ''} affected",
                              style: TextStyle(
                                color: primaryPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        _buildLabel("Total Population Affected"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: populationController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            "Enter number of people",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Casualties & Impact Card
                    _buildSectionCard(
                      title: "Casualties & Impact",
                      icon: Icons.people_outline_rounded,
                      children: [
                        _buildCasualtySection(),
                        SizedBox(height: 20),
                        _buildAnimalSection(),
                        SizedBox(height: 20),
                        _buildLabel("Crop Damage (Area in Hectares)"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: cropController,
                          decoration: _inputDecoration(
                            "Crop name and affected area",
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Property Damage Card
                    _buildSectionCard(
                      title: "Property Damage",
                      icon: Icons.home_outlined,
                      children: [
                        _buildHouseDamageSection(),
                        SizedBox(height: 16),
                        _buildPublicPropertyDamageSection(),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Response & Relief Card
                    _buildSectionCard(
                      title: "Response & Relief",
                      icon: Icons.health_and_safety_outlined,
                      children: [
                        _buildLabel("Relief Measures Undertaken"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: reliefController,
                          decoration: _inputDecoration(
                            "Describe relief measures",
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 20),
                        _buildLabel("Assistance Required"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: responseController,
                          decoration: _inputDecoration(
                            "Describe immediate needs and logistics",
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 20),
                        _buildLabel("Future Risk Forecast"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: forecastController,
                          decoration: _inputDecoration(
                            "Forecast of possible developments",
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Additional Information Card
                    _buildSectionCard(
                      title: "Additional Information",
                      icon: Icons.notes_rounded,
                      children: [
                        _buildLabel("Other Relevant Details"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: otherInfoController,
                          decoration: _inputDecoration("Any other information"),
                          maxLines: 4,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isPicking ? null : _pickImages,
                                icon: Icon(Icons.photo_library_outlined),
                                label: Text(
                                  isPicking
                                      ? "Picking images..."
                                      : selectedImages.isEmpty
                                      ? "Upload Photos"
                                      : "${selectedImages.length}/5 Photos",
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                    color: primaryPurple,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: isPicking || selectedImages.length >= 5
                                  ? null
                                  : _takePhoto,
                              icon: Icon(Icons.camera_alt_outlined),
                              label: Text("Take Photo"),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                side: BorderSide(
                                  color: primaryPurple,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        // Image Preview
                        if (selectedImages.isNotEmpty) ...[
                          Text(
                            "Selected Photos (${selectedImages.length}/5)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xff2D3142),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 100,
                                  margin: EdgeInsets.only(right: 12),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          selectedImages[index],
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 120,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.8,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        SizedBox(height: 16),
                        Text(
                          "📷 Max 5 photos, 2MB each. JPG/PNG only.",
                          // "📷 Max 5 photos, 2MB each. JPG/PNG only.\n📄 Documents: PDF, DOC, DOCX (2MB max)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff9CA3AF),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Document Upload
                        // OutlinedButton.icon(
                        //   onPressed: _pickAnyFile,
                        //   icon: Icon(Icons.description_outlined),
                        //   label: Text(
                        //     filePaths.isEmpty
                        //         ? "Upload Documents"
                        //         : "${filePaths.length} documents",
                        //   ),
                        //   style: OutlinedButton.styleFrom(
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: 20,
                        //       vertical: 12,
                        //     ),
                        //     side: BorderSide(color: Colors.grey.shade400),
                        //   ),
                        // ),
                        // if (filePaths.isNotEmpty) ...[
                        //   SizedBox(height: 12),
                        //   Text(
                        //     "Selected Documents (${filePaths.length})",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 13,
                        //       color: Color(0xff2D3142),
                        //     ),
                        //   ),
                        //   SizedBox(height: 8),
                        //   ...filePaths.asMap().entries.map(
                        //     (entry) => Padding(
                        //       padding: EdgeInsets.only(bottom: 4),
                        //       child: Row(
                        //         children: [
                        //           Icon(
                        //             Icons.description,
                        //             size: 16,
                        //             color: Colors.grey.shade600,
                        //           ),
                        //           SizedBox(width: 8),
                        //           Expanded(
                        //             child: Text(
                        //               entry.value.split('/').last,
                        //               style: TextStyle(fontSize: 13),
                        //             ),
                        //           ),
                        //           IconButton(
                        //             icon: Icon(Icons.close, size: 16),
                        //             onPressed: () => _removeFile(entry.key),
                        //             padding: EdgeInsets.zero,
                        //             constraints: BoxConstraints(),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                    SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.send_rounded),
                        label: Text("Submit Report"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shadowColor: primaryPurple.withOpacity(0.3),
                        ),
                        onPressed: submitIncidentReport,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Success Dialog
  void _showSuccessDialog(String prNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff4ADE80), Color(0xff22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff22C55E).withOpacity(0.3),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Report Submitted!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Your disaster incident report has been successfully uploaded with ${selectedImages.length} photos.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text("Your PR Number is", style: TextStyle(fontSize: 14)),
                SizedBox(height: 6),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    prNumber,
                    textAlign: TextAlign.center,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      "OK, Go to Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Submission Failed"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryPurple, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2D3142),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCasualtySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Human Casualties"),
        SizedBox(height: 12),
        _buildCheckboxWithInput(
          "Dead",
          isDead,
          deadController,
          (v) => setState(() => isDead = v),
        ),
        SizedBox(height: 8),
        _buildCheckboxWithInput(
          "Missing",
          isMissing,
          missingController,
          (v) => setState(() => isMissing = v),
        ),
        SizedBox(height: 8),
        _buildCheckboxWithInput(
          "Injured",
          isInjured,
          injuredController,
          (v) => setState(() => isInjured = v),
        ),
      ],
    );
  }

  Widget _buildAnimalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Animal Casualties"),
        SizedBox(height: 12),
        _buildCheckboxWithInput(
          "Affected",
          isAnimalAffected,
          animalAffectedController,
          (v) => setState(() => isAnimalAffected = v),
        ),
        SizedBox(height: 8),
        _buildCheckboxWithInput(
          "Lost",
          isAnimalLost,
          animalLostController,
          (v) => setState(() => isAnimalLost = v),
        ),
        SizedBox(height: 8),
        _buildCheckboxWithInput(
          "Dead",
          isAnimalDead,
          animalDeadController,
          (v) => setState(() => isAnimalDead = v),
        ),
      ],
    );
  }

  Widget _buildHouseDamageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Houses Damaged"),
        SizedBox(height: 12),
        _buildCheckboxWithInput(
          "Fully/Severely Damaged",
          houseFully,
          houseFullyController,
          (v) => setState(() => houseFully = v),
        ),
        SizedBox(height: 8),
        _buildCheckboxWithInput(
          "Partially Damaged",
          housePartially,
          housePartiallyController,
          (v) => setState(() => housePartially = v),
        ),
      ],
    );
  }

  Widget _buildCheckboxWithInput(
    String label,
    bool value,
    TextEditingController controller,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? primaryPurple.withOpacity(0.05) : Color(0xffF5F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? primaryPurple.withOpacity(0.3) : Color(0xffE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xff2D3142),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          if (value) ...[
            SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Count",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Color(0xffF5F5F7),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xffE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorRed, width: 2),
      ),
    );
  }

  Widget _buildPublicPropertyDamageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Damage to Public Property"),
        SizedBox(height: 12),

        if (publicPropertyRows.isEmpty)
          Text(
            "No public property added",
            style: TextStyle(color: Color(0xff6B7280)),
          ),

        ...publicPropertyRows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;

          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xffF5F5F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xffE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<Infrastructure>(
                    initialValue: row.infrastructure,

                    isExpanded: true,
                    decoration: _inputDecoration(
                      isInfrastructureLoading
                          ? "Loading..."
                          : "Select Infrastructure",
                    ),
                    items: infrastructureList
                        .map(
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(
                              i.infrastructureName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => row.infrastructure = v);
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: row.totalController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Total No."),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.delete, color: errorRed),
                  onPressed: () {
                    setState(() {
                      publicPropertyRows.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),

        SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: isInfrastructureLoading
              ? null
              : () {
                  setState(() {
                    publicPropertyRows.add(PublicPropertyDamageRow());
                  });
                },
          icon: Icon(Icons.add),
          label: Text("Add Row"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xff2D3142),
          ),
        ),
        SizedBox(width: 4),
        Text(
          "*",
          style: TextStyle(
            color: errorRed,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xff2D3142),
      ),
    );
  }
}
