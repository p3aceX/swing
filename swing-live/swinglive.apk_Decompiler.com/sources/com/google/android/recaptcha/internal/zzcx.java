package com.google.android.recaptcha.internal;

import I3.p;
import J3.j;
import w3.i;

/* JADX INFO: loaded from: classes.dex */
final class zzcx extends j implements p {
    final /* synthetic */ zzcj zza;
    final /* synthetic */ String zzb;
    final /* synthetic */ int zzc;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzcx(zzcj zzcjVar, String str, int i4) {
        super(2);
        this.zza = zzcjVar;
        this.zzb = str;
        this.zzc = i4;
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        Object[] objArr = (Object[]) obj;
        this.zza.zzi().zzb(this.zzb, (String) obj2);
        int i4 = this.zzc;
        if (i4 != -1) {
            this.zza.zzc().zzf(i4, objArr);
        }
        return i.f6729a;
    }
}
