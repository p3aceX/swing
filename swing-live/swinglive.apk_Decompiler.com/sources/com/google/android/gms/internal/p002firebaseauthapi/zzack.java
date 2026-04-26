package com.google.android.gms.internal.p002firebaseauthapi;

import android.content.Context;
import z0.C0775f;

/* JADX INFO: loaded from: classes.dex */
public final class zzack {
    private static Boolean zza;

    public static boolean zza(Context context) {
        if (zza == null) {
            int iC = C0775f.f6961b.c(context, 12451000);
            zza = Boolean.valueOf(iC == 0 || iC == 2);
        }
        return zza.booleanValue();
    }
}
