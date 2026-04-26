package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.common.api.f;
import java.util.AbstractList;
import java.util.Arrays;
import java.util.Collection;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzain extends zzahg<Double> implements zzajg<Double>, zzakw, RandomAccess {
    private static final zzain zza = new zzain(new double[0], 0, false);
    private double[] zzb;
    private int zzc;

    public zzain() {
        this(new double[10], 0, true);
    }

    private final String zzb(int i4) {
        return a.k("Index:", i4, this.zzc, ", Size:");
    }

    private final void zzc(int i4) {
        if (i4 < 0 || i4 >= this.zzc) {
            throw new IndexOutOfBoundsException(zzb(i4));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ void add(int i4, Object obj) {
        int i5;
        double dDoubleValue = ((Double) obj).doubleValue();
        zza();
        if (i4 < 0 || i4 > (i5 = this.zzc)) {
            throw new IndexOutOfBoundsException(zzb(i4));
        }
        double[] dArr = this.zzb;
        if (i5 < dArr.length) {
            System.arraycopy(dArr, i4, dArr, i4 + 1, i5 - i4);
        } else {
            double[] dArr2 = new double[a.i(i5, 3, 2, 1)];
            System.arraycopy(dArr, 0, dArr2, 0, i4);
            System.arraycopy(this.zzb, i4, dArr2, i4 + 1, this.zzc - i4);
            this.zzb = dArr2;
        }
        this.zzb[i4] = dDoubleValue;
        this.zzc++;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection<? extends Double> collection) {
        zza();
        zzajc.zza(collection);
        if (!(collection instanceof zzain)) {
            return super.addAll(collection);
        }
        zzain zzainVar = (zzain) collection;
        int i4 = zzainVar.zzc;
        if (i4 == 0) {
            return false;
        }
        int i5 = this.zzc;
        if (f.API_PRIORITY_OTHER - i5 < i4) {
            throw new OutOfMemoryError();
        }
        int i6 = i5 + i4;
        double[] dArr = this.zzb;
        if (i6 > dArr.length) {
            this.zzb = Arrays.copyOf(dArr, i6);
        }
        System.arraycopy(zzainVar.zzb, 0, this.zzb, this.zzc, zzainVar.zzc);
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
        if (!(obj instanceof zzain)) {
            return super.equals(obj);
        }
        zzain zzainVar = (zzain) obj;
        if (this.zzc != zzainVar.zzc) {
            return false;
        }
        double[] dArr = zzainVar.zzb;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            if (Double.doubleToLongBits(this.zzb[i4]) != Double.doubleToLongBits(dArr[i4])) {
                return false;
            }
        }
        return true;
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* synthetic */ Object get(int i4) {
        zzc(i4);
        return Double.valueOf(this.zzb[i4]);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.Collection, java.util.List
    public final int hashCode() {
        int iZza = 1;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            iZza = (iZza * 31) + zzajc.zza(Double.doubleToLongBits(this.zzb[i4]));
        }
        return iZza;
    }

    @Override // java.util.AbstractList, java.util.List
    public final int indexOf(Object obj) {
        if (!(obj instanceof Double)) {
            return -1;
        }
        double dDoubleValue = ((Double) obj).doubleValue();
        int size = size();
        for (int i4 = 0; i4 < size; i4++) {
            if (this.zzb[i4] == dDoubleValue) {
                return i4;
            }
        }
        return -1;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object remove(int i4) {
        zza();
        zzc(i4);
        double[] dArr = this.zzb;
        double d5 = dArr[i4];
        if (i4 < this.zzc - 1) {
            System.arraycopy(dArr, i4 + 1, dArr, i4, (r3 - i4) - 1);
        }
        this.zzc--;
        ((AbstractList) this).modCount++;
        return Double.valueOf(d5);
    }

    @Override // java.util.AbstractList
    public final void removeRange(int i4, int i5) {
        zza();
        if (i5 < i4) {
            throw new IndexOutOfBoundsException("toIndex < fromIndex");
        }
        double[] dArr = this.zzb;
        System.arraycopy(dArr, i5, dArr, i4, this.zzc - i5);
        this.zzc -= i5 - i4;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object set(int i4, Object obj) {
        double dDoubleValue = ((Double) obj).doubleValue();
        zza();
        zzc(i4);
        double[] dArr = this.zzb;
        double d5 = dArr[i4];
        dArr[i4] = dDoubleValue;
        return Double.valueOf(d5);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajg
    public final /* synthetic */ zzajg<Double> zza(int i4) {
        if (i4 >= this.zzc) {
            return new zzain(Arrays.copyOf(this.zzb, i4), this.zzc, true);
        }
        throw new IllegalArgumentException();
    }

    private zzain(double[] dArr, int i4, boolean z4) {
        super(z4);
        this.zzb = dArr;
        this.zzc = i4;
    }

    public final void zza(double d5) {
        zza();
        int i4 = this.zzc;
        double[] dArr = this.zzb;
        if (i4 == dArr.length) {
            double[] dArr2 = new double[a.i(i4, 3, 2, 1)];
            System.arraycopy(dArr, 0, dArr2, 0, i4);
            this.zzb = dArr2;
        }
        double[] dArr3 = this.zzb;
        int i5 = this.zzc;
        this.zzc = i5 + 1;
        dArr3[i5] = d5;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* synthetic */ boolean add(Object obj) {
        zza(((Double) obj).doubleValue());
        return true;
    }
}
