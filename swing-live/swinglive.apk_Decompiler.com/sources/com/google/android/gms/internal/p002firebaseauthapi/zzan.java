package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.f;

/* JADX INFO: loaded from: classes.dex */
public class zzan<E> {
    public static int zza(int i4, int i5) {
        if (i5 < 0) {
            throw new AssertionError("cannot store more than MAX_VALUE elements");
        }
        int iHighestOneBit = i4 + (i4 >> 1) + 1;
        if (iHighestOneBit < i5) {
            iHighestOneBit = Integer.highestOneBit(i5 - 1) << 1;
        }
        return iHighestOneBit < 0 ? f.API_PRIORITY_OTHER : iHighestOneBit;
    }
}
