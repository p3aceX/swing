package io.ktor.network.sockets;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class m extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public l f4901a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f4902b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4903c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f4904d;
    public final /* synthetic */ p e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4905f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public m(p pVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.e = pVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4904d = obj;
        this.f4905f |= Integer.MIN_VALUE;
        return this.e.m(null, this);
    }
}
