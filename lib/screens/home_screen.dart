import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:drms/app_scaffold.dart';
import 'package:shimmer/shimmer.dart';

final Map<String, Color> imdColors = {'green': Colors.green, 'yellow': Colors.yellow, 'orange': Colors.orange, 'red': Colors.red};

final Map<String, String> imdMeanings = {
  'green': "No warning; normal conditions.",
  'yellow': "Be aware; hazardous weather possible.",
  'orange': "Be prepared; dangerous weather likely.",
  'red': "Take action; severe weather expected.",
};

class WeatherDay {
  final String day;
  final IconData icon;
  final String desc;
  final double tempMax;
  final double tempMin;
  final double rain;
  final double cloud;
  final double gust;

  WeatherDay({
    required this.day,
    required this.icon,
    required this.desc,
    required this.tempMax,
    required this.tempMin,
    required this.rain,
    required this.cloud,
    required this.gust,
  });
}

WeatherDay getWeatherDay(String day, double rain, double cloud, double gust, double tempMax, double tempMin) {
  String desc;
  IconData icon;
  if (rain > 2) {
    desc = "Rainy";
    icon = Icons.grain;
  } else if (gust > 7) {
    desc = "Storm";
    icon = Icons.bolt;
  } else if (cloud > 60) {
    desc = "Cloudy";
    icon = Icons.cloud;
  } else {
    desc = "Sunny";
    icon = Icons.wb_sunny;
  }
  return WeatherDay(day: day, icon: icon, desc: desc, tempMax: tempMax, tempMin: tempMin, rain: rain, cloud: cloud, gust: gust);
}

List<String> getNextDays(int count, DateTime start) {
  return List.generate(count, (i) => DateFormat('EEE').format(start.add(Duration(days: i))));
}

Future<Map<String, dynamic>> fetchMegaFarmerWeatherData() async {
  final url = "https://cropsap.megfarmer.gov.in/api/getForecast";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    try {
      final List<dynamic> data = json.decode(response.body);
      return {'forecast': data};
    } catch (e) {
      return {};
    }
  } else {
    return {};
  }
}

Map<String, dynamic> getAverageForecastForDate(List<dynamic> forecastData, String targetDate) {
  final dayForecasts = forecastData.where((item) => item['forecast_date'] == targetDate).toList();

  if (dayForecasts.isEmpty) {
    return {'rain': 0.0, 'cloud': 0.0, 'gust': 0.0, 'tempMax': 0.0, 'tempMin': 0.0};
  }

  final rainAvg =
      dayForecasts.map((item) => double.tryParse(item['rainfall']?.toString() ?? '0') ?? 0.0).reduce((a, b) => a + b) / dayForecasts.length;

  final cloudAvg =
      dayForecasts.map((item) => double.tryParse(item['cloud_cover']?.toString() ?? '0') ?? 0.0).reduce((a, b) => a + b) / dayForecasts.length;

  final windAvg =
      dayForecasts.map((item) => double.tryParse(item['wind_speed']?.toString() ?? '0') ?? 0.0).reduce((a, b) => a + b) / dayForecasts.length;

  final tempMaxAvg =
      dayForecasts.map((item) => double.tryParse(item['temp_max']?.toString() ?? '0') ?? 0.0).reduce((a, b) => a + b) / dayForecasts.length;

  final tempMinAvg =
      dayForecasts.map((item) => double.tryParse(item['temp_min']?.toString() ?? '0') ?? 0.0).reduce((a, b) => a + b) / dayForecasts.length;

  return {'rain': rainAvg, 'cloud': cloudAvg, 'gust': windAvg, 'tempMax': tempMaxAvg, 'tempMin': tempMinAvg};
}

