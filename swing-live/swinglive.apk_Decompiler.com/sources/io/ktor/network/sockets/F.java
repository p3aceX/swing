package io.ktor.network.sockets;

/* JADX INFO: loaded from: classes.dex */
public final class F extends E {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f4840d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public long f4841f;

    @Override // io.ktor.network.sockets.E, io.ktor.network.sockets.q
    public final void b(q qVar) {
        J3.i.e(qVar, "from");
        super.b(qVar);
        if (qVar instanceof F) {
            F f4 = (F) qVar;
            this.f4840d = f4.f4840d;
            this.e = f4.e;
        }
    }
}
