package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzj {
    public int zza(CharSequence charSequence, int i4) {
        int length = charSequence.length();
        zzz.zza(i4, length, "index");
        while (i4 < length) {
            if (zza(charSequence.charAt(i4))) {
                return i4;
            }
            i4++;
        }
        return -1;
    }

    public abstract boolean zza(char c5);
}
