package com.google.android.recaptcha.internal;

import A3.g;
import A3.j;
import I3.p;
import Q3.C0146s;
import Q3.D;
import Q3.r;
import e1.AbstractC0367g;
import w3.e;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzew extends j implements p {
    int zza;
    final /* synthetic */ zzez zzb;
    final /* synthetic */ zzoe zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzew(zzez zzezVar, zzoe zzoeVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzezVar;
        this.zzc = zzoeVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzew(this.zzb, this.zzc, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzew) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 == 0) {
            zzez zzezVar = this.zzb;
            zzezVar.zzi.zza(zzezVar.zzp.zza(zzne.INIT_NATIVE));
            zzcb.zza(zznz.zzj(zzfy.zzh().zzj(this.zzc.zzJ())));
            this.zzb.zzn.zzd();
            this.zzb.zzn.zze();
            zzez.zzl(this.zzb, this.zzc);
            g.a(this.zzb.zzk().hashCode());
            r rVarZzk = this.zzb.zzk();
            this.zza = 1;
            if (((C0146s) rVarZzk).c0(this) == enumC0789a) {
                return enumC0789a;
            }
        }
        return new e(i.f6729a);
    }
}
