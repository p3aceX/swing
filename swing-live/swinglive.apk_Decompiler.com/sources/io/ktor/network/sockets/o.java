package io.ktor.network.sockets;

import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class o extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ByteBuffer f4916a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public q f4917b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4918c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ p f4919d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public o(p pVar, A3.c cVar) {
        super(cVar);
        this.f4919d = pVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4918c = obj;
        this.e |= Integer.MIN_VALUE;
        return p.a(this.f4919d, null, null, this);
    }
}
