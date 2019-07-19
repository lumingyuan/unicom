import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:unicom_attendance/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QRCodeVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QRCodeVCState();
}

class _QRCodeVCState extends State<QRCodeVC> {
  @override
  Widget build(BuildContext context) {
    var builder = new JWTBuilder()
      ..setClaim('data', {'moblie': UserManager.instance.userModel.mobile})
      ..getToken(); // returns token without signature

    var signer = new JWTHmacSha256Signer('tzywycenter');
    var token = builder.getSignedToken(signer);

    String url =
        'https://ywy.tzunicom.com/wxMain/ClientController/toShowQRCode?accessToken=$token&param=${UserManager.instance.currentCompanyModel.companyId}';
    lLog(url);

    return Scaffold(
      appBar: newAppBar(context, '一码通'),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        debuggingEnabled: true,
        onPageFinished: (text) {},
      ),
    );
  }
}
