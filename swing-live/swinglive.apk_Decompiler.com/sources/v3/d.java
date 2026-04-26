package V3;

import Q3.D;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class d implements D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0767h f2220a;

    public d(InterfaceC0767h interfaceC0767h) {
        this.f2220a = interfaceC0767h;
    }

    @Override // Q3.D
    public final InterfaceC0767h n() {
        return this.f2220a;
    }

    public final String toString() {
        return "CoroutineScope(coroutineContext=" + this.f2220a + ')';
    }
}
