package io.ktor.utils.io;

import y3.InterfaceC0762c;

/* JADX INFO: renamed from: io.ktor.utils.io.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0446j extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4986a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0449m f4987b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4988c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0446j(C0449m c0449m, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f4987b = c0449m;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4986a = obj;
        this.f4988c |= Integer.MIN_VALUE;
        return this.f4987b.i(this);
    }
}
