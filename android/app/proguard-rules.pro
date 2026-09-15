-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# WorkManager / Room generated classes are instantiated reflectively.
# Without these rules R8 removes the generated constructor and the app
# crashes on startup inside androidx.startup.InitializationProvider.
-keep class androidx.work.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keepclassmembers class * extends androidx.room.RoomDatabase {
    <init>();
}
-keepclassmembers class androidx.work.impl.WorkDatabase_Impl {
    <init>();
}
-dontwarn androidx.work.**
-dontwarn androidx.room.**
