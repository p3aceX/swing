package io.ktor.network.sockets;

import java.nio.channels.SocketChannel;

/* JADX INFO: loaded from: classes.dex */
public final class j extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public SocketChannel f4895a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C f4896b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4897c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4898d;

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4897c = obj;
        this.f4898d |= Integer.MIN_VALUE;
        return q.d(null, null, null, this);
    }
}
