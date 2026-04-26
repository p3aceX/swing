package com.google.android.recaptcha.internal;

import A3.c;
import w3.e;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzas extends c {
    /* synthetic */ Object zza;
    final /* synthetic */ zzaw zzb;
    int zzc;
    zzaw zzd;
    zzbd zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzas(zzaw zzawVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.zzb = zzawVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.zza = obj;
        this.zzc |= Integer.MIN_VALUE;
        Object objZzk = this.zzb.zzk(null, 0L, this);
        return objZzk == EnumC0789a.f6999a ? objZzk : new e(objZzk);
    }
}
