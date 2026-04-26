package com.google.android.gms.internal.p002firebaseauthapi;

import G0.a;
import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;
import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public final class zzado {
    private final String zza;
    private final String zzb;

    public zzado(Context context) {
        this(context, context.getPackageName());
    }

    public final String zza() {
        return this.zzb;
    }

    public final String zzb() {
        return this.zza;
    }

    private zzado(Context context, String str) {
        F.g(context);
        F.d(str);
        this.zza = str;
        try {
            byte[] bArrD = a.d(context, str);
            if (bArrD != null) {
                this.zzb = a.a(bArrD);
                return;
            }
            Log.e("FBA-PackageInfo", "single cert required: " + str);
            this.zzb = null;
        } catch (PackageManager.NameNotFoundException unused) {
            Log.e("FBA-PackageInfo", "no pkg: " + str);
            this.zzb = null;
        }
    }
}
