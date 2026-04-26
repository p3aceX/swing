package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0311p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0310o f3827a = new C0310o();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0310o f3828b;

    static {
        C0310o c0310o;
        try {
            c0310o = (C0310o) Class.forName("com.google.crypto.tink.shaded.protobuf.ExtensionSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            c0310o = null;
        }
        f3828b = c0310o;
    }
}
