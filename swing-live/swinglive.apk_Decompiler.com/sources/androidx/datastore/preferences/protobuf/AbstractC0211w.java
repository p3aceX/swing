package androidx.datastore.preferences.protobuf;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.w, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0211w {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Charset f3035a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final byte[] f3036b;

    static {
        Charset.forName("US-ASCII");
        f3035a = Charset.forName("UTF-8");
        Charset.forName("ISO-8859-1");
        byte[] bArr = new byte[0];
        f3036b = bArr;
        ByteBuffer.wrap(bArr);
        try {
            new C0197h(bArr, 0, 0, false).l(0);
        } catch (C0213y e) {
            throw new IllegalArgumentException(e);
        }
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
