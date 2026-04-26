package Y0;

import f1.C0400a;
import java.nio.charset.Charset;
import java.security.SecureRandom;

/* JADX INFO: loaded from: classes.dex */
public abstract class s {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ int f2502a = 0;

    static {
        Charset.forName("UTF-8");
    }

    public static int a() {
        SecureRandom secureRandom = new SecureRandom();
        byte[] bArr = new byte[4];
        int i4 = 0;
        while (i4 == 0) {
            secureRandom.nextBytes(bArr);
            i4 = ((bArr[0] & 127) << 24) | ((bArr[1] & 255) << 16) | ((bArr[2] & 255) << 8) | (bArr[3] & 255);
        }
        return i4;
    }

    public static final C0400a b(String str) {
        byte[] bArr = new byte[str.length()];
        for (int i4 = 0; i4 < str.length(); i4++) {
            char cCharAt = str.charAt(i4);
            if (cCharAt < '!' || cCharAt > '~') {
                throw new A0.b("Not a printable ASCII character: " + cCharAt);
            }
            bArr[i4] = (byte) cCharAt;
        }
        return C0400a.a(bArr);
    }
}
