import 'package:drms/model/BankBranch.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Calamity.dart';
import 'package:drms/model/ExGratiaBeneficiary.dart';
import 'package:drms/model/ExGratiaNorm%20.dart';
import 'package:drms/model/Infrastructure.dart';
import 'package:drms/model/User.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/CustomHTTPRequest.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
      Response response = await CustomHTTPRequest().post(
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
      Response response = await CustomHTTPRequest().get(
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
      Response response = await CustomHTTPRequest().get(
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
      Response response = await CustomHTTPRequest().get(
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

  //   Future<Map<String, dynamic>?> submitIncidentReport(
  //     Map<String, dynamic> payload) async {
  //   try {
  //     final response = await CustomHTTPRequest().post(
  //       "${drmsURL}savefir",
  //       jsonEncode(payload),
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     }
  //   } catch (e) {
  //     print("Submit error: $e");
  //   }
  //   return null;
  // }

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
  }) async {
    try {
      final response = await CustomHTTPRequest().get(
        "${drmsURL}getexgratiafromfir"
        "?firNo=$firNo"
        "&assistanceHead=$assistanceHead"
        "&reportid=",
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => ExGratiaBeneficiary.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("getExGratiaFromFir error: $e");
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
      final response = await get(
        Uri.parse(
          "https://relief.megrevenuedm.gov.in/stagingapi/getnormbynormcode?normcode=$normCode",
        ),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ExGratiaNorm.fromJson(json);
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
        "https://relief.megrevenuedm.gov.in/fetchlandnorms?farmertype=$farmertype&subtype=$subtype",
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return null;
    } catch (e) {
      debugPrint("Land Norm Fetch Error: $e");
      return null;
    }
  }
}
