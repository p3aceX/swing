package com.google.android.recaptcha;

import A3.c;
import w3.e;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class Recaptcha$getClient$1 extends c {
    /* synthetic */ Object zza;
    final /* synthetic */ Recaptcha zzb;
    int zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public Recaptcha$getClient$1(Recaptcha recaptcha, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.zzb = recaptcha;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.zza = obj;
        this.zzc |= Integer.MIN_VALUE;
        Object objM1getClientBWLJW6A = this.zzb.m1getClientBWLJW6A(null, null, 0L, this);
        return objM1getClientBWLJW6A == EnumC0789a.f6999a ? objM1getClientBWLJW6A : new e(objM1getClientBWLJW6A);
    }
}
