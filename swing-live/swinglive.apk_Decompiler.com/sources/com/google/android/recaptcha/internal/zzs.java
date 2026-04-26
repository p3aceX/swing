package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzs extends j implements p {
    public zzs(InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzs(interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return new zzs((InterfaceC0762c) obj2).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        Thread.currentThread().setPriority(8);
        return i.f6729a;
    }
}
