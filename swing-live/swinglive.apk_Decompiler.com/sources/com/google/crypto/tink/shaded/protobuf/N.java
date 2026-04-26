package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: loaded from: classes.dex */
public abstract class N {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final M f3743a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final M f3744b;

    static {
        M m4;
        try {
            m4 = (M) Class.forName("com.google.crypto.tink.shaded.protobuf.MapFieldSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            m4 = null;
        }
        f3743a = m4;
        f3744b = new M();
    }
}
