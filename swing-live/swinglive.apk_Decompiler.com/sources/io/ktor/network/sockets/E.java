package io.ktor.network.sockets;

import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public class E extends q {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4839c;

    public E(HashMap map) {
        super(map);
        this.f4839c = -1;
    }

    @Override // io.ktor.network.sockets.q
    public void b(q qVar) {
        J3.i.e(qVar, "from");
        if (qVar instanceof E) {
            this.f4839c = ((E) qVar).f4839c;
        }
    }
}
