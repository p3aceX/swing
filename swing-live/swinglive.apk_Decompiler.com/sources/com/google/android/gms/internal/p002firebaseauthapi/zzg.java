package com.google.android.gms.internal.p002firebaseauthapi;

import android.os.Handler;
import android.os.Looper;

/* JADX INFO: loaded from: classes.dex */
public final class zzg extends Handler {
    private static zzf zza;
    private final Looper zzb;

    public zzg() {
        this.zzb = Looper.getMainLooper();
    }

    public zzg(Looper looper) {
        super(looper);
        this.zzb = Looper.getMainLooper();
    }
}
