package com.google.android.recaptcha.internal;

import A3.c;
import w3.e;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzd extends c {
    /* synthetic */ Object zza;
    final /* synthetic */ zzg zzb;
    int zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzd(zzg zzgVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.zzb = zzgVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.zza = obj;
        this.zzc |= Integer.MIN_VALUE;
        Object objZzb = this.zzb.zzb(0L, null, this);
        return objZzb == EnumC0789a.f6999a ? objZzb : new e(objZzb);
    }
}
