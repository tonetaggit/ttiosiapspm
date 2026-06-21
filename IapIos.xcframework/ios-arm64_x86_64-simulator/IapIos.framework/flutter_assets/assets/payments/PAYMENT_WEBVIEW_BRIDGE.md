# Payment WebView Bridge — Developer Reference

This document covers every method the web page must implement (Flutter → Web)
and every message the web page can post (Web → Flutter).
Keep this in sync with `FlutterPaymentBridgeHandler` and `PaymentWebViewWidget`.

---

## 1. Flutter calls Web (you must implement these)

Flutter calls these functions on `window` after the page finishes loading.
Your page **must** expose them before `DOMContentLoaded` or at the top of `<script>`.

### `window.initPaymentPage(data: string)`
Called once on page load. `data` is a JSON string.

```jsonc
{
  "companyName":           "Chargezone",                    // operator label (small, muted)
  "stationName":           "KA | Bengaluru | JW Marrott Hotel - UB City",  // station display name
  "companyLogoUrl":        "https://cdn.example.com/logo.png",  // square card image; omit/empty = no image
  "termsAndConditionsUrl": "https://example.com/tnc",    // Flutter opens this when OPEN_TNC is received
  "breakupItems": [
    { "key": "cost of recharge", "value": "₹ 500" },
    { "key": "convenience fee",  "value": "₹ 5"   },
    { "key": "payable amount*",  "value": "₹ 506" }   // last item = total
  ],
  "breakupHeader":          "approximate recharge calculation",
  "note":                   "* any excess amount will be refunded",
  "upiUrl":                 "upi://pay?pa=merchant@upi&...",
  "primaryColor":           "#4CAF50",              // hex, use as brand colour
  "defaultHeader":          "select upi app",
  "preferredHeader":        "pay quickly",
  "offerHeader":            "offers for you",
  "otherUpiAppHeader":      "other UPI apps",
  "chooseUpiAppDescription":"choose upi app to pay for this session",
  "serverApps": [
    {
      "appName":        "PhonePe",
      "displayName":    "PhonePe",
      "androidPackage": "com.phonepe.app",
      "iosScheme":      "phonepe",
      "status":         "preferred",   // preferred | promotion | failure | none
      "message":        "recommended"  // badge label, empty = no badge
    }
  ]
}
```

### `window.setUpiApps(apps: string)`
Called after Flutter resolves installed apps (async, arrives shortly after `initPaymentPage`).
`apps` is a JSON string — array of:

```jsonc
[
  {
    "name":        "PhonePe",
    "scheme":      "phonepe://",
    "packageName": "com.phonepe.app",
    "iconBase64":  "<base64>",   // data-URI ready; use as <img src="data:image/TYPE;base64,…">
    "iconType":    "png"         // "png" or "svg"
  }
]
```

Match each app to `serverApps` via `packageName` (Android) or `scheme` (iOS) to get status/badge.

### `window.showErrorPopup(title: string, description: string)`
Called by Flutter when a payment fails after the status loader.
Show an in-page error popup; the dismiss button should call `CLOSE_SCREEN` (see §2).

---

## 2. Web posts to Flutter (call these from your page)

Post messages via:

```js
TTFlutterIAPBridge.postMessage(JSON.stringify({ action: "ACTION_NAME", payload: { … } }));
```

| Action | When to call | Payload fields |
|---|---|---|
| `OPEN_UPI_APP` | User taps a UPI app | `scheme`, `packageName`, `upiUrl` |
| `OPEN_STATUS_LOADER` | Card/other payment confirmed on-page | _(none)_ |
| `CLOSE_SCREEN` | Terminal error — user dismisses | _(none)_ |
| `OPEN_TNC` | User taps Terms & Conditions | _(none)_ — Flutter opens `termsAndConditionsUrl` from init data |

**Examples:**

```js
// UPI app tapped
TTFlutterIAPBridge.postMessage(JSON.stringify({
  action: "OPEN_UPI_APP",
  payload: { scheme: "phonepe://", packageName: "com.phonepe.app", upiUrl: "upi://pay?…" }
}));

// Credit card / other payment done
TTFlutterIAPBridge.postMessage(JSON.stringify({ action: "OPEN_STATUS_LOADER", payload: {} }));

// Error popup dismissed
TTFlutterIAPBridge.postMessage(JSON.stringify({ action: "CLOSE_SCREEN", payload: {} }));
```

---

## 3. Moving from asset HTML to server URL

**What changes in Flutter** — one line in `PaymentWebViewWidget._loadHtml()`:

```dart
// current (asset)
final html = await rootBundle.loadString('assets/payments/payment_breakup.html');
_controller.loadHtmlString(html);

// server
_controller.loadRequest(Uri.parse('https://your-server.com/payment-breakup'));
```

**What the server page must do differently**

