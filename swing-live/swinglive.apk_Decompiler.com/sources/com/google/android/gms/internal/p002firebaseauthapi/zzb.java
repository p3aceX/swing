package com.google.android.gms.internal.p002firebaseauthapi;

import java.net.URL;
import java.net.URLConnection;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzb {
    private static zzb zza = new zze();

    public static synchronized zzb zza() {
        return zza;
    }

    public abstract URLConnection zza(URL url, String str);
}
