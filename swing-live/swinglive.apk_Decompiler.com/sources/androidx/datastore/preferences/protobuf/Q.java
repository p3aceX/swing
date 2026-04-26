package androidx.datastore.preferences.protobuf;

import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class Q {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Q f2927c = new Q();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ConcurrentHashMap f2929b = new ConcurrentHashMap();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final D f2928a = new D();

    public final U a(Class cls) {
        U uX;
        Class cls2;
        AbstractC0211w.a(cls, "messageType");
        ConcurrentHashMap concurrentHashMap = this.f2929b;
        U u4 = (U) concurrentHashMap.get(cls);
        if (u4 != null) {
            return u4;
        }
        D d5 = this.f2928a;
        d5.getClass();
        Class cls3 = V.f2937a;
        if (!AbstractC0209u.class.isAssignableFrom(cls) && (cls2 = V.f2937a) != null && !cls2.isAssignableFrom(cls)) {
            throw new IllegalArgumentException("Message classes must extend GeneratedMessage or GeneratedMessageLite");
        }
        T tB = ((C) d5.f2898a).b(cls);
        if ((tB.f2936d & 2) == 2) {
            boolean zIsAssignableFrom = AbstractC0209u.class.isAssignableFrom(cls);
            AbstractC0209u abstractC0209u = tB.f2933a;
            if (zIsAssignableFrom) {
                uX = new M(V.f2939c, AbstractC0204o.f3008a, abstractC0209u);
            } else {
                c0 c0Var = V.f2938b;
                C0203n c0203n = AbstractC0204o.f3009b;
                if (c0203n == null) {
                    throw new IllegalStateException("Protobuf runtime is not correctly loaded.");
                }
                uX = new M(c0Var, c0203n, abstractC0209u);
            }
        } else if (AbstractC0209u.class.isAssignableFrom(cls)) {
            C0203n c0203n2 = null;
            N n4 = O.f2926b;
            A a5 = B.f2895b;
            c0 c0Var2 = V.f2939c;
            if (K.j.b(tB.a()) != 1) {
                c0203n2 = AbstractC0204o.f3008a;
            }
            C0203n c0203n3 = c0203n2;
            H h4 = I.f2906b;
            int[] iArr = L.f2908n;
            if (!(tB instanceof T)) {
                tB.getClass();
                throw new ClassCastException();
            }
            uX = L.x(tB, n4, a5, c0Var2, c0203n3, h4);
        } else {
            C0203n c0203n4 = null;
            N n5 = O.f2925a;
            A a6 = B.f2894a;
            c0 c0Var3 = V.f2938b;
            if (K.j.b(tB.a()) != 1 && (c0203n4 = AbstractC0204o.f3009b) == null) {
                throw new IllegalStateException("Protobuf runtime is not correctly loaded.");
            }
            C0203n c0203n5 = c0203n4;
            H h5 = I.f2905a;
            int[] iArr2 = L.f2908n;
            if (!(tB instanceof T)) {
                tB.getClass();
                throw new ClassCastException();
            }
            uX = L.x(tB, n5, a6, c0Var3, c0203n5, h5);
        }
        U u5 = (U) concurrentHashMap.putIfAbsent(cls, uX);
        return u5 != null ? u5 : uX;
    }
}
