# Stripe Android SDK
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep push provisioning classes (even if not used)
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# React Native Stripe SDK
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**
