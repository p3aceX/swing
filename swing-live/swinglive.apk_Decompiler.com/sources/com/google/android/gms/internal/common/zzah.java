package com.google.android.gms.internal.common;

import com.google.crypto.tink.shaded.protobuf.S;
import org.jspecify.nullness.NullMarked;

/* JADX INFO: loaded from: classes.dex */
@NullMarked
public final class zzah {
    public static Object[] zza(Object[] objArr, int i4) {
        for (int i5 = 0; i5 < i4; i5++) {
            if (objArr[i5] == null) {
                throw new NullPointerException(S.d(i5, "at index "));
            }
        }
        return objArr;
    }
}
