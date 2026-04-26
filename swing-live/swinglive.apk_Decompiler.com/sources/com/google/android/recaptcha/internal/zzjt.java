package com.google.android.recaptcha.internal;

import B1.a;
import com.google.android.gms.common.api.f;
import java.util.AbstractList;
import java.util.Arrays;
import java.util.Collection;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzjt extends zzgh implements RandomAccess, zzja, zzkm {
    private static final zzjt zza = new zzjt(new long[0], 0, false);
    private long[] zzb;
    private int zzc;

    public zzjt() {
        this(new long[10], 0, true);
    }

    public static zzjt zzf() {
        return zza;
    }

    private final String zzh(int i4) {
        return a.k("Index:", i4, this.zzc, ", Size:");
    }

    private final void zzi(int i4) {
        if (i4 < 0 || i4 >= this.zzc) {
            throw new IndexOutOfBoundsException(zzh(i4));
        }
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractList, java.util.List
    public final /* synthetic */ void add(int i4, Object obj) {
        int i5;
        long jLongValue = ((Long) obj).longValue();
        zza();
        if (i4 < 0 || i4 > (i5 = this.zzc)) {
            throw new IndexOutOfBoundsException(zzh(i4));
        }
        int i6 = i4 + 1;
        long[] jArr = this.zzb;
        if (i5 < jArr.length) {
            System.arraycopy(jArr, i4, jArr, i6, i5 - i4);
        } else {
            long[] jArr2 = new long[a.i(i5, 3, 2, 1)];
            System.arraycopy(jArr, 0, jArr2, 0, i4);
            System.arraycopy(this.zzb, i4, jArr2, i6, this.zzc - i4);
            this.zzb = jArr2;
        }
        this.zzb[i4] = jLongValue;
        this.zzc++;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection collection) {
        zza();
        byte[] bArr = zzjc.zzd;
        collection.getClass();
        if (!(collection instanceof zzjt)) {
            return super.addAll(collection);
        }
        zzjt zzjtVar = (zzjt) collection;
        int i4 = zzjtVar.zzc;
        if (i4 == 0) {
            return false;
        }
        int i5 = this.zzc;
        if (f.API_PRIORITY_OTHER - i5 < i4) {
            throw new OutOfMemoryError();
        }
        int i6 = i5 + i4;
        long[] jArr = this.zzb;
        if (i6 > jArr.length) {
            this.zzb = Arrays.copyOf(jArr, i6);
        }
        System.arraycopy(zzjtVar.zzb, 0, this.zzb, this.zzc, zzjtVar.zzc);
        this.zzc = i6;
        ((AbstractList) this).modCount++;
        return true;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean contains(Object obj) {
        return indexOf(obj) != -1;
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractList, java.util.Collection, java.util.List
    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof zzjt)) {
            return super.equals(obj);
        }
        zzjt zzjtVar = (zzjt) obj;
        if (this.zzc != zzjtVar.zzc) {
            return false;
        }
        long[] jArr = zzjtVar.zzb;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            if (this.zzb[i4] != jArr[i4]) {
                return false;
            }
        }
        return true;
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* synthetic */ Object get(int i4) {
        zzi(i4);
        return Long.valueOf(this.zzb[i4]);
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractList, java.util.Collection, java.util.List
    public final int hashCode() {
        int i4 = 1;
        for (int i5 = 0; i5 < this.zzc; i5++) {
            long j4 = this.zzb[i5];
            byte[] bArr = zzjc.zzd;
            i4 = (i4 * 31) + ((int) (j4 ^ (j4 >>> 32)));
        }
        return i4;
    }

    @Override // java.util.AbstractList, java.util.List
    public final int indexOf(Object obj) {
        if (!(obj instanceof Long)) {
            return -1;
        }
        long jLongValue = ((Long) obj).longValue();
        int i4 = this.zzc;
        for (int i5 = 0; i5 < i4; i5++) {
            if (this.zzb[i5] == jLongValue) {
                return i5;
            }
        }
        return -1;
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractList, java.util.List
    public final /* bridge */ /* synthetic */ Object remove(int i4) {
        zza();
        zzi(i4);
        long[] jArr = this.zzb;
        long j4 = jArr[i4];
        if (i4 < this.zzc - 1) {
            System.arraycopy(jArr, i4 + 1, jArr, i4, (r3 - i4) - 1);
        }
        this.zzc--;
        ((AbstractList) this).modCount++;
        return Long.valueOf(j4);
    }

    @Override // java.util.AbstractList
    public final void removeRange(int i4, int i5) {
        zza();
        if (i5 < i4) {
            throw new IndexOutOfBoundsException("toIndex < fromIndex");
        }
        long[] jArr = this.zzb;
        System.arraycopy(jArr, i5, jArr, i4, this.zzc - i5);
        this.zzc -= i5 - i4;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractList, java.util.List
    public final /* bridge */ /* synthetic */ Object set(int i4, Object obj) {
        long jLongValue = ((Long) obj).longValue();
        zza();
        zzi(i4);
        long[] jArr = this.zzb;
        long j4 = jArr[i4];
        jArr[i4] = jLongValue;
        return Long.valueOf(j4);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.recaptcha.internal.zzjb
    public final /* bridge */ /* synthetic */ zzjb zzd(int i4) {
        if (i4 >= this.zzc) {
            return new zzjt(Arrays.copyOf(this.zzb, i4), this.zzc, true);
        }
        throw new IllegalArgumentException();
    }

    public final long zze(int i4) {
        zzi(i4);
        return this.zzb[i4];
    }

    public final void zzg(long j4) {
        zza();
        int i4 = this.zzc;
        long[] jArr = this.zzb;
        if (i4 == jArr.length) {
            long[] jArr2 = new long[a.i(i4, 3, 2, 1)];
            System.arraycopy(jArr, 0, jArr2, 0, i4);
            this.zzb = jArr2;
        }
        long[] jArr3 = this.zzb;
        int i5 = this.zzc;
        this.zzc = i5 + 1;
        jArr3[i5] = j4;
    }

    private zzjt(long[] jArr, int i4, boolean z4) {
        super(z4);
        this.zzb = jArr;
        this.zzc = i4;
    }

    @Override // com.google.android.recaptcha.internal.zzgh, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ boolean add(Object obj) {
        zzg(((Long) obj).longValue());
        return true;
    }
}
