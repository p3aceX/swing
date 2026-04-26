package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzalg extends zzalh {
    public zzalg(int i4) {
        super(i4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalh
    public final void zza() {
        if (!zze()) {
            for (int i4 = 0; i4 < zzb(); i4++) {
                Map.Entry entryZzb = zzb(i4);
                if (((zzaiu) entryZzb.getKey()).zze()) {
                    entryZzb.setValue(Collections.unmodifiableList((List) entryZzb.getValue()));
                }
            }
            for (Map.Entry entry : zzc()) {
                if (((zzaiu) entry.getKey()).zze()) {
                    entry.setValue(Collections.unmodifiableList((List) entry.getValue()));
                }
            }
        }
        super.zza();
    }
}
