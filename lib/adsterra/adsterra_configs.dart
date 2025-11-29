class AdsterraConfigs {
  // ============================================================
  // ✅ ১. ব্যানার কি (Key) - Adsterra Banners
  // ============================================================
  static const String key300x250 = "9964ceedd636bc71ee33b5cde8683614";
  static const String key728x90 = "d9fb810eaeb7bf3314e5e11eabebed8b";
  static const String keyNative = "8e8a276d393bb819af043954cc38995b";
  static const String srcSocialBar =
      "https://pl25522730.effectivegatecpm.com/dd/4f/78/dd4f7878c3a97f6f9e08bdf8911ad44b.js";
  static const String monetagHomeLink =
      "https://otieu.com/4/10229034";
  static const String monetagPlayerLink =
      "https://otieu.com/4/10228985";

  //
  // // 👉 লিংক ১: মেইন লিস্ট বা রিলস স্ক্রিনের জন্য
  // // (Monetag ড্যাশবোর্ড থেকে 'Incredible link' বা যেকোনো একটি কপি করে এখানে দিন)
  // static const String monetagHomeLink = "https://www.effectivegatecpm.com/n90473c2?key=8d080fc227ce9b5ddb7bd690437b6d2c";
  //mdmostakinali686@gmail.com
  // // 👉 লিংক ২: প্লেয়ার স্ক্রিন বা সাজেশনের জন্য
  // // (Monetag ড্যাশবোর্ড থেকে 'Superior link' বা অন্য একটি কপি করে এখানে দিন)
  // static const String monetagPlayerLink = "https://www.effectivegatecpm.com/n90473c2?key=8d080fc227ce9b5ddb7bd690437b6d2c";
  //

  // ============================================================
  // ⚠️ ৩. লিগ্যাসি/ব্যাকআপ লিংক (Adsterra Smart Link)
  // ============================================================

  static const String smartLinkUrl = "https://otieu.com/4/10229030";
  static const String popunderUrl = smartLinkUrl;


  static String get html300x250 =>
      """
    <script type="text/javascript">
       atOptions = {
          'key' : '$key300x250',
          'format' : 'iframe',
          'height' : 250,
          'width' : 300,
          'params' : {}
       };
    </script>
    <script type="text/javascript" src="https://www.highperformanceformat.com/$key300x250/invoke.js"></script>
  """;

  static String get html728x90 =>
      """
    <script type="text/javascript">
       atOptions = {
          'key' : '$key728x90',
          'format' : 'iframe',
          'height' : 90,
          'width' : 728,
          'params' : {}
       };
    </script>
    <script type="text/javascript" src="https://www.highperformanceformat.com/$key728x90/invoke.js"></script>
  """;

  static String get htmlSocialBar =>
      """
    <script type='text/javascript' src='$srcSocialBar'></script>
  """;

  static String get htmlNative =>
      """
    <script async="async" data-cfasync="false" src="https://pl25493353.effectivegatecpm.com/$keyNative/invoke.js"></script>
    <div id="container-$keyNative"></div>
  """;
}
