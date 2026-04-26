package com.google.crypto.tink.shaded.protobuf;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.z, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0320z {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Charset f3839a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final byte[] f3840b;

    static {
        Charset.forName("US-ASCII");
        f3839a = Charset.forName("UTF-8");
        Charset.forName("ISO-8859-1");
        byte[] bArr = new byte[0];
        f3840b = bArr;
        ByteBuffer.wrap(bArr);
        T0.d.h(bArr, 0, 0, false);
    }

    public static void a(Object obj, String str) {
        if (obj == null) {
            throw new NullPointerException(str);
        }
    }

    public static int b(long j4) {
        return (int) (j4 ^ (j4 >>> 32));
    }
}
