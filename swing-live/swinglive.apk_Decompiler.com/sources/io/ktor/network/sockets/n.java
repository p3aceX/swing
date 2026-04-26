package io.ktor.network.sockets;

import java.nio.ByteBuffer;
import v3.C0695a;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class n extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f4906a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public J3.o f4907b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0695a f4908c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f4909d;
    public Z3.a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Z3.f f4910f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ByteBuffer f4911m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public ByteBuffer f4912n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4913o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final /* synthetic */ l f4914p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final /* synthetic */ p f4915q;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public n(l lVar, p pVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4914p = lVar;
        this.f4915q = pVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new n(this.f4914p, this.f4915q, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((n) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:30:0x00cf  */
    /* JADX WARN: Removed duplicated region for block: B:40:0x00f0  */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r19) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 349
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.n.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
