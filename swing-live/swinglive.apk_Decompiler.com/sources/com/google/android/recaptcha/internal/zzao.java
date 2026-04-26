package com.google.android.recaptcha.internal;

import A3.c;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
final class zzao extends c {
    /* synthetic */ Object zza;
    final /* synthetic */ zzaw zzb;
    int zzc;
    zzaw zzd;
    zzbb zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzao(zzaw zzawVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.zzb = zzawVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.zza = obj;
        this.zzc |= Integer.MIN_VALUE;
        return this.zzb.zzj(0L, null, null, this);
    }
}
