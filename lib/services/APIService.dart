import 'package:drms/model/BankBranch.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Calamity.dart';
import 'package:drms/model/ExGratiaBeneficiary.dart';
import 'package:drms/model/ExGratiaNorm%20.dart';
import 'package:drms/model/Infrastructure.dart';
import 'package:drms/model/RequiredDocument.dart';
import 'package:drms/model/User.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/CustomHTTPRequest.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

class APIService {
  APIService._();
  static final APIService instance = APIService._();

  static const String baseURL =
      "https://fisheries.meghalaya.gov.in/fishFarmerPortal/";
  static const String cropsapURL =
      "https://cropsap.megfarmer.gov.in/api/getForecast/";
  // static const String drmsURL = "http://10.179.2.219:8083/drms/v-1/app/api/";
  static const String drmsURL =
      "https://relief.megrevenuedm.gov.in/stagingapi/drms/v-1/app/api/";

  Future<User?> login(String username, String password) async {
    try {
      final response = await CustomHTTPRequest().post(
        "$baseURL/userlogin",
        jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data["data"]);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Calamity>?> getAllCalamities() async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getallcalamity",
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Calamity> calamityList = (data as List)
            .map((e) => Calamity.fromMap(e))
            .toList();
        return calamityList;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Block>?> getAllBlocks(String districtCode) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getallblock/$districtCode",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((e) => Block.fromMap(e)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Village>?> getAllVillages(int blockCode) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getallvillage/$blockCode",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((e) => Village.fromMap(e)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Infrastructure>?> getInfrastructures() async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getinfrastructures",
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Infrastructure.fromMap(e)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitSaveAssistanceForm(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await CustomHTTPRequest().post(
        "${drmsURL}saveassistanceform",
        jsonEncode(payload),
      );

      debugPrint("Before Submit: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Submit Response: ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stack) {
      debugPrint("❌ Submit error: $e");
      print(stack);
    }
    return null;
  }

  Future<List<RequiredDocument>> fetchDocuments(
    int normCode,
    String firNo,
  ) async {
    final response = await CustomHTTPRequest().get(
      "${drmsURL}getalldocumentbynormcodes?norms=$normCode&fir=$firNo",
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // ✅ Case 1: API returns List directly
      if (decoded is List) {
        return decoded.map((e) => RequiredDocument.fromJson(e)).toList();
      }

      // ✅ Case 2: API returns Map wrapper
      if (decoded is Map && decoded["data"] is List) {
        final List list = decoded["data"];
        return list.map((e) => RequiredDocument.fromJson(e)).toList();
      }
    }

    return [];
  }

  Future<Map<String, dynamic>?> submitIncidentReport(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await CustomHTTPRequest().post(
        "${drmsURL}savefir",
        jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e, stack) {
      debugPrint("❌ Submit error: $e");
      print(stack);
    }
    return null;
  }

  Future<List<String>?> getFirDatesByBlockCode() async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getFirDatesByBlockCode",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['status'] == "SUCCESS" && json['data'] != null) {
          return List<String>.from(json['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint("getFirDatesByBlockCode error: $e");
      return null;
    }
  }

  Future<List<String>?> getAllFirFromDate(String date) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getallfirfromdate?date=$date",
      );

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);

      // If API directly returns list (as shown)
      if (decoded is List) {
        return decoded
            .where((e) => e is Map && e['firNo'] != null)
            .map<String>((e) => e['firNo'].toString())
            .toList();
      }

      // If wrapped response (future-proof)
      if (decoded is Map<String, dynamic> &&
          decoded['status'] == "SUCCESS" &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .where((e) => e is Map && e['firNo'] != null)
            .map<String>((e) => e['firNo'].toString())
            .toList();
      }

      return null;
    } catch (e) {
      debugPrint("getAllFirFromDate error: $e");
      return null;
    }
  }

  Future<List<ExGratiaBeneficiary>> getExGratiaFromFir({
    required String firNo,
    required String assistanceHead,
    String reportId = "",
    required int page,
    required int size,
  }) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getexgratiafromfir"
        "?firNo=$firNo"
        "&assistanceHead=$assistanceHead"
        "&reportid=$reportId"
        "&page=$page"
        "&size=$size",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint("ExGratia Beneficiary Response: $decoded");

        if (decoded is Map && decoded["status"] == "SUCCESS") {
          final mainData = decoded["data"];

          if (mainData is Map && mainData["data"] != null) {
            final String beneficiaryJsonString = mainData["data"];

            final List beneficiaryList = jsonDecode(beneficiaryJsonString);

            return beneficiaryList
                .map((e) => ExGratiaBeneficiary.fromJson(e))
                .toList();
          }
        }
      }

      return [];
    } catch (e, stack) {
      debugPrint("❌ getExGratiaFromFir error: $e");
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  Future<List<ExGratiaNorm>?> getExGratiaNorms() async {
    try {
      final response = await CustomHTTPRequest().get("${drmsURL}exgratianorms");

      if (response.statusCode != 200) return null;

      final Map<String, dynamic> jsonBody = jsonDecode(response.body);

      if (jsonBody['status'] != "SUCCESS") return null;

      final List list = jsonBody['data'];
      debugPrint("Norm List: $list");
      debugPrint("Lenght Norm List: ${list.length}");
      return list.map((e) => ExGratiaNorm.fromJson(e)).toList();
    } catch (e) {
      debugPrint("ExGratiaNorm API Error: $e");
      return null;
    }
  }

  Future<List<BankBranch>> getBankByIFSC(String ifsc) async {
    try {
      final response = await CustomHTTPRequest().get(
        "https://relief.megrevenuedm.gov.in/nicdsign/v-1/bankbyIFCD/$ifsc",
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => BankBranch.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("getBankByIFSC error: $e");
      return [];
    }
  }

  Future<ExGratiaNorm?> getNormByNormCode(int normCode) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getnormbynormcode?normcode=$normCode",
      );

      debugPrint("Norm API Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded == null || decoded['data'] == null) {
          debugPrint("Norm not found inside data for code: $normCode");
          return null;
        }

        return ExGratiaNorm.fromJson(decoded['data']);
      }
    } catch (e) {
      debugPrint("NormCode API Error: $e");
    }

    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchLandNorms({
    required String farmertype,
    required String subtype,
  }) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}fetchlandnorms?farmertype=$farmertype&subtype=$subtype",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          if (decoded["status"] == "SUCCESS" && decoded["data"] is List) {
            final List list = decoded["data"];

            return list.map((e) => e as Map<String, dynamic>).toList();
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint("❌ Land Norm Fetch Error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchInputSubsidyNorms({
    required String farmertype,
    required String subtype,
    required String losstype,
  }) async {
    try {
      String url = "";

      if (losstype == "perinial crop") {
        url =
            "${drmsURL}fetchperennialnorms?farmertype=$farmertype&subtype=$subtype&losstype=$losstype";
      } else if (losstype == "sericulture crop" ||
          losstype == "agriculture, horticulture and annual crop") {
        url =
            "${drmsURL}fetchsericulturenorms?farmertype=$farmertype&subtype=$subtype&losstype=$losstype";
      }

      final response = await CustomHTTPRequest().get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded["status"] == "SUCCESS" &&
            decoded["data"] is List) {
          return List<Map<String, dynamic>>.from(decoded["data"]);
        }

        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      }

      return [];
    } catch (e) {
      debugPrint("Input Subsidy Norm Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPerennialNorms({
    required String farmertype,
    required String subtype,
    required String losstype,
  }) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}fetchperennialnorms?farmertype=$farmertype&subtype=$subtype&losstype=$losstype",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded["status"] == "SUCCESS" &&
            decoded["data"] is List) {
          return List<Map<String, dynamic>>.from(decoded["data"]);
        }
      }
    } catch (e) {
      debugPrint("Perennial Norm Error: $e");
    }

    return [];
  }

  // ✅ Fetch Sericulture Norms
  Future<List<Map<String, dynamic>>> fetchSericultureNorms({
    required String farmertype,
    required String subtype,
    required String losstype,
  }) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}fetchsericulturenorms?farmertype=$farmertype&subtype=$subtype&losstype=$losstype",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded["status"] == "SUCCESS" &&
            decoded["data"] is List) {
          return List<Map<String, dynamic>>.from(decoded["data"]);
        }
      }
    } catch (e) {
      debugPrint("Sericulture Norm Error: $e");
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getNormBySubtype(String subtype) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getnormbysubtype?subType=$subtype",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded["status"] == "SUCCESS" &&
            decoded["data"] is List) {
          return List<Map<String, dynamic>>.from(decoded["data"]);
        }
      }
    } catch (e) {
      debugPrint("Sericulture Norm Error: $e");
    }

    return [];
  }

  Future<bool> uploadBeneficiaryDocuments({
    required String beneficiaryId,
    required List<Map<String, dynamic>> documents,
  }) async {
    try {
      final response = await CustomHTTPRequest().post(
        "${drmsURL}upload-updated-enclocures?beneficiaryId=$beneficiaryId",
        jsonEncode(documents),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded["status"] == "SUCCESS";
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> getAnimalSubtypeByAnimalType(
    String animalType,
  ) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getanimalsubtypebyanimaltype?animalType=$animalType",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint(" decoded Animal Subtype: $decoded");

        if (decoded is Map &&
            decoded["status"] == "SUCCESS" &&
            decoded["data"] is List) {
          return List<Map<String, dynamic>>.from(decoded["data"]);
        }
      }
    } catch (e) {
      debugPrint("Animal Subtype Fetch Error: $e");
    }

    return [];
  }

  Future<int?> getNormCodeByAssistanceType(String subtype) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getnormcodebyassistancetype?assistanceType=$subtype",
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["data"];
      }
    } catch (e) {
      debugPrint("NormCode API Error: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHouseSubtypeByHouseType({
    required String subType,
    required String houseType,
  }) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getbysubtypeandhousetype?subType=$subType&houseType=$houseType",
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return List<Map<String, dynamic>>.from(json["data"]);
      }

      return [];
    } catch (e) {
      debugPrint("❌ House Subtype API Error: $e");
      return [];
    }
  }

  // ======================================================
  // ✅ GET NORM CODE FOR HOUSING (SUBTYPE8)
  // ======================================================
  Future<int?> getNormCodeByHousingAssistType(String assistanceType) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getnormcodebyassistancetypeforhousing?assistanceType=$assistanceType",
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // ✅ API returns normCode inside data
        final data = json["data"];

        if (data != null && data is int) {
          return data;
        }

        if (data != null && data is String) {
          return int.tryParse(data);
        }
      }

      return null;
    } catch (e) {
      debugPrint("❌ Housing NormCode API Error: $e");
      return null;
    }
  }
}
