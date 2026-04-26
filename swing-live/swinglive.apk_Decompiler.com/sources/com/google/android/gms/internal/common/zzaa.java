package com.google.android.gms.internal.common;

import com.google.android.gms.common.api.f;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
class zzaa extends zzab {
    Object[] zza = new Object[4];
    int zzb = 0;
    boolean zzc;

    public zzaa(int i4) {
    }

    public final zzaa zza(Object obj) {
        obj.getClass();
        int i4 = this.zzb;
        int i5 = i4 + 1;
        Object[] objArr = this.zza;
        int length = objArr.length;
        if (length < i5) {
            int i6 = length + (length >> 1) + 1;
            if (i6 < i5) {
                int iHighestOneBit = Integer.highestOneBit(i4);
                i6 = iHighestOneBit + iHighestOneBit;
            }
            if (i6 < 0) {
                i6 = f.API_PRIORITY_OTHER;
            }
            this.zza = Arrays.copyOf(objArr, i6);
            this.zzc = false;
        } else if (this.zzc) {
            this.zza = (Object[]) objArr.clone();
            this.zzc = false;
        }
        Object[] objArr2 = this.zza;
        int i7 = this.zzb;
        this.zzb = i7 + 1;
        objArr2[i7] = obj;
        return this;
    }
}
