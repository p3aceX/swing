# SLF4J is used by some Pedro dependencies but the binder isn't needed for the app to function.
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Pedro Encoder / RootEncoder rules
-keep class com.pedro.** { *; }
-dontwarn com.pedro.**
