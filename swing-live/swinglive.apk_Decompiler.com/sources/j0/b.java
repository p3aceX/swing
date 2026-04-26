package J0;

import K.k;
import e1.j;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Random;
import javax.crypto.Cipher;

/* JADX INFO: loaded from: classes.dex */
public final class b extends ThreadLocal {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f767a;

    @Override // java.lang.ThreadLocal
    public final Object initialValue() {
        switch (this.f767a) {
            case 0:
                return 0L;
            case 1:
                return new Random();
            case 2:
                try {
                    return (Cipher) j.f3998b.f4000a.e("AES/GCM/NoPadding");
                } catch (GeneralSecurityException e) {
                    throw new IllegalStateException(e);
                }
            case 3:
                try {
                    return (Cipher) j.f3998b.f4000a.e("AES/GCM-SIV/NoPadding");
                } catch (GeneralSecurityException e4) {
                    throw new IllegalStateException(e4);
                }
            case 4:
                return Boolean.FALSE;
            case 5:
                try {
                    return (Cipher) j.f3998b.f4000a.e("AES/CTR/NoPadding");
                } catch (GeneralSecurityException e5) {
                    throw new IllegalStateException(e5);
                }
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                try {
                    return (Cipher) j.f3998b.f4000a.e("AES/ECB/NOPADDING");
                } catch (GeneralSecurityException e6) {
                    throw new IllegalStateException(e6);
                }
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                try {
                    return (Cipher) j.f3998b.f4000a.e("AES/CTR/NOPADDING");
                } catch (GeneralSecurityException e7) {
                    throw new IllegalStateException(e7);
                }
            default:
                SecureRandom secureRandom = new SecureRandom();
                secureRandom.nextLong();
                return secureRandom;
        }
    }
}
