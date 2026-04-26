package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzakg implements zzakh {
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final int zza(int i4, Object obj, Object obj2) {
        zzake zzakeVar = (zzake) obj;
        if (zzakeVar.isEmpty()) {
            return 0;
        }
        Iterator it = zzakeVar.entrySet().iterator();
        if (!it.hasNext()) {
            return 0;
        }
        Map.Entry entry = (Map.Entry) it.next();
        entry.getKey();
        entry.getValue();
        throw new NoSuchMethodError();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final Object zzb(Object obj) {
        return zzake.zza().zzb();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final Object zzc(Object obj) {
        ((zzake) obj).zzc();
        return obj;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final Map<?, ?> zzd(Object obj) {
        return (zzake) obj;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final Map<?, ?> zze(Object obj) {
        return (zzake) obj;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final boolean zzf(Object obj) {
        return !((zzake) obj).zzd();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final zzakf<?, ?> zza(Object obj) {
        throw new NoSuchMethodError();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakh
    public final Object zza(Object obj, Object obj2) {
        zzake zzakeVarZzb = (zzake) obj;
        zzake zzakeVar = (zzake) obj2;
        if (!zzakeVar.isEmpty()) {
            if (!zzakeVarZzb.zzd()) {
                zzakeVarZzb = zzakeVarZzb.zzb();
            }
            zzakeVarZzb.zza(zzakeVar);
        }
        return zzakeVarZzb;
    }
}
