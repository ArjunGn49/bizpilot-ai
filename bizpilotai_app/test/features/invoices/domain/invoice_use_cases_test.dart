import 'package:flutter_test/flutter_test.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/create_invoice_use_case.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/void_invoice_use_case.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/add_payment_use_case.dart';

class FakeInvoiceRepository extends Fake implements InvoiceRepository {
  bool shouldFail = false;

  @override
  Future<Result<int>> createInvoice({required Invoice invoice, required List<Payment> initialPayments}) async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return const Result.success(1001);
  }

  @override
  Future<Result<void>> voidInvoice(String invoiceId) async {
    if (shouldFail) return const Result.failure(ValidationFailure('Already Void'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> addPayment(Payment payment) async {
    if (shouldFail) return const Result.failure(ValidationFailure('Payment exceeds total'));
    return const Result.success(null);
  }
}

void main() {
  late FakeInvoiceRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeInvoiceRepository();
  });

  group('CreateInvoice UseCase', () {
    final testInvoice = Invoice(
      id: 'inv1', invoiceNumber: 0, subtotal: 100.0, discountAmount: 0.0,
      discountType: 'FLAT', taxAmount: 0.0, taxType: 'FLAT', total: 100.0,
      paidAmount: 100.0, balanceAmount: 0.0, paymentStatus: 'PAID', status: 'ACTIVE',
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    test('Returns successfully and propagates invoice number', () async {
      final useCase = CreateInvoiceUseCase(fakeRepo);
      final result = await useCase.call(invoice: testInvoice, initialPayments: []);
      
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 1001);
    });

    test('Propagates failure securely', () async {
      fakeRepo.shouldFail = true;
      final useCase = CreateInvoiceUseCase(fakeRepo);
      final result = await useCase.call(invoice: testInvoice, initialPayments: []);
      
      expect(result, isA<FailureResult<int>>());
    });
  });

  group('VoidInvoice UseCase', () {
    test('Returns successfully', () async {
      final useCase = VoidInvoiceUseCase(fakeRepo);
      final result = await useCase.call('inv1');
      expect(result, isA<Success<void>>());
    });
  });

  group('AddPayment UseCase', () {
    test('Propagates failure gracefully', () async {
      fakeRepo.shouldFail = true;
      final useCase = AddPaymentUseCase(fakeRepo);
      final result = await useCase.call(Payment(id: 'p1', invoiceId: 'inv1', amount: 999.0, method: 'CASH', createdAt: DateTime.now()));
      
      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult).failure, isA<ValidationFailure>());
    });
  });
}
