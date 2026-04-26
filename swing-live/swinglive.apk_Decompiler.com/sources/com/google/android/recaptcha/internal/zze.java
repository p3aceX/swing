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
final class zze extends j implements p {
    int zza;
    final /* synthetic */ zza zzb;
    final /* synthetic */ long zzc;
    final /* synthetic */ zzoe zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zze(zza zzaVar, long j4, zzoe zzoeVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzaVar;
        this.zzc = j4;
        this.zzd = zzoeVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zze(this.zzb, this.zzc, this.zzd, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zze) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Object objZzb;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            objZzb = ((e) obj).f6721a;
        } else {
            zza zzaVar = this.zzb;
            long j4 = this.zzc;
            zzoe zzoeVar = this.zzd;
            this.zza = 1;
            objZzb = zzaVar.zzb(j4, zzoeVar, this);
            if (objZzb == enumC0789a) {
                return enumC0789a;
            }
        }
        return new e(objZzb);
    }
}
