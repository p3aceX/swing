package com.google.crypto.tink.shaded.protobuf;

import java.util.Collections;
import java.util.Map;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0309n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static volatile C0309n f3818a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0309n f3819b;

    static {
        C0309n c0309n = new C0309n();
        Map map = Collections.EMPTY_MAP;
        f3819b = c0309n;
    }

    public static C0309n a() {
        C0309n c0309n;
        C0309n c0309n2 = f3818a;
        if (c0309n2 != null) {
            return c0309n2;
        }
        synchronized (C0309n.class) {
            try {
                c0309n = f3818a;
                if (c0309n == null) {
                    Class cls = AbstractC0308m.f3817a;
                    C0309n c0309n3 = null;
                    if (cls != null) {
                        try {
                            c0309n3 = (C0309n) cls.getDeclaredMethod("getEmptyRegistry", new Class[0]).invoke(null, new Object[0]);
                        } catch (Exception unused) {
                        }
                    }
                    c0309n = c0309n3 != null ? c0309n3 : f3819b;
                    f3818a = c0309n;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return c0309n;
    }
}
