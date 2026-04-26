package y3;

import I3.p;
import java.io.Serializable;

/* JADX INFO: renamed from: y3.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0768i implements InterfaceC0767h, Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0768i f6945a = new C0768i();

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h c(InterfaceC0766g interfaceC0766g) {
        J3.i.e(interfaceC0766g, "key");
        return this;
    }

    public final int hashCode() {
        return 0;
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        J3.i.e(interfaceC0766g, "key");
        return null;
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h s(InterfaceC0767h interfaceC0767h) {
        J3.i.e(interfaceC0767h, "context");
        return interfaceC0767h;
    }

    public final String toString() {
        return "EmptyCoroutineContext";
    }

    @Override // y3.InterfaceC0767h
    public final Object h(Object obj, p pVar) {
        return obj;
    }
}
