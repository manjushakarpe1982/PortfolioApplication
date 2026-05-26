import 'dart:convert';
import 'package:bold_portfolio/models/spot_price_model.dart';
import 'package:bold_portfolio/widgets/chartData.dart';
import 'package:bold_portfolio/widgets/spotPriceCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const snapYellow = Color.fromARGB(255, 220, 166, 2);

class SpotPriceScreen extends StatefulWidget {
  final ValueChanged<SpotData> onLatestSpotPriceChanged;
  const SpotPriceScreen({super.key, required this.onLatestSpotPriceChanged});

  @override
  State<SpotPriceScreen> createState() => _SpotPriceScreenState();
}

class _SpotPriceScreenState extends State<SpotPriceScreen> {
  int selectedTab = 0;
  String selectedMetal = "Gold";
  bool errorOccurred = false;

  // ✅ All 4 metals with their colors
  static const Map<String, Color> _metalColors = {
    'Gold': Color.fromARGB(255, 220, 166, 2),
    'Silver': Color(0xFF808080),
    'Platinum': Color(0xFF93C5FD),
    'Palladium': Color(0xFF2DD4BF),
  };

  // ✅ Safe getter — never throws, has fallback
  Color get _currentMetalColor =>
      _metalColors[selectedMetal] ?? const Color.fromARGB(255, 220, 166, 2);

  // ✅ Metal ID mapping for API
  final Map<String, int> metalIdMap = {
    'Gold': 1,
    'Silver': 2,
    'Platinum': 3,
    'Palladium': 4,
  };

  final Map<String, String> filterMap = {
    "24H": "1D",
    "1W": "1W",
    "1M": "1M",
    "6M": "6M",
    "YTD": "YTD",
    "1Y": "1Y",
    "5Y": "5Y",
    "All": "ALL",
  };

  String _selectedFilterUI = "24H";
  String _selectedRangeAPI = "1D";
  SpotData? latestSpotPrice;
  List<ChartData> metalInOuncesData = [];
  bool isLoading = false;
  bool _isDropdownOpen = false; // ✅ tracks dropdown open state
  final String spotBaseUrl = dotenv.env['SPOT_API_URL']!;

  @override
  void initState() {
    super.initState();
    _fetchMetalData(_selectedRangeAPI);
  }

  Future<void> _fetchMetalData(String range) async {
    setState(() => isLoading = true);

    // ✅ Use metalIdMap for all 4 metals
    final int metalId = metalIdMap[selectedMetal] ?? 1;
    final String url =
        "$spotBaseUrl/SpotPrices/GetHistoricalSpotPriceChart?MetalId=$metalId&Type=$range";

    try {
      final response = await http.get(Uri.parse(url));
      print("API URL: $url");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final chartData = jsonData['data']['chartdata'];
          errorOccurred = false;
          setState(() {
            metalInOuncesData = (chartData as List)
                .map((item) => ChartData.fromJson(item))
                .toList();
          });
        } else {
          debugPrint("API Error: Success flag is false");
        }
      } else {
        debugPrint("API Error: ${response.statusCode}");
        errorOccurred = true;
      }
    } catch (e) {
      debugPrint("API Exception: $e");
      errorOccurred = true;
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ Dropdown selector replaces old tab buttons
          _metalDropdown(),
          const SizedBox(height: 16),
          SpotPriceCard(
            metal: selectedMetal,
            onSpotPriceUpdated: (spotData) {
              setState(() => latestSpotPrice = spotData);
              widget.onLatestSpotPriceChanged(spotData);
            },
          ),
          const SizedBox(height: 16),
          _timeFilters(),
          const SizedBox(height: 16),
          _chartPlaceholder(),
        ],
      ),
    );
  }

  // ✅ NEW — Dropdown selector matching the screenshot UI
  Widget _metalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dropdown trigger button ───────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: snapYellow,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMetal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),

        // ── Dropdown menu ─────────────────────────────────────────────────
        if (_isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _metalColors.entries.map((entry) {
                final String name = entry.key;
                final Color color = entry.value;
                final bool isSelected = selectedMetal == name;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedMetal = name;
                      _isDropdownOpen = false;
                    });
                    _fetchMetalData(_selectedRangeAPI);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      // ✅ Highlight selected item with light tint of metal color
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // ✅ Color dot per metal
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        // ✅ Checkmark for selected item
                        if (isSelected)
                          Icon(Icons.check, color: color, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ✅ UPDATED — time filter chip color matches selected metal
  Widget _timeFilters() {
    final filters = ["24H", "1W", "1M", "6M", "YTD", "1Y", "5Y", "All"];

    return Wrap(
      spacing: 8,
      children: filters.map((e) {
        return ChoiceChip(
          label: Text(e, style: const TextStyle(color: Colors.black)),
          selected: _selectedFilterUI == e,
          selectedColor: snapYellow,
          onSelected: (_) {
            setState(() {
              _selectedFilterUI = e;
              _selectedRangeAPI = filterMap[e] ?? "1D";
            });
            _fetchMetalData(_selectedRangeAPI);
          },
        );
      }).toList(),
    );
  }

  Widget _chartPlaceholder() {
    return Container(
      height: 450,
      decoration: _cardDecoration(),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ChartPage(
              data: metalInOuncesData,
              metal: selectedMetal,
              selectedFilter: _selectedFilterUI,
              errorOccurred: errorOccurred,
              chartColor: _currentMetalColor, // ✅ NEW — pass metal color
              pressedRetry: () => _fetchMetalData(_selectedRangeAPI),
            ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