Future<List<String>> fetchWarningColors(double lat, double lon) async {
  List<String> colors = [];
  for (int i = 1; i <= 5; i++) {
    final url = 'https://mausamgram.imd.gov.in/get_warning_color1.php?lat=$lat&lon=$lon&day=day${i}_color';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data;
        try {
          data = json.decode(response.body);
        } catch (e) {
          data = {};
        }
        colors.add(data['content_color'] ?? 'green');
      } else {
        colors.add('green');
      }
    } catch (e) {
      colors.add('green');
    }
  }
  return colors;
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WeatherDay> forecast = [];
  List<String> warningColors = List.filled(5, 'green');
  bool loading = true;
  String errorMsg = "";

  final double lat = 25.500; // Shillong coordinates
  final double lon = 91.875;

  double currentTempMax = 0;
  double currentTempMin = 0;
  String currentDesc = "";
  String currentTime = "";
  String apiDate = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var now = DateTime.now();
    setState(() {
      loading = true;
      apiDate = DateFormat('yyyy-MM-dd').format(now);
      errorMsg = "";
    });

    try {
      final megaFarmerData = await fetchMegaFarmerWeatherData();
      final wc = await fetchWarningColors(lat, lon);

      final List<dynamic> forecastList = megaFarmerData['forecast'] ?? [];
      var days = getNextDays(5, now);

      List<WeatherDay> fw = [];
      for (int i = 0; i < 5; i++) {
        final forecastDate = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: i)));
        final avgData = getAverageForecastForDate(forecastList, forecastDate);

        fw.add(getWeatherDay(days[i], avgData['rain']!, avgData['cloud']!, avgData['gust']!, avgData['tempMax']!, avgData['tempMin']!));
      }

      setState(() {
        forecast = fw;
        warningColors = wc;
        currentTempMax = forecast[0].tempMax;
        currentTempMin = forecast[0].tempMin;
        currentDesc = forecast[0].desc;
        currentTime = DateFormat('hh:mm a').format(now);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "$e";
        loading = false;
      });
    }
  }

  Color getWeatherIconColor(String desc) {
    switch (desc.toLowerCase()) {
      case "cloudy":
        return Color(0xff8E9AAF);
      case "rainy":
        return Color(0xff5B8CDB);
      case "storm":
        return Color(0xffF4A261);
      case "sunny":
        return Color(0xffF9C74F);
      default:
        return Color(0xff6C63FF);
    }
  }

  Widget _buildShimmer() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 160,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          ),
        ),
        SizedBox(height: 28),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          ),
        ),
        SizedBox(height: 28),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 70,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Disaster Relief",
      currentRoute: 'home',
      body: loading
          ? _buildShimmer()
          : errorMsg.isNotEmpty
          ? Center(
              child: Text(
                errorMsg,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // Current Weather Card - Now shows Max/Min
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(colors: [Color(0xff6C63FF), Color(0xff5A54D1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: Color(0xff6C63FF).withOpacity(0.3), blurRadius: 24, offset: Offset(0, 12))],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                  ),
                                  child: Icon(
                                    forecast.isNotEmpty ? forecast[0].icon : Icons.wb_sunny,
                                    color: getWeatherIconColor(currentDesc),
                                    size: 32,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentDesc.isNotEmpty ? currentDesc : "Loading...",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                        child: Text(
                                          "As of $currentTime",
                                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "${currentTempMax.round()}°",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 48, height: 1, letterSpacing: -1),
                                    ),
                                    Text(
                                      "HIGH",
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_upward, color: Colors.green, size: 30),

                                SizedBox(width: 24),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${currentTempMin.round()}°",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
                                      ),
                                      Text("LOW", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_downward, color: Colors.red, size: 30),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28),

                // 5-Day Forecast - Now shows Max/Min
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Color(0xff6C63FF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.calendar_today_rounded, color: Color(0xff6C63FF), size: 20),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "5-Day Forecast",
                              style: TextStyle(color: Color(0xff2D3142), fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.2),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(forecast.length, (idx) {
                            final weather = forecast[idx];
                            final warning = warningColors[idx];
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xffF5F5F7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: getWeatherIconColor(weather.desc).withOpacity(0.2), width: 1.5),
                                      ),
                                      child: Icon(weather.icon, color: getWeatherIconColor(weather.desc), size: 18),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      weather.day,
                                      style: TextStyle(color: Color(0xff6B7280), fontWeight: FontWeight.w500, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${weather.tempMax.round()}°",
                                          style: TextStyle(color: Color(0xff2D3142), fontWeight: FontWeight.w700, fontSize: 12),
                                        ),
                                        Text(
                                          "/${weather.tempMin.round()}°",
                                          style: TextStyle(color: Color(0xff6B7280), fontWeight: FontWeight.w500, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Tooltip(
                                      message: imdMeanings[warning] ?? "",
                                      child: Container(
                                        width: 16,
                                        height: 8,
                                        decoration: BoxDecoration(color: imdColors[warning] ?? Colors.green, borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28),

                // IMD Warning Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IMD Warning Legend", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      ...['green', 'yellow', 'orange', 'red'].map(
                        (code) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 8,
                                decoration: BoxDecoration(color: imdColors[code], borderRadius: BorderRadius.circular(4)),
                              ),
                              SizedBox(width: 8),
                              Flexible(child: Text(imdMeanings[code] ?? "", style: TextStyle(fontSize: 13))),
                            ],
                          ),
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