| Requirement | Detail |
|---|---|
| `TTFlutterIAPBridge` availability | The JS channel is injected by Flutter's WebView. Always guard calls: `if (window.TTFlutterIAPBridge) { … }` |
| Expose `window.initPaymentPage` and `window.setUpiApps` | Must be defined **before** the page fires `onPageFinished` on Flutter's side, i.e. before `DOMContentLoaded` or in a synchronous `<script>` |
| HTTPS only | Android WebView blocks mixed content by default |
| No redirects to external domains | The WebView does not follow OAuth / bank redirects outside the app unless you add a `NavigationDelegate` override in Flutter |
| `safe-area-inset-bottom` | Keep `padding-bottom: env(safe-area-inset-bottom, 20px)` for iPhone notch support |
| `viewport` meta | Keep `maximum-scale=1.0, user-scalable=no` to prevent accidental pinch-zoom |

**Nothing else changes** — the bridge protocol (`TTFlutterIAPBridge.postMessage`, `window.initPaymentPage`, `window.setUpiApps`, `window.showErrorPopup`) is identical between asset and server modes.

---

## 4. How it works — Flow Diagrams

### A. Page Load

```
Flutter                          WebView (HTML page)
  │                                      │
  ├─ initiatePayment() API call           │
  │        ↓                             │
  │   response: use_web_view = true       │
  │        ↓                             │
  ├─ loadHtmlString() / loadRequest() ──►│
  │                                      ├─ page renders (blank/skeleton)
  │                                      ├─ onPageFinished fires
  │◄─────────────────────────────────────┤
  │        ↓                             │
  ├─ initPaymentPage(data) ─────────────►│ render breakup rows, headers, note
  │        ↓                             │
  ├─ [async] fetch installed UPI apps    │
  │        ↓                             │
  └─ setUpiApps(apps) ─────────────────►│ render UPI app list with icons
```

---

### B. UPI Payment Flow

```
Flutter                 WebView (HTML)           UPI App
  │                         │                      │
  │                   user taps UPI app             │
  │                         │                      │
  │◄── OPEN_UPI_APP ─────── │                      │
  │    { scheme,             │                      │
  │      packageName,        │                      │
  │      upiUrl }            │                      │
  │                         │                      │
  ├─ launchUPIPayment() ────────────────────────── ►│
  │  (app goes background)                          │
  │                                                 │
  │  (user completes / cancels payment)             │
  │                                                 │
  │◄──────────── app resumes ──────────────────────-┤
  │                         │                      │
  ├─ isOpenedUpiApp = true  │                      │
  ├─ show PaymentStatusBottomSheet                  │
  │        ↓                                        │
  │   2-min timer starts                            │
  │   polling payment status API                    │
  │        ↓                                        │
  │   success → navigate to ConnectGun screen       │
  │   failure → showErrorPopup() ─────────────────►│ show in-page error popup
  │                         │                       │
  │                   user taps "done"              │
  │◄── CLOSE_SCREEN ─────── │                       │
  │                         │                       │
  └─ pop PaymentBreakUpScreen                        │
```

---

### C. Credit Card / Other Payment Flow

```
Flutter                 WebView (HTML)
  │                         │
  │                   user fills card form
  │                   taps "pay now"
  │                         │
  │◄── OPEN_STATUS_LOADER ──│
  │                         │
  ├─ show PaymentStatusBottomSheet (autoStartTimer = true)
  │        ↓
  │   timer starts immediately (no app-resume needed)
  │   polling payment status API
  │        ↓
  │   success → navigate to ConnectGun screen
  │   failure → showErrorPopup() ────────────────►│ show in-page error popup
  │                         │
  │                   user taps "done"
  │◄── CLOSE_SCREEN ─────── │
  │                         │
  └─ pop PaymentBreakUpScreen
```

---

### D. Error / Close Flow

```
Flutter                 WebView (HTML)
  │                         │
  │   (payment API fails    │
  │    before WebView loads)│
  │                         │
  ├─ show native Flutter error bottom sheet
  ├─ user taps "done" → pop screen
  │
  │   (error inside WebView after payment attempt)
  │                         │
  ├─ showErrorPopup(title, desc) ──────────────►│
  │                         ├─ in-page popup shown
  │                         ├─ user taps dismiss
  │◄── CLOSE_SCREEN ─────── │
  └─ pop PaymentBreakUpScreen
```

---

### E. Key Actors Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  PaymentBreakUpScreen  (Flutter shell)                          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  PaymentWebViewWidget                                    │   │
│  │  ┌─────────────────┐   ┌──────────────────────────────┐ │   │
│  │  │ PaymentWebData  │   │  UpiAppsWebLoader            │ │   │
│  │  │ Builder         │   │  (iOS / Android)             │ │   │
│  │  └────────┬────────┘   └──────────────┬───────────────┘ │   │
│  │           │  inject data              │  inject apps     │   │
│  │           ▼                           ▼                  │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │               WebView  (HTML page)                  │ │   │
│  │  │                                                     │ │   │
│  │  │   TTFlutterIAPBridge.postMessage(action, payload)  ──────┼─┼──►│
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            │                              │   │
│  │  ┌─────────────────────────▼───────────────────────────┐ │   │
│  │  │  FlutterPaymentBridgeHandler                        │ │   │
│  │  │  onOpenUpiApp / onOpenStatusLoader / onCloseScreen  │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  PaymentStatusBottomSheet  (always Flutter-native)              │
└─────────────────────────────────────────────────────────────────┘
```
