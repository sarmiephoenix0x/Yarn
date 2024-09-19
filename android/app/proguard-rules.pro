# Flutter related rules
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# InAppWebView related rules
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# Suppress warnings related to android.window.BackEvent
-dontwarn android.window.BackEvent
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication



# Other libraries (optional)
-dontwarn io.flutter.embedding.**
