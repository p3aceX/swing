package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import Q3.F;
import e1.AbstractC0367g;
import java.util.List;
import java.util.concurrent.TimeUnit;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzbx extends j implements p {
    int zza;
    final /* synthetic */ zzcj zzb;
    final /* synthetic */ List zzc;
    final /* synthetic */ zzca zzd;
    private /* synthetic */ Object zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzbx(zzcj zzcjVar, List list, zzca zzcaVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzcjVar;
        this.zzc = list;
        this.zzd = zzcaVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        zzbx zzbxVar = new zzbx(this.zzb, this.zzc, this.zzd, interfaceC0762c);
        zzbxVar.zze = obj;
        return zzbxVar;
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzbx) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        i iVar = i.f6729a;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            return iVar;
        }
        D d5 = (D) this.zze;
        zzfh zzfhVarZzb = zzfh.zzb();
        while (true) {
            zzcj zzcjVar = this.zzb;
            if (zzcjVar.zza() < 0) {
                break;
            }
            if (zzcjVar.zza() >= this.zzc.size() || !F.q(d5)) {
                break;
            }
            try {
                this.zzd.zzi((zzpr) this.zzc.get(this.zzb.zza()), this.zzb);
            } catch (Exception e) {
                zzca zzcaVar = this.zzd;
                zzcj zzcjVar2 = this.zzb;
                this.zza = 1;
                return zzcaVar.zzh(e, zzcjVar2, this) == enumC0789a ? enumC0789a : iVar;
            }
        }
        zzfhVarZzb.zzf();
        new Long(zzfhVarZzb.zza(TimeUnit.MICROSECONDS));
        return iVar;
    }
}
