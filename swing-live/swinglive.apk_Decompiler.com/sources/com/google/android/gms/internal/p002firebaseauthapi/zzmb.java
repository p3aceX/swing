package com.google.android.gms.internal.p002firebaseauthapi;

import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzmb {
    public static BigInteger zza(byte[] bArr) {
        return new BigInteger(1, bArr);
    }

    public static byte[] zza(BigInteger bigInteger) {
        if (bigInteger.signum() != -1) {
            return bigInteger.toByteArray();
        }
        throw new IllegalArgumentException("n must not be negative");
    }

    public static byte[] zza(BigInteger bigInteger, int i4) throws GeneralSecurityException {
        if (bigInteger.signum() != -1) {
            byte[] byteArray = bigInteger.toByteArray();
            if (byteArray.length == i4) {
                return byteArray;
            }
            int i5 = i4 + 1;
            if (byteArray.length <= i5) {
                if (byteArray.length == i5) {
                    if (byteArray[0] == 0) {
                        return Arrays.copyOfRange(byteArray, 1, byteArray.length);
                    }
                    throw new GeneralSecurityException("integer too large");
                }
                byte[] bArr = new byte[i4];
                System.arraycopy(byteArray, 0, bArr, i4 - byteArray.length, byteArray.length);
                return bArr;
            }
            throw new GeneralSecurityException("integer too large");
        }
        throw new IllegalArgumentException("integer must be nonnegative");
    }
}
