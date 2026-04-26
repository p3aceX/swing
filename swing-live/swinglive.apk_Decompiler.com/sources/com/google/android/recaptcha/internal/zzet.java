package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.C0146s;
import Q3.D;
import Q3.F;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzet extends j implements p {
    int zza;
    final /* synthetic */ String zzb;
    final /* synthetic */ zzez zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzet(String str, zzez zzezVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = str;
        this.zzc = zzezVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzet(this.zzb, this.zzc, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzet) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            return obj;
        }
        zzez zzezVar = this.zzc;
        String str = this.zzb;
        C0146s c0146sA = F.a();
        zzezVar.zzl.put(str, c0146sA);
        String str2 = this.zzb;
        zzou zzouVarZzf = zzov.zzf();
        zzouVarZzf.zzd(str2);
        byte[] bArrZzd = ((zzov) zzouVarZzf.zzj()).zzd();
        F.s(this.zzc.zzq.zzb(), null, new zzes(this.zzc, zzfy.zzh().zzi(bArrZzd, 0, bArrZzd.length), null), 3);
        this.zza = 1;
        Object objC0 = c0146sA.c0(this);
        return objC0 == enumC0789a ? enumC0789a : objC0;
    }
}
