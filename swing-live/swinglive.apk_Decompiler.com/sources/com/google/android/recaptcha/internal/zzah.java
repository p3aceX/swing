package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import android.app.Application;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzah extends j implements p {
    int zza;
    final /* synthetic */ Application zzb;
    final /* synthetic */ String zzc;
    final /* synthetic */ long zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzah(Application application, String str, long j4, zzbq zzbqVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = application;
        this.zzc = str;
        this.zzd = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzah(this.zzb, this.zzc, this.zzd, null, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzah) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            return obj;
        }
        Application application = this.zzb;
        String str = this.zzc;
        long j4 = this.zzd;
        zzam zzamVar = zzam.zza;
        this.zza = 1;
        Object objZza = zzamVar.zza(application, str, j4, new zzab("https://www.recaptcha.net/recaptcha/api3"), null, null, zzam.zze, this);
        return objZza == enumC0789a ? enumC0789a : objZza;
    }
}
