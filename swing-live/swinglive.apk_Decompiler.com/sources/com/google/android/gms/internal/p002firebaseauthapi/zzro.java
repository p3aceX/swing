package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzro {
    private HashMap<String, String> zza = new HashMap<>();

    public final zzrl zza() {
        if (this.zza == null) {
            throw new IllegalStateException("cannot call build() twice");
        }
        zzrl zzrlVar = new zzrl(Collections.unmodifiableMap(this.zza));
        this.zza = null;
        return zzrlVar;
    }
}
