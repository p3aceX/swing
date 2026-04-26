package com.google.android.recaptcha.internal;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzku extends zzle {
    public zzku(int i4) {
        super(i4, null);
    }

    @Override // com.google.android.recaptcha.internal.zzle
    public final void zza() {
        if (!zzj()) {
            for (int i4 = 0; i4 < zzb(); i4++) {
                ((zzii) zzg(i4).getKey()).zzg();
            }
            Iterator it = zzc().iterator();
            while (it.hasNext()) {
                ((zzii) ((Map.Entry) it.next()).getKey()).zzg();
            }
        }
        super.zza();
    }
}
