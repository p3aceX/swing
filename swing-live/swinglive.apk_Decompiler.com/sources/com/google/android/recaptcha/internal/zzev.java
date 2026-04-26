package com.google.android.recaptcha.internal;

import A3.c;
import w3.e;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzev extends c {
    long zza;
    /* synthetic */ Object zzb;
    final /* synthetic */ zzez zzc;
    int zzd;
    zzez zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzev(zzez zzezVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.zzc = zzezVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.zzb = obj;
        this.zzd |= Integer.MIN_VALUE;
        Object objZzb = this.zzc.zzb(0L, null, this);
        return objZzb == EnumC0789a.f6999a ? objZzb : new e(objZzb);
    }
}
