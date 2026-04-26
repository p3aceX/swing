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
final class zzak extends j implements p {
    int zza;
    final /* synthetic */ Application zzb;
    final /* synthetic */ String zzc;
    final /* synthetic */ long zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzak(Application application, String str, long j4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = application;
        this.zzc = str;
        this.zzd = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzak(this.zzb, this.zzc, this.zzd, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzak) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            return obj;
        }
        zzam zzamVar = zzam.zza;
        Application application = this.zzb;
        String str = this.zzc;
        long j4 = this.zzd;
        this.zza = 1;
        Object objZzc = zzam.zzc(application, str, j4, null, this);
        return objZzc == enumC0789a ? enumC0789a : objZzc;
    }
}
