package com.google.android.gms.internal.auth;

import android.net.Uri;
import n.k;

/* JADX INFO: loaded from: classes.dex */
public final class zzci {
    private final k zza;

    public zzci(k kVar) {
        this.zza = kVar;
    }

    public final String zza(Uri uri, String str, String str2, String str3) {
        k kVar;
        if (uri != null) {
            kVar = (k) this.zza.getOrDefault(uri.toString(), null);
        } else {
            kVar = null;
        }
        if (kVar == null) {
            return null;
        }
        return (String) kVar.getOrDefault("".concat(str3), null);
    }
}
