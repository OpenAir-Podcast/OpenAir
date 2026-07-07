class ValueRecipient {
  final String? name;
  final String? customKey;
  final String? customValue;
  final String type;
  final String address;
  final int split;
  final bool? fee;

  ValueRecipient({
    this.name,
    this.customKey,
    this.customValue,
    required this.type,
    required this.address,
    required this.split,
    this.fee,
  });

  factory ValueRecipient.fromJson(Map<String, dynamic> json) {
    return ValueRecipient(
      name: json['name'] as String?,
      customKey: json['customKey'] as String?,
      customValue: json['customValue'] as String?,
      type: json['type'] as String,
      address: json['address'] as String,
      split: (json['split'] as num).toInt(),
      fee: json['fee'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'address': address,
        'split': split,
        if (name != null) 'name': name,
        if (customKey != null) 'customKey': customKey,
        if (customValue != null) 'customValue': customValue,
        if (fee != null) 'fee': fee,
      };
}

class Value {
  final String type;
  final String method;
  final double? suggested;
  final List<ValueRecipient> valueRecipients;

  Value({
    required this.type,
    required this.method,
    this.suggested,
    this.valueRecipients = const [],
  });

  factory Value.fromJson(Map<String, dynamic> json) {
    return Value(
      type: json['type'] as String,
      method: json['method'] as String,
      suggested: (json['suggested'] as num?)?.toDouble(),
      valueRecipients: (json['valueRecipients'] as List<dynamic>?)
              ?.map((e) => ValueRecipient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'method': method,
        if (suggested != null) 'suggested': suggested,
        'valueRecipients': valueRecipients.map((e) => e.toJson()).toList(),
      };

  String get displayName {
    switch (type) {
      case 'lightning':
        return 'Bitcoin Lightning';
      case 'bitcoin':
        return 'Bitcoin';
      default:
        return type;
    }
  }
}
