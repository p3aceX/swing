package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzvd;

/* JADX INFO: loaded from: classes.dex */
public final class zzcz {
    public static final zzvd zzb;
    private static final zzvd zzf;
    private static final zzvd zzg;
    private static final zzvd zzh;
    public static final zzvd zza = zza(16);
    private static final zzvd zzc = zza(32);
    private static final zzvd zzd = zza(16, 16);
    private static final zzvd zze = zza(32, 16);

    static {
        zzuc zzucVar = zzuc.SHA256;
        zzb = zza(16, 16, 32, 16, zzucVar);
        zzf = zza(32, 16, 32, 32, zzucVar);
        zzvd.zza zzaVarZza = zzvd.zza().zza(zzfk.zza());
        zzvt zzvtVar = zzvt.TINK;
        zzg = (zzvd) ((zzaja) zzaVarZza.zza(zzvtVar).zzf());
        zzh = (zzvd) ((zzaja) zzvd.zza().zza(zzgz.zza()).zza(zzvtVar).zzf());
    }

    private static zzvd zza(int i4, int i5, int i6, int i7, zzuc zzucVar) {
        zzsk zzskVar = (zzsk) ((zzaja) zzsk.zzb().zza((zzsl) ((zzaja) zzsl.zzb().zza(16).zzf())).zza(i4).zzf());
        return (zzvd) ((zzaja) zzvd.zza().zza(((zzsg) ((zzaja) zzsg.zza().zza(zzskVar).zza((zzuf) ((zzaja) zzuf.zzc().zza((zzui) ((zzaja) zzui.zzc().zza(zzucVar).zza(i7).zzf())).zza(32).zzf())).zzf())).zzi()).zza(zzdj.zza()).zza(zzvt.TINK).zzf());
    }

    private static zzvd zza(int i4, int i5) {
        return (zzvd) ((zzaja) zzvd.zza().zza(((zzsp) ((zzaja) zzsp.zzb().zza(i4).zza((zzss) ((zzaja) zzss.zzb().zza(16).zzf())).zzf())).zzi()).zza(zzdz.zza()).zza(zzvt.TINK).zzf());
    }

    private static zzvd zza(int i4) {
        return (zzvd) ((zzaja) zzvd.zza().zza(((zzsw) ((zzaja) zzsw.zzc().zza(i4).zzf())).zzi()).zza(zzeo.zza()).zza(zzvt.TINK).zzf());
    }
}
