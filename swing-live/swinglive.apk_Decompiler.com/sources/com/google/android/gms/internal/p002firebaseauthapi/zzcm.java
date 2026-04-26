package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzcm<P> {
    private final P zza;
    private final P zzb;
    private final byte[] zzc;
    private final zzvb zzd;
    private final zzvt zze;
    private final int zzf;
    private final String zzg;
    private final zzbu zzh;

    public zzcm(P p4, P p5, byte[] bArr, zzvb zzvbVar, zzvt zzvtVar, int i4, String str, zzbu zzbuVar) {
        this.zza = p4;
        this.zzb = p5;
        this.zzc = Arrays.copyOf(bArr, bArr.length);
        this.zzd = zzvbVar;
        this.zze = zzvtVar;
        this.zzf = i4;
        this.zzg = str;
        this.zzh = zzbuVar;
    }

    public final int zza() {
        return this.zzf;
    }

    public final zzbu zzb() {
        return this.zzh;
    }

    public final zzvb zzc() {
        return this.zzd;
    }

    public final zzvt zzd() {
        return this.zze;
    }

    public final P zze() {
        return this.zza;
    }

    public final P zzf() {
        return this.zzb;
    }

    public final String zzg() {
        return this.zzg;
    }

    public final byte[] zzh() {
        byte[] bArr = this.zzc;
        if (bArr == null) {
            return null;
        }
        return Arrays.copyOf(bArr, bArr.length);
    }
}
