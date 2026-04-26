package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0298c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Class f3777a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final boolean f3778b;

    static {
        Class<?> cls;
        Class<?> cls2 = null;
        try {
            cls = Class.forName("libcore.io.Memory");
        } catch (Throwable unused) {
            cls = null;
        }
        f3777a = cls;
        try {
            cls2 = Class.forName("org.robolectric.Robolectric");
        } catch (Throwable unused2) {
        }
        f3778b = cls2 != null;
    }

    public static boolean a() {
        return (f3777a == null || f3778b) ? false : true;
    }
}
