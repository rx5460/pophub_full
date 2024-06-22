class Payment {
  final String date;
  final String description;
  final String amount;
  final String type;

  Payment(
      {required this.date,
      required this.description,
      required this.amount,
      required this.type});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      date: json['date'],
      description: json['description'],
      amount: json['amount'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'description': description,
      'amount': amount,
      'type': type,
    };
  }
}
