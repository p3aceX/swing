package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import D2.v;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.common.internal.C0293p;
import com.google.android.gms.common.internal.F;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzact {
    private final int zza;

    private zzact(String str) {
        this.zza = zza(str);
    }

    private static int zza(String str) {
        try {
            List<String> listZza = zzac.zza("[.-]").zza((CharSequence) str);
            if (listZza.size() == 1) {
                return Integer.parseInt(str);
            }
            if (listZza.size() < 3) {
                return -1;
            }
            return (Integer.parseInt(listZza.get(1)) * 1000) + (Integer.parseInt(listZza.get(0)) * 1000000) + Integer.parseInt(listZza.get(2));
        } catch (IllegalArgumentException e) {
            if (!Log.isLoggable("LibraryVersionContainer", 3)) {
                return -1;
            }
            Log.d("LibraryVersionContainer", String.format("Version code parsing failed for: %s with exception %s.", str, e));
            return -1;
        }
    }

    public final String zzb() {
        return a.m("X", Integer.toString(this.zza));
    }

    public static zzact zza() throws Throwable {
        String str;
        String str2;
        InputStream resourceAsStream;
        String strConcat = "Failed to get app version for libraryName: firebase-auth";
        C0293p c0293p = C0293p.f3586c;
        c0293p.getClass();
        v vVar = C0293p.f3585b;
        F.e("firebase-auth", "Please provide a valid libraryName");
        ConcurrentHashMap concurrentHashMap = c0293p.f3587a;
        if (concurrentHashMap.containsKey("firebase-auth")) {
            str2 = (String) concurrentHashMap.get("firebase-auth");
        } else {
            Properties properties = new Properties();
            InputStream inputStream = null;
            property = null;
            String property = null;
            InputStream inputStream2 = null;
            try {
                try {
                    resourceAsStream = C0293p.class.getResourceAsStream("/firebase-auth.properties");
                } catch (Throwable th) {
                    th = th;
                }
            } catch (IOException e) {
                e = e;
                str = null;
            }
            try {
                if (resourceAsStream != null) {
                    properties.load(resourceAsStream);
                    property = properties.getProperty("version", null);
                    String strConcat2 = "firebase-auth version is " + property;
                    if (Log.isLoggable((String) vVar.f260b, 2)) {
                        String str3 = (String) vVar.f261c;
                        if (str3 != null) {
                            strConcat2 = str3.concat(strConcat2);
                        }
                        Log.v("LibraryVersion", strConcat2);
                    }
                } else if (Log.isLoggable((String) vVar.f260b, 5)) {
                    String str4 = (String) vVar.f261c;
                    Log.w("LibraryVersion", str4 == null ? "Failed to get app version for libraryName: firebase-auth" : str4.concat("Failed to get app version for libraryName: firebase-auth"));
                }
                if (resourceAsStream != null) {
                    G0.a.b(resourceAsStream);
                }
            } catch (IOException e4) {
                e = e4;
                str = null;
                inputStream = resourceAsStream;
                if (Log.isLoggable((String) vVar.f260b, 6)) {
                    String str5 = (String) vVar.f261c;
                    if (str5 != null) {
                        strConcat = str5.concat("Failed to get app version for libraryName: firebase-auth");
                    }
                    Log.e("LibraryVersion", strConcat, e);
                }
                if (inputStream != null) {
                    G0.a.b(inputStream);
                }
                property = str;
            } catch (Throwable th2) {
                th = th2;
                inputStream2 = resourceAsStream;
                if (inputStream2 != null) {
                    G0.a.b(inputStream2);
                }
                throw th;
            }
            if (property == null) {
                if (Log.isLoggable((String) vVar.f260b, 3)) {
                    String str6 = (String) vVar.f261c;
                    Log.d("LibraryVersion", str6 != null ? str6.concat(".properties file is dropped during release process. Failure to read app version is expected during Google internal testing where locally-built libraries are used") : ".properties file is dropped during release process. Failure to read app version is expected during Google internal testing where locally-built libraries are used");
                }
                str2 = "UNKNOWN";
            } else {
                str2 = property;
            }
            concurrentHashMap.put("firebase-auth", str2);
        }
        if (TextUtils.isEmpty(str2) || str2.equals("UNKNOWN")) {
            str2 = "-1";
        }
        return new zzact(str2);
    }
}
