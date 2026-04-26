package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import e1.AbstractC0367g;
import w3.e;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzb extends j implements p {
    int zza;
    final /* synthetic */ zza zzb;
    final /* synthetic */ String zzc;
    final /* synthetic */ long zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzb(zza zzaVar, String str, long j4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzaVar;
        this.zzc = str;
        this.zzd = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzb(this.zzb, this.zzc, this.zzd, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzb) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Object objZza;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            objZza = ((e) obj).f6721a;
        } else {
            zza zzaVar = this.zzb;
            String str = this.zzc;
            long j4 = this.zzd;
            this.zza = 1;
            objZza = zzaVar.zza(str, j4, this);
            if (objZza == enumC0789a) {
                return enumC0789a;
            }
        }
        return new e(objZza);
    }
}
