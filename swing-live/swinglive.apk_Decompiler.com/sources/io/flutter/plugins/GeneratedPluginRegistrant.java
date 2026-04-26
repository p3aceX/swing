package io.flutter.plugins;

import A2.a;
import B2.b;
import E2.c;
import T2.C0167l;
import android.util.Log;
import androidx.annotation.Keep;
import i3.C0424a;
import j3.C0467d;
import k3.C0516d;
import l3.K;
import o0.C0578a;

/* JADX INFO: loaded from: classes.dex */
@Keep
public final class GeneratedPluginRegistrant {
    private static final String TAG = "GeneratedPluginRegistrant";

    public static void registerWith(c cVar) {
        try {
            cVar.f344d.a(new C0167l());
        } catch (Exception e) {
            Log.e(TAG, "Error registering plugin camera_android, io.flutter.plugins.camera.CameraPlugin", e);
        }
        try {
            cVar.f344d.a(new z2.c());
        } catch (Exception e4) {
            Log.e(TAG, "Error registering plugin connectivity_plus, dev.fluttercommunity.plus.connectivity.ConnectivityPlugin", e4);
        }
        try {
            cVar.f344d.a(new C0424a());
        } catch (Exception e5) {
            Log.e(TAG, "Error registering plugin flutter_plugin_android_lifecycle, io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin", e5);
        }
        try {
            cVar.f344d.a(new w1.c());
        } catch (Exception e6) {
            Log.e(TAG, "Error registering plugin flutter_secure_storage, com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin", e6);
        }
        try {
            cVar.f344d.a(new C0467d());
        } catch (Exception e7) {
            Log.e(TAG, "Error registering plugin google_sign_in_android, io.flutter.plugins.googlesignin.GoogleSignInPlugin", e7);
        }
        try {
            cVar.f344d.a(new a());
        } catch (Exception e8) {
            Log.e(TAG, "Error registering plugin package_info_plus, dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin", e8);
        }
        try {
            cVar.f344d.a(new C0516d());
        } catch (Exception e9) {
            Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e9);
        }
        try {
            cVar.f344d.a(new C0578a());
        } catch (Exception e10) {
            Log.e(TAG, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin", e10);
        }
        try {
            cVar.f344d.a(new K());
        } catch (Exception e11) {
            Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e11);
        }
        try {
            cVar.f344d.a(new b());
        } catch (Exception e12) {
            Log.e(TAG, "Error registering plugin wakelock_plus, dev.fluttercommunity.plus.wakelock.WakelockPlusPlugin", e12);
        }
    }
}
