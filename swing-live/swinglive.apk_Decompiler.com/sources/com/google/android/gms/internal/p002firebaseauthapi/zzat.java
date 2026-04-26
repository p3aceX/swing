package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;
import java.util.Collection;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zzat<K, V> {
    zzaw zza;
    private Object[] zzb;
    private int zzc;
    private boolean zzd;

    public zzat() {
        this(4);
    }

    public final zzat<K, V> zza(Iterable<? extends Map.Entry<? extends K, ? extends V>> iterable) {
        if (iterable instanceof Collection) {
            zza(((Collection) iterable).size() + this.zzc);
        }
        for (Map.Entry<? extends K, ? extends V> entry : iterable) {
            K key = entry.getKey();
            V value = entry.getValue();
            zza(this.zzc + 1);
            zzaj.zza(key, value);
            Object[] objArr = this.zzb;
            int i4 = this.zzc;
            objArr[i4 * 2] = key;
            objArr[(i4 * 2) + 1] = value;
            this.zzc = i4 + 1;
        }
        return this;
    }

    public zzat(int i4) {
        this.zzb = new Object[i4 * 2];
        this.zzc = 0;
        this.zzd = false;
    }

    public final zzau<K, V> zza() {
        zzaw zzawVar = this.zza;
        if (zzawVar == null) {
            int i4 = this.zzc;
            Object[] objArr = this.zzb;
            this.zzd = true;
            zzax zzaxVarZza = zzax.zza(i4, objArr, this);
            zzaw zzawVar2 = this.zza;
            if (zzawVar2 == null) {
                return zzaxVarZza;
            }
            throw zzawVar2.zza();
        }
        throw zzawVar.zza();
    }

    private final void zza(int i4) {
        int i5 = i4 << 1;
        Object[] objArr = this.zzb;
        if (i5 > objArr.length) {
            this.zzb = Arrays.copyOf(objArr, zzan.zza(objArr.length, i5));
            this.zzd = false;
        }
    }
}
