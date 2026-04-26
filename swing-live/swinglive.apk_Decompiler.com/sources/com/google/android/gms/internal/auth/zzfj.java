package com.google.android.gms.internal.auth;

/* JADX INFO: loaded from: classes.dex */
final class zzfj extends zzfl {
    public /* synthetic */ zzfj(zzfi zzfiVar) {
        super(null);
    }

    @Override // com.google.android.gms.internal.auth.zzfl
    public final void zza(Object obj, long j4) {
        ((zzez) zzhj.zzf(obj, j4)).zzb();
    }

    @Override // com.google.android.gms.internal.auth.zzfl
    public final void zzb(Object obj, Object obj2, long j4) {
        zzez zzezVarZzd = (zzez) zzhj.zzf(obj, j4);
        zzez zzezVar = (zzez) zzhj.zzf(obj2, j4);
        int size = zzezVarZzd.size();
        int size2 = zzezVar.size();
        if (size > 0 && size2 > 0) {
            if (!zzezVarZzd.zzc()) {
                zzezVarZzd = zzezVarZzd.zzd(size2 + size);
            }
            zzezVarZzd.addAll(zzezVar);
        }
        if (size > 0) {
            zzezVar = zzezVarZzd;
        }
        zzhj.zzp(obj, j4, zzezVar);
    }

    private zzfj() {
        super(null);
    }
}
