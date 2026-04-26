package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
class zzao<E> extends zzan<E> {
    Object[] zza;
    int zzb;
    boolean zzc;

    public zzao(int i4) {
        zzaj.zza(4, "initialCapacity");
        this.zza = new Object[4];
        this.zzb = 0;
    }

    public zzao<E> zza(E e) {
        zzz.zza(e);
        int i4 = this.zzb + 1;
        Object[] objArr = this.zza;
        if (objArr.length < i4) {
            this.zza = Arrays.copyOf(objArr, zzan.zza(objArr.length, i4));
            this.zzc = false;
        } else if (this.zzc) {
            this.zza = (Object[]) objArr.clone();
            this.zzc = false;
        }
        Object[] objArr2 = this.zza;
        int i5 = this.zzb;
        this.zzb = i5 + 1;
        objArr2[i5] = e;
        return this;
    }
}
