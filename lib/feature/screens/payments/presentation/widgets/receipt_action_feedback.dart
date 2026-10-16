import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../viewmodels/payment_receipt_viewmodel.dart';

/// Call from `ref.listen(receiptActionProvider, ...)` on any screen that
/// triggers receipt download/share, so the feedback is identical everywhere.
void handleReceiptActionChange(
    BuildContext context,
    ReceiptActionState? previous,
    ReceiptActionState next,
    ) {
  if (previous?.status == next.status) return;

  final messenger = ScaffoldMessenger.of(context);

  switch (next.status) {
    case ReceiptActionStatus.saved:
      final path = next.localPath;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              next.savedToDownloads
                  ? 'Receipt saved to Downloads'
                  : 'Receipt downloaded',
            ),
            action: path == null
                ? null
                : SnackBarAction(label: 'Open', onPressed: () => OpenFilex.open(path)),
          ),
        );
    case ReceiptActionStatus.error:
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Something went wrong.')),
        );
    case ReceiptActionStatus.idle:
    case ReceiptActionStatus.downloading:
    case ReceiptActionStatus.sharing:
      break;
  }
}