package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzaju extends zzajt {
    private static <E> zzajg<E> zzc(Object obj, long j4) {
        return (zzajg) zzamh.zze(obj, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajt
    public final <L> List<L> zza(Object obj, long j4) {
        zzajg zzajgVarZzc = zzc(obj, j4);
        if (zzajgVarZzc.zzc()) {
            return zzajgVarZzc;
        }
        int size = zzajgVarZzc.size();
        zzajg zzajgVarZza = zzajgVarZzc.zza(size == 0 ? 10 : size << 1);
        zzamh.zza(obj, j4, zzajgVarZza);
        return zzajgVarZza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajt
    public final void zzb(Object obj, long j4) {
        zzc(obj, j4).b_();
    }

    private zzaju() {
        super();
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r0v1 */
    /* JADX WARN: Type inference failed for: r0v2, types: [java.util.List] */
    /* JADX WARN: Type inference failed for: r0v4 */
    /* JADX WARN: Type inference failed for: r0v5 */
    /* JADX WARN: Type inference failed for: r0v6 */
    /* JADX WARN: Type inference failed for: r0v7 */
    /* JADX WARN: Type inference failed for: r0v8 */
    /* JADX WARN: Type inference failed for: r6v1, types: [com.google.android.gms.internal.firebase-auth-api.zzajg, java.util.Collection, java.util.List] */
    /* JADX WARN: Type inference failed for: r6v2, types: [java.lang.Object] */
    /* JADX WARN: Type inference failed for: r6v3 */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajt
    public final <E> void zza(Object obj, Object obj2, long j4) {
        zzajg zzajgVarZzc = zzc(obj, j4);
        ?? Zzc = zzc(obj2, j4);
        int size = zzajgVarZzc.size();
        int size2 = Zzc.size();
        ?? r02 = zzajgVarZzc;
        r02 = zzajgVarZzc;
        if (size > 0 && size2 > 0) {
            boolean zZzc = zzajgVarZzc.zzc();
            ?? Zza = zzajgVarZzc;
            if (!zZzc) {
                Zza = zzajgVarZzc.zza(size2 + size);
            }
            Zza.addAll(Zzc);
            r02 = Zza;
        }
        if (size > 0) {
            Zzc = r02;
        }
        zzamh.zza(obj, j4, (Object) Zzc);
    }
}
