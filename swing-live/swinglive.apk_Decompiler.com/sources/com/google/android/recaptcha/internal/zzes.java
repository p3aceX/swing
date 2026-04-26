package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzes extends j implements p {
    final /* synthetic */ zzez zza;
    final /* synthetic */ String zzb;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzes(zzez zzezVar, String str, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = zzezVar;
        this.zzb = str;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzes(this.zza, this.zzb, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzes) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        this.zza.zzc().evaluateJavascript("recaptcha.m.Main.execute(\"" + this.zzb + "\")", null);
        return i.f6729a;
    }
}
