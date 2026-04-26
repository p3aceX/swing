package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: loaded from: classes.dex */
public abstract class W {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final V f3764a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final V f3765b;

    static {
        V v;
        try {
            v = (V) Class.forName("com.google.crypto.tink.shaded.protobuf.NewInstanceSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            v = null;
        }
        f3764a = v;
        f3765b = new V();
    }
}
