package com.google.android.gms.internal.auth;

import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
final class zzcv extends zzdc {
    public zzcv(zzcz zzczVar, String str, Long l2, boolean z4) {
        super(zzczVar, str, l2, true, null);
    }

    @Override // com.google.android.gms.internal.auth.zzdc
    public final /* synthetic */ Object zza(Object obj) {
        try {
            return Long.valueOf(Long.parseLong((String) obj));
        } catch (NumberFormatException unused) {
            Log.e("PhenotypeFlag", "Invalid long value for " + this.zzc + ": " + ((String) obj));
            return null;
        }
    }
}
