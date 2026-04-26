package com.google.android.recaptcha.internal;

import android.content.Context;
import android.os.Build;
import z0.C0775f;

/* JADX INFO: loaded from: classes.dex */
public final class zzaf {
    public static final zzaf zza = new zzaf();
    private static final String zzb = String.valueOf(Build.VERSION.SDK_INT);
    private static final C0775f zzc = C0775f.f6961b;

    private zzaf() {
    }

    public static final String zza(Context context) {
        int iB = zzc.b(context);
        return (iB == 1 || iB == 3 || iB == 9) ? "ANDROID_OFFPLAY" : "ANDROID_ONPLAY";
    }
}
