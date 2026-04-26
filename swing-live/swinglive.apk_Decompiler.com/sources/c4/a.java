package c4;

import d4.e;
import java.io.Serializable;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: loaded from: classes.dex */
public final class a implements b4.b, Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public e f3307a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public LinkedBlockingQueue f3308b;

    @Override // b4.b
    public final boolean a() {
        return true;
    }

    @Override // b4.b
    public final void c(String str) {
        b bVar = new b();
        System.currentTimeMillis();
        bVar.f3309a = this.f3307a;
        Thread.currentThread().getName();
        this.f3308b.add(bVar);
    }
}
