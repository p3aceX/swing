package io.ktor.network.sockets;

import e1.AbstractC0367g;
import io.ktor.utils.io.C0449m;
import java.net.SocketTimeoutException;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: io.ktor.network.sockets.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0430b extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ C0449m f4844a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0430b(C0449m c0449m, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f4844a = c0449m;
    }

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new C0430b(this.f4844a, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        C0430b c0430b = (C0430b) create((InterfaceC0762c) obj);
        w3.i iVar = w3.i.f6729a;
        c0430b.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        io.ktor.utils.io.z.b(this.f4844a, new SocketTimeoutException());
        return w3.i.f6729a;
    }
}
