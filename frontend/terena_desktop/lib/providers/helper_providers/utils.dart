import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

buildResultView(Widget child) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromRGBO(224, 224, 224, 1),
          width: 1,
        ),
      ),
      child: child,
    ),
  );
}

Future<dynamic> buildErrorAlert(
  BuildContext context,
  String title,
  String text,
  Exception exception,
) async {
  String errorMessage = text;

  if (text.startsWith('Exception: ')) {
    errorMessage = text.substring('Exception: '.length);
  }

  return await QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    title: title,
    confirmBtnText: "OK",
    text: errorMessage,
  );
}

String formatDateString(String? dateString) {
  if (dateString == null) return "";
  try {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd.MM.yyyy').format(date);
  } catch (e) {
    return dateString;
  }
}

String formatDateTimeString(String? dateTimeString) {
  if (dateTimeString == null) return "";
  try {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  } catch (e) {
    return dateTimeString;
  }
}

String formatCurrency(dynamic amount) {
  if (amount == null) return "0.00 BAM";
  double value = 0.0;
  if (amount is String) {
    value = double.tryParse(amount) ?? 0.0;
  } else if (amount is num) {
    value = amount.toDouble();
  }
  return "${value.toStringAsFixed(2)} BAM";
}

