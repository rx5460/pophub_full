import 'package:flutter/material.dart';
import 'package:pophub/model/pay_model.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final List<Payment> payments = [
    Payment(
        date: '04.16',
        description: '빵빵이 x 스미스 레더 키링',
        amount: '-52,000원',
        type: '구매'),
    Payment(
        date: '04.16',
        description: '잇섭 맥세이프 충전기',
        amount: '+89,000원',
        type: '환불'),
    Payment(
        date: '04.12',
        description: '플레이스테이션 세로 거...',
        amount: '-42,000원',
        type: '구매'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(titleName: "결제 내역"),
      body: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          bool isNewDate =
              index == 0 || payment.date != payments[index - 1].date;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNewDate) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(payment.date,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
              ],
              ListTile(
                title: Text(payment.description),
                subtitle: Text(payment.type),
                trailing: Text(payment.amount),
              ),
            ],
          );
        },
      ),
    );
  }
}
