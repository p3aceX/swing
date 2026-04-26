package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
abstract class zzi<T> implements Iterator<T> {
    private int zza = zzh.zzb;
    private T zzb;

    @Override // java.util.Iterator
    public final boolean hasNext() {
        int i4 = this.zza;
        int i5 = zzh.zzd;
        if (i4 == i5) {
            throw new IllegalStateException();
        }
        int i6 = i4 - 1;
        if (i6 == 0) {
            return true;
        }
        if (i6 != 2) {
            this.zza = i5;
            this.zzb = zza();
            if (this.zza != zzh.zzc) {
                this.zza = zzh.zza;
                return true;
            }
        }
        return false;
    }

    @Override // java.util.Iterator
    public final T next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        this.zza = zzh.zzb;
        T t4 = this.zzb;
        this.zzb = null;
        return t4;
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException();
    }

    public abstract T zza();

    public final T zzb() {
        this.zza = zzh.zzc;
        return null;
    }
}
