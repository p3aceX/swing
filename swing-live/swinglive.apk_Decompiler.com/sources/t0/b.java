package T0;

import Y0.s;
import android.os.Build;
import e1.q;
import java.security.GeneralSecurityException;
import java.security.spec.AlgorithmParameterSpec;
import java.util.Objects;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final J0.b f1868c = new J0.b(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final SecretKeySpec f1869a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f1870b;

    public b(byte[] bArr) throws GeneralSecurityException {
        if (!B1.a.g(2)) {
            throw new GeneralSecurityException("Can not use AES-GCM in FIPS-mode, as BoringCrypto module is not available.");
        }
        q.a(bArr.length);
        this.f1869a = new SecretKeySpec(bArr, "AES");
        this.f1870b = true;
    }

    public static AlgorithmParameterSpec a(byte[] bArr) {
        int length = bArr.length;
        int i4 = s.f2502a;
        Integer numValueOf = !Objects.equals(System.getProperty("java.vendor"), "The Android Project") ? null : Integer.valueOf(Build.VERSION.SDK_INT);
        return (numValueOf == null || numValueOf.intValue() > 19) ? new GCMParameterSpec(128, bArr, 0, length) : new IvParameterSpec(bArr, 0, length);
    }
}
