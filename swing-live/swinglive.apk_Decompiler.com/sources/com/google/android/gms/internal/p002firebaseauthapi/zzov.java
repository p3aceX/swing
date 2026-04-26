package com.google.android.gms.internal.p002firebaseauthapi;

import java.lang.reflect.InvocationTargetException;
import java.security.GeneralSecurityException;
import java.security.Provider;
import java.security.SecureRandom;

/* JADX INFO: loaded from: classes.dex */
public final class zzov {
    private static final ThreadLocal<SecureRandom> zza = new zzou();

    public static /* synthetic */ SecureRandom zza() {
        SecureRandom secureRandomZzc = zzc();
        secureRandomZzc.nextLong();
        return secureRandomZzc;
    }

    private static Provider zzb() throws GeneralSecurityException {
        try {
            return (Provider) Class.forName("org.conscrypt.Conscrypt").getMethod("newProvider", new Class[0]).invoke(null, new Object[0]);
        } catch (ClassNotFoundException | IllegalAccessException | IllegalArgumentException | NoSuchMethodException | InvocationTargetException e) {
            throw new GeneralSecurityException("Failed to get Conscrypt provider", e);
        }
    }

    private static SecureRandom zzc() {
        try {
            try {
                try {
                    try {
                        return SecureRandom.getInstance("SHA1PRNG", "GmsCore_OpenSSL");
                    } catch (GeneralSecurityException unused) {
                        return new SecureRandom();
                    }
                } catch (GeneralSecurityException unused2) {
                    return SecureRandom.getInstance("SHA1PRNG", "Conscrypt");
                }
            } catch (GeneralSecurityException unused3) {
                return SecureRandom.getInstance("SHA1PRNG", "AndroidOpenSSL");
            }
        } catch (GeneralSecurityException unused4) {
            return SecureRandom.getInstance("SHA1PRNG", zzb());
        }
    }

    public static byte[] zza(int i4) {
        byte[] bArr = new byte[i4];
        zza.get().nextBytes(bArr);
        return bArr;
    }
}
