package com.google.android.gms.internal.auth;

import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
final class zzcx extends zzdc {
    public zzcx(zzcz zzczVar, String str, Double d5, boolean z4) {
        super(zzczVar, str, d5, true, null);
    }

    @Override // com.google.android.gms.internal.auth.zzdc
    public final /* synthetic */ Object zza(Object obj) {
        try {
            return Double.valueOf(Double.parseDouble((String) obj));
        } catch (NumberFormatException unused) {
            Log.e("PhenotypeFlag", "Invalid double value for " + this.zzc + ": " + ((String) obj));
            return null;
        }
    }
}
