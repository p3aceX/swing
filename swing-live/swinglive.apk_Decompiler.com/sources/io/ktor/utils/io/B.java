package io.ktor.utils.io;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class B extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4952a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ com.google.android.gms.common.internal.r f4953b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4954c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public B(com.google.android.gms.common.internal.r rVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f4953b = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4952a = obj;
        this.f4954c |= Integer.MIN_VALUE;
        return this.f4953b.i(this);
    }
}
