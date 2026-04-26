package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.util.AbstractList;
import java.util.Arrays;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzalb<E> extends zzahg<E> implements RandomAccess {
    private static final zzalb<Object> zza = new zzalb<>(new Object[0], 0, false);
    private E[] zzb;
    private int zzc;

    public zzalb() {
        this(new Object[10], 0, true);
    }

    private final String zzb(int i4) {
        return a.k("Index:", i4, this.zzc, ", Size:");
    }

    private final void zzc(int i4) {
        if (i4 < 0 || i4 >= this.zzc) {
            throw new IndexOutOfBoundsException(zzb(i4));
        }
    }

    public static <E> zzalb<E> zzd() {
        return (zzalb<E>) zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final void add(int i4, E e) {
        int i5;
        zza();
        if (i4 < 0 || i4 > (i5 = this.zzc)) {
            throw new IndexOutOfBoundsException(zzb(i4));
        }
        E[] eArr = this.zzb;
        if (i5 < eArr.length) {
            System.arraycopy(eArr, i4, eArr, i4 + 1, i5 - i4);
        } else {
            E[] eArr2 = (E[]) new Object[a.i(i5, 3, 2, 1)];
            System.arraycopy(eArr, 0, eArr2, 0, i4);
            System.arraycopy(this.zzb, i4, eArr2, i4 + 1, this.zzc - i4);
            this.zzb = eArr2;
        }
        this.zzb[i4] = e;
        this.zzc++;
        ((AbstractList) this).modCount++;
    }

    @Override // java.util.AbstractList, java.util.List
    public final E get(int i4) {
        zzc(i4);
        return this.zzb[i4];
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final E remove(int i4) {
        zza();
        zzc(i4);
        E[] eArr = this.zzb;
        E e = eArr[i4];
        if (i4 < this.zzc - 1) {
            System.arraycopy(eArr, i4 + 1, eArr, i4, (r2 - i4) - 1);
        }
        this.zzc--;
        ((AbstractList) this).modCount++;
        return e;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final E set(int i4, E e) {
        zza();
        zzc(i4);
        E[] eArr = this.zzb;
        E e4 = eArr[i4];
        eArr[i4] = e;
        ((AbstractList) this).modCount++;
        return e4;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajg
    public final /* synthetic */ zzajg zza(int i4) {
        if (i4 >= this.zzc) {
            return new zzalb(Arrays.copyOf(this.zzb, i4), this.zzc, true);
        }
        throw new IllegalArgumentException();
    }

    private zzalb(E[] eArr, int i4, boolean z4) {
        super(z4);
        this.zzb = eArr;
        this.zzc = i4;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean add(E e) {
        zza();
        int i4 = this.zzc;
        E[] eArr = this.zzb;
        if (i4 == eArr.length) {
            this.zzb = (E[]) Arrays.copyOf(eArr, ((i4 * 3) / 2) + 1);
        }
        E[] eArr2 = this.zzb;
        int i5 = this.zzc;
        this.zzc = i5 + 1;
        eArr2[i5] = e;
        ((AbstractList) this).modCount++;
        return true;
    }
}
