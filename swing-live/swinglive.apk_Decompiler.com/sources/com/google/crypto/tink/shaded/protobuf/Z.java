package com.google.crypto.tink.shaded.protobuf;

import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class Z {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Z f3766c = new Z();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ConcurrentHashMap f3768b = new ConcurrentHashMap();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final K f3767a = new K();

    public final c0 a(Class cls) {
        c0 c0VarC;
        Class cls2;
        AbstractC0320z.a(cls, "messageType");
        ConcurrentHashMap concurrentHashMap = this.f3768b;
        c0 c0Var = (c0) concurrentHashMap.get(cls);
        if (c0Var != null) {
            return c0Var;
        }
        K k4 = this.f3767a;
        k4.getClass();
        Class cls3 = d0.f3779a;
        if (!AbstractC0316v.class.isAssignableFrom(cls) && (cls2 = d0.f3779a) != null && !cls2.isAssignableFrom(cls)) {
            throw new IllegalArgumentException("Message classes must extend GeneratedMessageV3 or GeneratedMessageLite");
        }
        b0 b0VarB = ((J) k4.f3740a).b(cls);
        if ((b0VarB.f3776d & 2) == 2) {
            boolean zIsAssignableFrom = AbstractC0316v.class.isAssignableFrom(cls);
            AbstractC0296a abstractC0296a = b0VarB.f3773a;
            if (zIsAssignableFrom) {
                c0VarC = new U(d0.f3782d, AbstractC0311p.f3827a, abstractC0296a);
            } else {
                g0 g0Var = d0.f3780b;
                C0310o c0310o = AbstractC0311p.f3828b;
                if (c0310o == null) {
                    throw new IllegalStateException("Protobuf runtime is not correctly loaded.");
                }
                c0VarC = new U(g0Var, c0310o, abstractC0296a);
            }
        } else if (AbstractC0316v.class.isAssignableFrom(cls)) {
            c0VarC = (b0VarB.f3776d & 1) == 1 ? T.C(b0VarB, W.f3765b, H.f3737b, d0.f3782d, AbstractC0311p.f3827a, N.f3744b) : T.C(b0VarB, W.f3765b, H.f3737b, d0.f3782d, null, N.f3744b);
        } else if ((b0VarB.f3776d & 1) == 1) {
            V v = W.f3764a;
            F f4 = H.f3736a;
            g0 g0Var2 = d0.f3780b;
            C0310o c0310o2 = AbstractC0311p.f3828b;
            if (c0310o2 == null) {
                throw new IllegalStateException("Protobuf runtime is not correctly loaded.");
            }
            c0VarC = T.C(b0VarB, v, f4, g0Var2, c0310o2, N.f3743a);
        } else {
            c0VarC = T.C(b0VarB, W.f3764a, H.f3736a, d0.f3781c, null, N.f3743a);
        }
        c0 c0Var2 = (c0) concurrentHashMap.putIfAbsent(cls, c0VarC);
        return c0Var2 != null ? c0Var2 : c0VarC;
    }
}
