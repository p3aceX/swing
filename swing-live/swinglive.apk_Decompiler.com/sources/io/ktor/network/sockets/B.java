package io.ktor.network.sockets;

/* JADX INFO: loaded from: classes.dex */
public final class B extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4835a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C f4836b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4837c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public B(C c5, A3.c cVar) {
        super(cVar);
        this.f4836b = c5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4835a = obj;
        this.f4837c |= Integer.MIN_VALUE;
        return this.f4836b.l(null, this);
    }
}
