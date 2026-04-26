package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zznt {
    private static final zznt zza = new zznt();
    private final Map<String, zzci> zzb = new HashMap();

    public static zznt zza() {
        return zza;
    }

    private final synchronized void zza(String str, zzci zzciVar) {
        try {
            if (!this.zzb.containsKey(str)) {
                this.zzb.put(str, zzciVar);
                return;
            }
            if (this.zzb.get(str).equals(zzciVar)) {
                return;
            }
            throw new GeneralSecurityException("Parameters object with name " + str + " already exists (" + String.valueOf(this.zzb.get(str)) + "), cannot insert " + String.valueOf(zzciVar));
        } catch (Throwable th) {
            throw th;
        }
    }

    public final synchronized void zza(Map<String, zzci> map) {
        for (Map.Entry<String, zzci> entry : map.entrySet()) {
            zza(entry.getKey(), entry.getValue());
        }
    }
}
