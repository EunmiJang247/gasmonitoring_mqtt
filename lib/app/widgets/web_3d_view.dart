import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web3dView extends StatefulWidget {
  const Web3dView({super.key, required this.url});
  final String url;

  @override
  State<Web3dView> createState() => _Web3dViewState();
}

class _Web3dViewState extends State<Web3dView> {
  late WebViewController webViewController;

  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: leftBarWidth, top: appBarHeight),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      alignment: Alignment.bottomRight,
      elevation: 0,
      child: Container(
          color: Colors.transparent,
          child: WebViewWidget(controller: webViewController)),
    );
  }
}
