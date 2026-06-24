import 'package:get/get.dart';
import 'package:student_systemv1/API/dio_client.dart';
import '../models/payment.dart';

class PaymentsController extends GetxController {
  var isLoading = true.obs;
  var summary = Rxn<PaymentSummary>();
  var invoices = <Invoice>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentsData();
  }

  Future<void> fetchPaymentsData() async {
    try {
      isLoading(true);
      errorMessage('');
      final dio = DioClient.getDio();

      // Fetch Summary
      final summaryResponse = await dio.get('/payments/me/summary');
      if (summaryResponse.data['success'] == true) {
        summary.value = PaymentSummary.fromJson(summaryResponse.data['data']);
      }

      // Fetch Invoices
      final invoicesResponse = await dio.get('/payments/me/invoices');
      if (invoicesResponse.data['success'] == true) {
        List data = invoicesResponse.data['data'];
        invoices.value = data.map((e) => Invoice.fromJson(e)).toList();
      }
    } catch (e) {
      errorMessage('Failed to load payment data. Please try again.');
      print('Error fetching payments: $e');
    } finally {
      isLoading(false);
    }
  }
}
