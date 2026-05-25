class SpotPriceData {
  final bool success;
  final SpotData data;
  final String dataFrom;

  SpotPriceData({
    required this.success,
    required this.data,
    required this.dataFrom,
  });

  factory SpotPriceData.fromJson(Map<String, dynamic> json) {
    return SpotPriceData(
      success: json['success'],
      data: SpotData.fromJson(json['data']),
      dataFrom: json['dataFrom'],
    );
  }
}

class SpotData {
  final String timestamp;
  final String spotTime;
  final double goldAsk;
  final double goldBid;
  final double goldChange;
  final double goldChangePercent;
  final double silverAsk;
  final double silverBid;
  final double silverChange;
  final double silverChangePercent;
  final double platinumAsk;
  final double platinumBid;
  final double platinumChange;
  final double platinumChangePercent;
  final double palladiumAsk;
  final double palladiumBid;
  final double palladiumChange;
  final double palladiumChangePercent;
  final double silverlowspot;
  final double silverhighspot;
  final double goldlowspot;
  final double goldhighspot;
  final double platinumlowspot;
  final double platinumhighspot;
  final double palladiumlowspot;
  final double palladiumhighspot;
  final PNL? pnl; // make nullable

  SpotData({
    required this.timestamp,
    required this.spotTime,
    required this.goldAsk,
    required this.goldBid,
    required this.goldChange,
    required this.goldChangePercent,
    required this.silverAsk,
    required this.silverBid,
    required this.silverChange,
    required this.silverChangePercent,
    required this.platinumAsk,
    required this.platinumBid,
    required this.platinumChange,
    required this.platinumChangePercent,
    required this.palladiumAsk,
    required this.palladiumBid,
    required this.palladiumChange,
    required this.palladiumChangePercent,
    required this.silverlowspot,
    required this.silverhighspot,
    required this.goldlowspot,
    required this.goldhighspot,
    required this.platinumlowspot,
    required this.platinumhighspot,
    required this.palladiumlowspot,
    required this.palladiumhighspot,
    this.pnl, // allow null
  });

  factory SpotData.fromJson(Map<String, dynamic> json) {
    return SpotData(
      timestamp: json['timestamp'] ?? '',
      spotTime: json['spotTime'] ?? '',
      goldAsk: (json['goldAsk'] as num?)?.toDouble() ?? 0.0,
      goldBid: (json['goldBid'] as num?)?.toDouble() ?? 0.0,
      goldChange: (json['goldChange'] as num?)?.toDouble() ?? 0.0,
      goldChangePercent: (json['goldChangePercent'] as num?)?.toDouble() ?? 0.0,
      silverAsk: (json['silverAsk'] as num?)?.toDouble() ?? 0.0,
      silverBid: (json['silverBid'] as num?)?.toDouble() ?? 0.0,
      silverChange: (json['silverChange'] as num?)?.toDouble() ?? 0.0,
      silverChangePercent:
          (json['silverChangePercent'] as num?)?.toDouble() ?? 0.0,
      platinumAsk: (json['platinumAsk'] as num?)?.toDouble() ?? 0.0,
      platinumBid: (json['platinumBid'] as num?)?.toDouble() ?? 0.0,
      platinumChange: (json['platinumChange'] as num?)?.toDouble() ?? 0.0,
      platinumChangePercent:
          (json['platinumChangePercent'] as num?)?.toDouble() ?? 0.0,
      palladiumAsk: (json['palladiumAsk'] as num?)?.toDouble() ?? 0.0,
      palladiumBid: (json['palladiumBid'] as num?)?.toDouble() ?? 0.0,
      palladiumChange: (json['palladiumChange'] as num?)?.toDouble() ?? 0.0,
      palladiumChangePercent:
          (json['palladiumChangePercent'] as num?)?.toDouble() ?? 0.0,
      silverlowspot: (json['silverlowspot'] as num?)?.toDouble() ?? 0.0,
      silverhighspot: (json['silverhighspot'] as num?)?.toDouble() ?? 0.0,
      goldlowspot: (json['goldlowspot'] as num?)?.toDouble() ?? 0.0,
      goldhighspot: (json['goldhighspot'] as num?)?.toDouble() ?? 0.0,
      platinumlowspot: (json['platinumlowspot'] as num?)?.toDouble() ?? 0.0,
      platinumhighspot: (json['platinumhighspot'] as num?)?.toDouble() ?? 0.0,
      palladiumlowspot: (json['palladiumlowspot'] as num?)?.toDouble() ?? 0.0,
      palladiumhighspot: (json['palladiumhighspot'] as num?)?.toDouble() ?? 0.0,
      pnl: json['pnl'] != null ? PNL.fromJson(json['pnl']) : null,
    );
  }
}

class PNL {
  final double totalCurrentAssetValue;
  final double dayPnlDollar;
  final double dayChangePercentage;

  PNL({
    required this.totalCurrentAssetValue,
    required this.dayPnlDollar,
    required this.dayChangePercentage,
  });

  factory PNL.fromJson(Map<String, dynamic> json) {
    return PNL(
      totalCurrentAssetValue:
          (json['totalCurrentAssetValue'] as num?)?.toDouble() ?? 0.0,
      dayPnlDollar: (json['dayPnlDollar'] as num?)?.toDouble() ?? 0.0,
      dayChangePercentage:
          (json['dayChangePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
