package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzvh;
import java.security.GeneralSecurityException;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class zzcc {
    private final zzvh.zzb zza;

    private zzcc(zzvh.zzb zzbVar) {
        this.zza = zzbVar;
    }

    private final synchronized int zza(zzvd zzvdVar, boolean z4) {
        zzvh.zza zzaVarZza;
        zzaVarZza = zza(zzvdVar);
        this.zza.zza(zzaVarZza);
        return zzaVarZza.zza();
    }

    public static zzcc zzb() {
        return new zzcc(zzvh.zzc());
    }

    private final synchronized int zzc() {
        int iZza;
        iZza = zzpg.zza();
        while (zzb(iZza)) {
            iZza = zzpg.zza();
        }
        return iZza;
    }

    private final synchronized boolean zzb(int i4) {
        Iterator<zzvh.zza> it = this.zza.zzb().iterator();
        while (it.hasNext()) {
            if (it.next().zza() == i4) {
                return true;
            }
        }
        return false;
    }

    public final synchronized zzby zza() {
        return zzby.zza((zzvh) ((zzaja) this.zza.zzf()));
    }

    public final synchronized zzcc zza(zzbv zzbvVar) {
        zza(zzbvVar.zza(), false);
        return this;
    }

    public final synchronized zzcc zza(int i4) {
        for (int i5 = 0; i5 < this.zza.zza(); i5++) {
            zzvh.zza zzaVarZzb = this.zza.zzb(i5);
            if (zzaVarZzb.zza() == i4) {
                if (zzaVarZzb.zzc().equals(zzvb.ENABLED)) {
                    this.zza.zza(i4);
                } else {
                    throw new GeneralSecurityException("cannot set key as primary because it's not enabled: " + i4);
                }
            }
        }
        throw new GeneralSecurityException("key not found: " + i4);
        return this;
    }

    public static zzcc zza(zzby zzbyVar) {
        return new zzcc(zzbyVar.zzb().zzm());
    }

    private final synchronized zzvh.zza zza(zzux zzuxVar, zzvt zzvtVar) {
        int iZzc;
        iZzc = zzc();
        if (zzvtVar != zzvt.UNKNOWN_PREFIX) {
        } else {
            throw new GeneralSecurityException("unknown output prefix type");
        }
        return (zzvh.zza) ((zzaja) zzvh.zza.zzd().zza(zzuxVar).zza(iZzc).zza(zzvb.ENABLED).zza(zzvtVar).zzf());
    }

    private final synchronized zzvh.zza zza(zzvd zzvdVar) {
        return zza(zzcu.zza(zzvdVar), zzvdVar.zzd());
    }
}
