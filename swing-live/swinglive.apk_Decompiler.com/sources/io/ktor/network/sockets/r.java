package io.ktor.network.sockets;

import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class r extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ByteBuffer f4926a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public t f4927b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4928c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ t f4929d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public r(t tVar, A3.c cVar) {
        super(cVar);
        this.f4929d = tVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4928c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4929d.o(null, this);
    }
}
