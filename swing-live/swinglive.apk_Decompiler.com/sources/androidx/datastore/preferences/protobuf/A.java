package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class A {
    public static InterfaceC0210v a(Object obj, long j4) {
        InterfaceC0210v interfaceC0210v = (InterfaceC0210v) h0.f2981c.h(obj, j4);
        if (((AbstractC0191b) interfaceC0210v).f2953a) {
            return interfaceC0210v;
        }
        S s4 = (S) interfaceC0210v;
        int i4 = s4.f2932c;
        S sH = s4.h(i4 == 0 ? 10 : i4 * 2);
        h0.o(obj, j4, sH);
        return sH;
    }
}
