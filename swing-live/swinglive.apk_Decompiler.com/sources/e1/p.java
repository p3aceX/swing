package e1;

import java.security.SecureRandom;

/* JADX INFO: loaded from: classes.dex */
public abstract class p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final J0.b f4008a = new J0.b(8);

    public static byte[] a(int i4) {
        byte[] bArr = new byte[i4];
        ((SecureRandom) f4008a.get()).nextBytes(bArr);
        return bArr;
    }
}
