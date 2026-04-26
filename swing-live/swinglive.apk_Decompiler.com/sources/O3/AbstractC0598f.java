package o3;

import java.nio.charset.Charset;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: renamed from: o3.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0598f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final byte[] f6088a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final byte[] f6089b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final byte[] f6090c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final byte[] f6091d;

    static {
        Charset charset = P3.a.f1492a;
        byte[] bytes = "master secret".getBytes(charset);
        J3.i.d(bytes, "getBytes(...)");
        f6088a = bytes;
        byte[] bytes2 = "key expansion".getBytes(charset);
        J3.i.d(bytes2, "getBytes(...)");
        f6089b = bytes2;
        byte[] bytes3 = "client finished".getBytes(charset);
        J3.i.d(bytes3, "getBytes(...)");
        f6090c = bytes3;
        byte[] bytes4 = "server finished".getBytes(charset);
        J3.i.d(bytes4, "getBytes(...)");
        f6091d = bytes4;
    }

    public static final SecretKeySpec a(C0594b c0594b, byte[] bArr) {
        J3.i.e(c0594b, "suite");
        return new SecretKeySpec(bArr, c0594b.f6080p * 2, c0594b.f6079o, P3.m.H0(c0594b.e, "/"));
    }

    public static final SecretKeySpec b(C0594b c0594b, byte[] bArr) {
        J3.i.e(c0594b, "suite");
        int i4 = c0594b.f6080p * 2;
        int i5 = c0594b.f6079o;
        return new SecretKeySpec(bArr, i4 + i5, i5, P3.m.H0(c0594b.e, "/"));
    }
}
