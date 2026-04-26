package com.google.android.gms.internal.p002firebaseauthapi;

import android.os.Build;
import java.nio.charset.Charset;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzpg {
    public static final Charset zza = Charset.forName("UTF-8");

    public static int zza() {
        SecureRandom secureRandom = new SecureRandom();
        byte[] bArr = new byte[4];
        int i4 = 0;
        while (i4 == 0) {
            secureRandom.nextBytes(bArr);
            i4 = ((bArr[0] & 255) << 24) | ((bArr[1] & 255) << 16) | ((bArr[2] & 255) << 8) | (bArr[3] & 255);
        }
        return i4;
    }

    public static final zzxr zzb(String str) {
        byte[] bArr = new byte[str.length()];
        for (int i4 = 0; i4 < str.length(); i4++) {
            char cCharAt = str.charAt(i4);
            if (cCharAt < '!' || cCharAt > '~') {
                throw new zzpe("Not a printable ASCII character: " + cCharAt);
            }
            bArr[i4] = (byte) cCharAt;
        }
        return zzxr.zza(bArr);
    }

    public static final zzxr zza(String str) throws GeneralSecurityException {
        byte[] bArr = new byte[str.length()];
        for (int i4 = 0; i4 < str.length(); i4++) {
            char cCharAt = str.charAt(i4);
            if (cCharAt >= '!' && cCharAt <= '~') {
                bArr[i4] = (byte) cCharAt;
            } else {
                throw new GeneralSecurityException("Not a printable ASCII character: " + cCharAt);
            }
        }
        return zzxr.zza(bArr);
    }

    public static Integer zzb() {
        if (Objects.equals(System.getProperty("java.vendor"), "The Android Project")) {
            return Integer.valueOf(Build.VERSION.SDK_INT);
        }
        return null;
    }

    public static boolean zza(byte[] bArr, byte[] bArr2) {
        if (bArr2.length < bArr.length) {
            return false;
        }
        for (int i4 = 0; i4 < bArr.length; i4++) {
            if (bArr2[i4] != bArr[i4]) {
                return false;
            }
        }
        return true;
    }
}
