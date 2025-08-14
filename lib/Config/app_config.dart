//** CHANGE APP LOGO
import 'package:get/get.dart';
import 'package:untitled2/Controller/site_controller.dart';

final String appLogo = "icon1.png";

//** CHANGE SPLASH SCREEN IMAGE
final String splashLogo = "Splash.png";

// ** CHANGE WEBSITE ROOT URL
final String rootUrl = "https://elmobd3-mohamed-samy.com";
// final String rootUrl = "https://spondan.com/spn19/production/app";
// final String rootUrl = "https://spondan.com/spn19/production/default";
// final String rootUrl = "https://spondan.com/spn19/production/module";
// final String rootUrl = "https://spondan.com/spn19/production/570";
//https://spondan.com/spn19/production/520
//https://spondan.com/spn23/lmsdemo

final bool isDemo = false;

final bool showDownloadsFolder = false;

final String authHeader =
    "Authorization"; // X-Authorization if server doesn't support Authorization header

final String isBearer = authHeader == "X-Authorization" ? "" : "Bearer ";

Map<String, String> header({String? token}) {
  print('token is :::::: $token');

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // API key as shown in the Postman collection
    'ApiKey': backendApiKey,
  };

  // Only add Authorization header if token is provided and not null
  if (token != null && token.isNotEmpty && token != 'null') {
    headers[authHeader] = '$isBearer$token';
  }

  return headers;
}

final String baseUrl = rootUrl + "/api";

//** Change App Title
final String companyName = "InfixLMS";

//** Change Currency
String appCurrency = '\$';

//** Enable USD to INR conversion for PayTM and Razorpay
final bool enableCurrencyConvert = false;

//** VdoCipher API KEY (restored to original value)
final String vdoCipherApiKey =
    "uWhR1L0foh4YmYZ8cfGP3pPexiMR1wpeSEcLCJcI0EaD3CSkFvCLZhWDMuJlZ2k2";

//** Backend API KEY for authentication (updated to correct key)
final String backendApiKey =
    "1eUtUydmN7WNihu08QnxuMu7JPqULzNbiv7beAatd45uZG7Nra41WtAFSu0MgZkf";

//** Change currencyconverterapi.com API KEY
final String currencyConvApiKey = "c53aa753fbea191d10a1";

//** Change Razor Pay API Key and API Secret for Razor Pay Payment
final String razorPayKey = 'rzp_test_NwZxaMNdPJ9VhJ';
final String razorPaySecret = 'vQeK9wIA1hhlx4RRovhJnxoC';

//** CHANGE PAYTM host url
const PAYTM_HOST_URL = "http://localhost:3000";
final String payTMCurrency = 'INR';
final String payTmMerchantId = 'Resell00448805757124';
final isStaging = true;
final String callBackUrl = isStaging
    ? 'https://securegw-stage.paytm.in/theia/paytmCallback?'
    : 'https://securegw.paytm.in/theia/paytmCallback?';

//** Settings Page Links
final String privacyPolicyLink =
    "https://spondan.com/spn19/production/default/privacy";
final String rateAppLinkAndroid =
    "https://play.google.com/store/apps/details?id=com.infix.lms";
final String rateAppLinkiOS = "https://app.apple.com/id123214";
final String contactUsLink =
    "https://spondan.com/spn19/production/default/contact-us";

const PAYMENT_URL = "$PAYTM_HOST_URL/payment";
const STATUS_LOADING = "PAYMENT_LOADING";
const STATUS_SUCCESSFUL = "PAYMENT_SUCCESSFUL";
const STATUS_PENDING = "PAYMENT_PENDING";
const STATUS_FAILED = "PAYMENT_FAILED";
const STATUS_CHECKSUM_FAILED = "PAYMENT_CHECKSUM_FAILED";

//** Midtrans Payment
final String midTransServerUrl = 'http://localhost:3000';

//** Paypal Payment

final String paypalDomain =
    "https://api.sandbox.paypal.com"; // "https://api.paypal.com"; // for production mode
final String paypalCurrency = 'USD';
final String paypalClientId =
    'AQgAWV4PlM9g81xZ51TLtVi68KjB89s4mpcchFschs7OvTM-3p4zsQTDqHOkv5Sw44k9goHlE-VAC7zj';
final String paypalClientSecret =
    'ELLoQfnZ4kRbDkul81U_RNRsgHgFPDumlUloCcX6nO6ziXRXKob8gVYaTn6CGCeNVJtBqsfv7VtbsuR2';

//** PayStack Payment
final String payStackPublicKey =
    'pk_test_cb290d59b9ec539d7bc3617d1fee3d8a9cdb78b3';

final String payStackCurrency = 'ZAR';

///
/// InstaMojo
///
final String instaMojoApiUrl = 'https://test.instamojo.com/api/1.1';
final String instaMojoApiKey = 'test_d883b3a8d2bc1adc7a535506713';
final String instaMojoAuthToken = 'test_dc229039d2232a260a2df3f7502';

///
/// Stripe
///
final String stripeServerURL = 'https://api.stripe.com/v1/payment_intents';

/// For flutter_stripe
String stripeToken =
    'pk_test_51HUWfSGRvmmDdlLV4SicdCgwHvugSZJIWnq3JAVRdJFwzkNS94SafaOSsg9qgUdQkO0yyWARKyWSXOjjBXFrvwDD00kYOLnaBQ';

/// For flutter_stripe
// final String stripeServerURL = 'http://localhost:3000'; /// For Stripe_sdk

final String stripeCurrency = "USD";
final String stripeMerchantID = "merchant.thegreatestmarkeplace";
final String stripePublishableKey =
    "pk_test_51Ok2uhHu6txA5QVJYZK0q1UcawmJbzmd7S5HmMoq8fd2b82pZ7OkBK1qBjNnwqOFWk4SZGBtgke5woQOUINvU7Wc00HgfZmNF5";
final String appPackageName = "com.infix.lms";

final bool facebookLogin = true;

final bool googleLogin = true;

// Getter for SiteController to avoid circular dependency
SiteController get stctrl => Get.find<SiteController>();

// Apple Public API key

const apiIosRevenueKey = 'appl_qLcFeFmANDrcXeLhNVkQNnTagjK';
