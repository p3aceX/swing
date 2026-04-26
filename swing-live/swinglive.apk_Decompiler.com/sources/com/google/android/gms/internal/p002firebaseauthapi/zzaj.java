package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
final class zzaj {
    public static int zza(int i4, String str) {
        if (i4 >= 0) {
            return i4;
        }
        throw new IllegalArgumentException(str + " cannot be negative but was: " + i4);
    }

    public static void zza(Object obj, Object obj2) {
        if (obj == null) {
            throw new NullPointerException("null key in entry: null=".concat(String.valueOf(obj2)));
        }
        if (obj2 == null) {
            throw new NullPointerException(S.g("null value in entry: ", String.valueOf(obj), "=null"));
        }
    }
}
