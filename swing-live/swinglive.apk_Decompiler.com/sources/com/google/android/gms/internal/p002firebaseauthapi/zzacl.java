package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class zzacl {
    public static String zza(zzaci zzaciVar, String str) {
        try {
            String str2 = new String(MessageDigest.getInstance("SHA-256").digest(str.getBytes()));
            int length = str2.length();
            int i4 = 0;
            while (i4 < length) {
                if (zzk.zza(str2.charAt(i4))) {
                    char[] charArray = str2.toCharArray();
                    while (i4 < length) {
                        char c5 = charArray[i4];
                        if (zzk.zza(c5)) {
                            charArray[i4] = (char) (c5 ^ ' ');
                        }
                        i4++;
                    }
                    return String.valueOf(charArray);
                }
                i4++;
            }
            return str2;
        } catch (NoSuchAlgorithmException unused) {
            zzaci.zza.c("Failed to get SHA-256 MessageDigest", new Object[0]);
            return null;
        }
    }

    public static void zzb(zzaci zzaciVar, String str) {
        zzaciVar.zza(str, null);
    }
}
