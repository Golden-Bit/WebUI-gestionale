// File: payment_details_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/sdk/db_sdk.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/payment_view/payment_list_widget.dart';

class PaymentDetailsWidget extends StatefulWidget {
  final int initialPageSize;
  final int initialPageNumber;
  final String collectionName;
  final ValueChanged<int>? onTotalCountChanged;

  const PaymentDetailsWidget({
    Key? key,
    this.initialPageSize = 50,
    this.initialPageNumber = 0,
    required this.collectionName,
    this.onTotalCountChanged,
  }) : super(key: key);

  @override
  State<PaymentDetailsWidget> createState() => _PaymentDetailsWidgetState();
}

class _PaymentDetailsWidgetState extends State<PaymentDetailsWidget> {
  List<Map<String, dynamic>> myPayments = [];
  late int _currentPage;
  late int _pageSize;
  int _totalCount = 0;
  bool _isLoading = false;
Map<String, dynamic> _schema = {};

  @override
  void initState() {
    super.initState();
    _pageSize = widget.initialPageSize;
    _currentPage = widget.initialPageNumber;
    _loadPayments();
  }

  @override
  void didUpdateWidget(covariant PaymentDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se cambiano i parametri di pagina o il nome della collection, ricarica i dati.
    if (oldWidget.initialPageNumber != widget.initialPageNumber ||
        oldWidget.initialPageSize != widget.initialPageSize ||
        oldWidget.collectionName != widget.collectionName) {
      setState(() {
        _currentPage = widget.initialPageNumber;
        _pageSize = widget.initialPageSize;
      });
      _loadPayments();
    }
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });
    // Carica i pagamenti dalla "API" simulata usando il collectionName passato
    final payments = await FakePaymentSdk.getPayments(
      collectionName: widget.collectionName,
      skip: _currentPage * _pageSize,
      maxSize: _pageSize,
    );
    final total = await FakePaymentSdk.getTotalCount(
      collectionName: widget.collectionName,
    );
   final schema = await FakePaymentSdk.getSchema(
     collectionName: widget.collectionName,
   );
    setState(() {
      myPayments = payments;
      _totalCount = total;
     _schema = schema;
      _isLoading = false;
    });
    // Notifica il totale tramite callback, se fornita
    widget.onTotalCountChanged?.call(total);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : PaymentsListWidget(
          paymentsList: myPayments,
          onPaymentsChanged: (newList) {
            setState(() {
              myPayments = newList;
            });
          },
         schema: _schema,  // Passa lo schema recuperato
        );
  }
}