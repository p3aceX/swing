package com.google.android.gms.internal.auth;

import android.net.Uri;
import n.b;

/* JADX INFO: loaded from: classes.dex */
public final class zzcr {
    private static final b zza = new b();

    public static synchronized Uri zza(String str) {
        b bVar = zza;
        Uri uri = (Uri) bVar.getOrDefault("com.google.android.gms.auth_account", null);
        if (uri != null) {
            return uri;
        }
        Uri uri2 = Uri.parse("content://com.google.android.gms.phenotype/".concat(String.valueOf(Uri.encode("com.google.android.gms.auth_account"))));
        bVar.put("com.google.android.gms.auth_account", uri2);
        return uri2;
    }
}
