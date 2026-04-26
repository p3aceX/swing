package io.ktor.network.sockets;

/* JADX INFO: loaded from: classes.dex */
public final class G extends E {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f4842d;

    @Override // io.ktor.network.sockets.E, io.ktor.network.sockets.q
    public final void b(q qVar) {
        J3.i.e(qVar, "from");
        super.b(qVar);
        if (qVar instanceof G) {
            this.f4842d = ((G) qVar).f4842d;
        }
    }
}
