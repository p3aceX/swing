package com.google.android.recaptcha.internal;

import Q3.D;
import Q3.F;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import w3.i;
import x3.AbstractC0728h;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class zzca implements zzbu {
    public static final zzbv zza = new zzbv(null);
    private final D zzb;
    private final zzcl zzc;
    private final zzee zzd;
    private final Map zze;
    private final Map zzf;

    public zzca(D d5, zzcl zzclVar, zzee zzeeVar, Map map) {
        this.zzb = d5;
        this.zzc = zzclVar;
        this.zzd = zzeeVar;
        this.zze = map;
        this.zzf = zzclVar.zzb().zzc();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final Object zzg(List list, zzcj zzcjVar, InterfaceC0762c interfaceC0762c) throws Throwable {
        Object objG = F.g(new zzbx(zzcjVar, list, this, null), interfaceC0762c);
        return objG == EnumC0789a.f6999a ? objG : i.f6729a;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final Object zzh(Exception exc, zzcj zzcjVar, InterfaceC0762c interfaceC0762c) throws Throwable {
        Object objG = F.g(new zzby(exc, zzcjVar, this, null), interfaceC0762c);
        return objG == EnumC0789a.f6999a ? objG : i.f6729a;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzi(zzpr zzprVar, zzcj zzcjVar) throws zzae {
        zzfh zzfhVarZzb = zzfh.zzb();
        int iZza = zzcjVar.zza();
        zzdd zzddVar = (zzdd) this.zze.get(Integer.valueOf(zzprVar.zzf()));
        if (zzddVar == null) {
            throw new zzae(5, 2, null);
        }
        int iZzg = zzprVar.zzg();
        zzpq[] zzpqVarArr = (zzpq[]) zzprVar.zzj().toArray(new zzpq[0]);
        zzddVar.zza(iZzg, zzcjVar, (zzpq[]) Arrays.copyOf(zzpqVarArr, zzpqVarArr.length));
        if (iZza == zzcjVar.zza()) {
            zzcjVar.zzg(zzcjVar.zza() + 1);
        }
        zzfhVarZzb.zzf();
        long jZza = zzfhVarZzb.zza(TimeUnit.MICROSECONDS);
        zzv zzvVar = zzv.zza;
        int iZzk = zzprVar.zzk();
        if (iZzk == 1) {
            throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
        }
        zzv.zza(iZzk - 2, jZza);
        zzprVar.zzk();
        zzprVar.zzg();
        AbstractC0728h.a0(zzprVar.zzj(), null, null, null, new zzbw(this), 31);
    }

    @Override // com.google.android.recaptcha.internal.zzbu
    public final void zza(String str) {
        F.s(this.zzb, null, new zzbz(new zzcj(this.zzc), this, str, null), 3);
    }
}
