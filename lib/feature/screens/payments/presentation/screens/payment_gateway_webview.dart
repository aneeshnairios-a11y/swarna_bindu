
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentGatewayWebView extends StatefulWidget {
  const PaymentGatewayWebView({super.key});

  static const String paymentUrl = 'https://paymentgateway.bindujewellery.com/';
  static const String callbackUrl =
      'https://paymentgateway.bindujewellery.com/handleJuspayResponse';

  @override
  State<PaymentGatewayWebView> createState() =>
      _PaymentGatewayWebViewState();
}

class _PaymentGatewayWebViewState extends State<PaymentGatewayWebView> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _allowPop = false;
  bool _showingExitDialog = false;
  bool _hasHandledCallback = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            final uri = Uri.tryParse(change.url ?? '');
            if (uri != null && _isPaymentCallback(uri)) {
              _handlePaymentCallback(uri);
            }
          },
          onHttpError: (error) {
            debugPrint('WebView HTTP error: ${error.response?.statusCode}');
            debugPrint('Failed request: ${error.request?.uri}');
          },
          onPageStarted: (url) {
            final uri = Uri.tryParse(url);
            if (uri != null && _isPaymentCallback(uri)) {
              _handlePaymentCallback(uri);
              return;
            }
            if (!mounted) return;

            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;

            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);

            if (uri != null && _isPaymentCallback(uri)) {
              _handlePaymentCallback(uri);
              return NavigationDecision.prevent;
            }

            // Block invalid URLs and non-HTTPS navigation.
            if (uri == null || uri.scheme.toLowerCase() != 'https') {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('========== WEBVIEW ERROR ==========');
            debugPrint('Description: ${error.description}');
            debugPrint('Error code: ${error.errorCode}');
            debugPrint('Is main frame: ${error.isForMainFrame}');
            debugPrint('===================================');

            // Ignore failed images, scripts, analytics and other
            // subresources. Only handle main page failures.
            if (error.isForMainFrame != true || !mounted) return;

            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(PaymentGatewayWebView.paymentUrl));
  }

  bool _isPaymentCallback(Uri uri) {
    final callbackUri = Uri.parse(PaymentGatewayWebView.callbackUrl);
    return uri.scheme.toLowerCase() == callbackUri.scheme &&
        uri.host.toLowerCase() == callbackUri.host &&
        uri.path.replaceFirst(RegExp(r'/+$'), '') ==
            callbackUri.path.replaceFirst(RegExp(r'/+$'), '');
  }

  void _handlePaymentCallback(Uri uri) {
    // Prevent duplicate callback handling.
    if (_hasHandledCallback || !mounted) return;

    _hasHandledCallback = true;

    debugPrint('Juspay callback detected. Closing payment WebView.');

    // Allow the route to pop despite PopScope.
    setState(() => _allowPop = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).pop(uri);
    });
  }

  Future<void> _confirmExit() async {
    if (_showingExitDialog || !mounted) return;

    _showingExitDialog = true;

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Exit payment?'),
          content: const Text(
            'Are you sure you want to leave the payment page? '
            'Your payment may not be completed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    _showingExitDialog = false;

    if (shouldExit == true && mounted) {
      setState(() => _allowPop = true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop<Uri>(null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Uri>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_errorMessage == null)
                WebViewWidget(controller: _controller)
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load payment page',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                              _isLoading = true;
                            });

                            _controller.reload();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_isLoading && _errorMessage == null)
                const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
