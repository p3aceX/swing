package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.common.api.f;
import java.util.AbstractList;
import java.util.Arrays;
import java.util.Collection;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzajz extends zzahg<Long> implements zzajg<Long>, zzakw, RandomAccess {
    private static final zzajz zza = new zzajz(new long[0], 0, false);
    private long[] zzb;
    private int zzc;

    public zzajz() {
        this(new long[10], 0, true);
    }

    private final String zzc(int i4) {
        return a.k("Index:", i4, this.zzc, ", Size:");
    }

    private final void zzd(int i4) {
        if (i4 < 0 || i4 >= this.zzc) {
            throw new IndexOutOfBoundsException(zzc(i4));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ void add(int i4, Object obj) {
        int i5;
        long jLongValue = ((Long) obj).longValue();
        zza();
        if (i4 < 0 || i4 > (i5 = this.zzc)) {
            throw new IndexOutOfBoundsException(zzc(i4));
        }
        long[] jArr = this.zzb;
        if (i5 < jArr.length) {
            System.arraycopy(jArr, i4, jArr, i4 + 1, i5 - i4);
        } else {
            long[] jArr2 = new long[a.i(i5, 3, 2, 1)];
            System.arraycopy(jArr, 0, jArr2, 0, i4);
            System.arraycopy(this.zzb, i4, jArr2, i4 + 1, this.zzc - i4);
            this.zzb = jArr2;
        }
        this.zzb[i4] = jLongValue;
        this.zzc++;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection<? extends Long> collection) {
        zza();
        zzajc.zza(collection);
        if (!(collection instanceof zzajz)) {
            return super.addAll(collection);
        }
        zzajz zzajzVar = (zzajz) collection;
        int i4 = zzajzVar.zzc;
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
        System.arraycopy(zzajzVar.zzb, 0, this.zzb, this.zzc, zzajzVar.zzc);
        this.zzc = i6;
        ((AbstractList) this).modCount++;
        return true;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean contains(Object obj) {
        return indexOf(obj) != -1;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.Collection, java.util.List
    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof zzajz)) {
            return super.equals(obj);
        }
        zzajz zzajzVar = (zzajz) obj;
        if (this.zzc != zzajzVar.zzc) {
            return false;
        }
        long[] jArr = zzajzVar.zzb;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            if (this.zzb[i4] != jArr[i4]) {
                return false;
            }
        }
        return true;
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* synthetic */ Object get(int i4) {
        return Long.valueOf(zzb(i4));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.Collection, java.util.List
    public final int hashCode() {
        int iZza = 1;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            iZza = (iZza * 31) + zzajc.zza(this.zzb[i4]);
        }
        return iZza;
    }

    @Override // java.util.AbstractList, java.util.List
    public final int indexOf(Object obj) {
        if (!(obj instanceof Long)) {
            return -1;
        }
        long jLongValue = ((Long) obj).longValue();
        int size = size();
        for (int i4 = 0; i4 < size; i4++) {
            if (this.zzb[i4] == jLongValue) {
                return i4;
            }
        }
        return -1;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object remove(int i4) {
        zza();
        zzd(i4);
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

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object set(int i4, Object obj) {
        long jLongValue = ((Long) obj).longValue();
        zza();
        zzd(i4);
        long[] jArr = this.zzb;
        long j4 = jArr[i4];
        jArr[i4] = jLongValue;
        return Long.valueOf(j4);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajg
    public final /* synthetic */ zzajg<Long> zza(int i4) {
        if (i4 >= this.zzc) {
            return new zzajz(Arrays.copyOf(this.zzb, i4), this.zzc, true);
        }
        throw new IllegalArgumentException();
    }

    public final long zzb(int i4) {
        zzd(i4);
        return this.zzb[i4];
    }

    private zzajz(long[] jArr, int i4, boolean z4) {
        super(z4);
        this.zzb = jArr;
        this.zzc = i4;
    }

    public final void zza(long j4) {
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

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* synthetic */ boolean add(Object obj) {
        zza(((Long) obj).longValue());
        return true;
    }
}
