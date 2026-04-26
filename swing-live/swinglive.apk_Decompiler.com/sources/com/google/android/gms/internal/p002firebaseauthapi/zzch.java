package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ConcurrentMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzch<P> {
    private final ConcurrentMap<zzcl, List<zzcm<P>>> zza;
    private final List<zzcm<P>> zzb;
    private zzcm<P> zzc;
    private final Class<P> zzd;
    private final zzrl zze;
    private final boolean zzf;

    public final zzcm<P> zza() {
        return this.zzc;
    }

    public final zzrl zzb() {
        return this.zze;
    }

    public final Class<P> zzc() {
        return this.zzd;
    }

    public final Collection<List<zzcm<P>>> zzd() {
        return this.zza.values();
    }

    public final List<zzcm<P>> zze() {
        return zza(zzbo.zza);
    }

    public final boolean zzf() {
        return !this.zze.zza().isEmpty();
    }

    private zzch(ConcurrentMap<zzcl, List<zzcm<P>>> concurrentMap, List<zzcm<P>> list, zzcm<P> zzcmVar, zzrl zzrlVar, Class<P> cls) {
        this.zza = concurrentMap;
        this.zzb = list;
        this.zzc = zzcmVar;
        this.zzd = cls;
        this.zze = zzrlVar;
        this.zzf = false;
    }

    public final List<zzcm<P>> zza(byte[] bArr) {
        List<zzcm<P>> list = this.zza.get(new zzcl(bArr));
        return list != null ? list : Collections.EMPTY_LIST;
    }
}
