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
final class zzey extends j implements p {
    final /* synthetic */ zzez zza;
    final /* synthetic */ zzoe zzb;
    final /* synthetic */ zzbb zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzey(zzez zzezVar, zzoe zzoeVar, zzbb zzbbVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = zzezVar;
        this.zzb = zzoeVar;
        this.zzc = zzbbVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzey(this.zza, this.zzb, this.zzc, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzey) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Exception {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        try {
            zzez zzezVar = this.zza;
            F.s(this.zza.zzq.zzb(), null, new zzex(this.zza, zzezVar.zzf().zzb(this.zzb, zzezVar.zzp), null), 3);
        } catch (zzp e) {
            zzez zzezVar2 = this.zza;
            zzezVar2.zzi.zzb(this.zzc, e, null);
            ((C0146s) this.zza.zzk()).d0(e);
        }
        return i.f6729a;
    }
}
