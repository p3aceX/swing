package com.google.android.recaptcha.internal;

import A3.c;
import w3.e;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzar extends c {
    /* synthetic */ Object zza;
    final /* synthetic */ zzaw zzb;
    int zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzar(zzaw zzawVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.zzb = zzawVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        this.zza = obj;
        this.zzc |= Integer.MIN_VALUE;
        Object objMo3executegIAlus = this.zzb.mo3executegIAlus(null, this);
        return objMo3executegIAlus == EnumC0789a.f6999a ? objMo3executegIAlus : new e(objMo3executegIAlus);
    }
}
