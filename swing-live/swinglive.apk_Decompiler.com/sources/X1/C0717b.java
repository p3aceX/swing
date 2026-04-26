package x1;

import android.content.Context;
import android.security.keystore.KeyGenParameterSpec;
import com.google.android.gms.common.internal.r;
import java.math.BigInteger;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.MGF1ParameterSpec;
import java.util.Calendar;
import javax.crypto.Cipher;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;
import javax.security.auth.x500.X500Principal;

/* JADX INFO: renamed from: x1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0717b extends r {
    @Override // com.google.android.gms.common.internal.r
    public final KeyGenParameterSpec C(Calendar calendar, Calendar calendar2) {
        String str = (String) this.f3597b;
        return new KeyGenParameterSpec.Builder(str, 3).setCertificateSubject(new X500Principal(B1.a.m("CN=", str))).setDigests("SHA-256").setBlockModes("ECB").setEncryptionPaddings("OAEPPadding").setCertificateSerialNumber(BigInteger.valueOf(1L)).setCertificateNotBefore(calendar.getTime()).setCertificateNotAfter(calendar2.getTime()).build();
    }

    @Override // com.google.android.gms.common.internal.r
    public final String x() {
        return ((Context) this.f3598c).getPackageName() + ".FlutterSecureStoragePluginKeyOAEP";
    }

    @Override // com.google.android.gms.common.internal.r
    public final AlgorithmParameterSpec y() {
        return new OAEPParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA1, PSource.PSpecified.DEFAULT);
    }

    @Override // com.google.android.gms.common.internal.r
    public final Cipher z() {
        return Cipher.getInstance("RSA/ECB/OAEPPadding", "AndroidKeyStoreBCWorkaround");
    }
}
