import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/payment_receipt_model.dart';
import '../../data/repository/payments_repository.dart';
import '../../data/services/receipt_file_service.dart';


// ─────────────────────────────────────────────────────────────────────
// Receipt details  (GET /payments/receipt/:transactionId)
// ─────────────────────────────────────────────────────────────────────

enum PaymentReceiptLoadStatus { idle, loading, loaded, error }

class PaymentReceiptState {
  const PaymentReceiptState({
    this.status = PaymentReceiptLoadStatus.idle,
    this.receipt,
    this.transactionId,
    this.errorMessage,
  });

  final PaymentReceiptLoadStatus status;
  final PaymentReceiptModel? receipt;
  final String? transactionId;
  final String? errorMessage;

  bool get isLoading => status == PaymentReceiptLoadStatus.loading;
  bool get isError => status == PaymentReceiptLoadStatus.error;

  PaymentReceiptState copyWith({
    PaymentReceiptLoadStatus? status,
    PaymentReceiptModel? receipt,
    String? transactionId,
    String? errorMessage,
  }) {
    return PaymentReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage,
    );
  }
}

class PaymentReceiptNotifier extends Notifier<PaymentReceiptState> {
  @override
  PaymentReceiptState build() => const PaymentReceiptState();

  Future<void> load(String transactionId) async {
    state = state.copyWith(
      status: PaymentReceiptLoadStatus.loading,
      transactionId: transactionId,
      errorMessage: null,
    );

    final result = await ref.read(paymentsRepositoryProvider).getReceipt(transactionId);
    if (!ref.mounted) return;

    result.when(
      success: (data) {
        state = state.copyWith(status: PaymentReceiptLoadStatus.loaded, receipt: data);
      },
      failure: (e) {
        state = state.copyWith(status: PaymentReceiptLoadStatus.error, errorMessage: e.message);
      },
    );
  }

  Future<void> retry() {
    final id = state.transactionId;
    if (id == null) return Future.value();
    return load(id);
  }
}

final paymentReceiptProvider =
NotifierProvider.autoDispose<PaymentReceiptNotifier, PaymentReceiptState>(
  PaymentReceiptNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────
// Receipt actions: download-to-device + share
// (GET /payments/receipt/:transactionId/download)
// Shared by the History cards and the Receipt screen.
// ─────────────────────────────────────────────────────────────────────

enum ReceiptActionStatus { idle, downloading, sharing, saved, error }

class ReceiptActionState {
  const ReceiptActionState({
    this.status = ReceiptActionStatus.idle,
    this.transactionId,
    this.localPath,
    this.savedToDownloads = false,
    this.errorMessage,
  });

  final ReceiptActionStatus status;

  /// The transaction the current/last action was for.
  final String? transactionId;

  /// Local copy of the PDF (for "Open" and "Share").
  final String? localPath;
  final bool savedToDownloads;
  final String? errorMessage;

  bool get isBusy =>
      status == ReceiptActionStatus.downloading || status == ReceiptActionStatus.sharing;

  ReceiptActionState copyWith({
    ReceiptActionStatus? status,
    String? transactionId,
    String? localPath,
    bool? savedToDownloads,
    String? errorMessage,
  }) {
    return ReceiptActionState(
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      localPath: localPath ?? this.localPath,
      savedToDownloads: savedToDownloads ?? this.savedToDownloads,
      errorMessage: errorMessage,
    );
  }
}

class ReceiptActionNotifier extends Notifier<ReceiptActionState> {
  @override
  ReceiptActionState build() => const ReceiptActionState();

  /// Download the PDF and save it to the device's Downloads folder.
  Future<void> download(String transactionId) async {
    if (state.isBusy) return;

    state = ReceiptActionState(
      status: ReceiptActionStatus.downloading,
      transactionId: transactionId,
    );

    final tempPath = await _fetchPdf(transactionId);
    if (tempPath == null) return;

    try {
      final saved = await ref.read(receiptFileServiceProvider).saveToDownloads(tempPath);
      if (!ref.mounted) return;
      state = ReceiptActionState(
        status: ReceiptActionStatus.saved,
        transactionId: transactionId,
        localPath: saved.localPath,
        savedToDownloads: saved.inPublicDownloads,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = ReceiptActionState(
        status: ReceiptActionStatus.error,
        transactionId: transactionId,
        errorMessage: 'Could not save the receipt to your device. Please try again.',
      );
    }
  }

  /// Download (if not already cached) and open the OS share sheet.
  Future<void> share(String transactionId, {String? subject}) async {
    if (state.isBusy) return;

    final cached = state.transactionId == transactionId ? state.localPath : null;

    state = ReceiptActionState(
      status: ReceiptActionStatus.sharing,
      transactionId: transactionId,
    );

    final path = (cached != null && await File(cached).exists())
        ? cached
        : await _fetchPdf(transactionId);
    if (path == null || !ref.mounted) return;

    try {
      await ref.read(receiptFileServiceProvider).share(
        path,
        subject: subject ?? 'Swarna Bindu payment receipt',
        text: 'Payment receipt for transaction $transactionId',
      );
      if (!ref.mounted) return;
      // Sharing needs no snackbar — go back to idle (keep the cached file).
      state = ReceiptActionState(
        transactionId: transactionId,
        localPath: path,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = ReceiptActionState(
        status: ReceiptActionStatus.error,
        transactionId: transactionId,
        errorMessage: 'Could not share the receipt. Please try again.',
      );
    }
  }

  /// Returns the temp PDF path, or null after putting the state in `error`.
  Future<String?> _fetchPdf(String transactionId) async {
    final result = await ref.read(paymentsRepositoryProvider).downloadReceipt(transactionId);
    if (!ref.mounted) return null;

    return result.when(
      success: (path) => path,
      failure: (e) {
        state = ReceiptActionState(
          status: ReceiptActionStatus.error,
          transactionId: transactionId,
          errorMessage: e.message,
        );
        return null;
      },
    );
  }
}

final receiptActionProvider =
NotifierProvider.autoDispose<ReceiptActionNotifier, ReceiptActionState>(
  ReceiptActionNotifier.new,
);