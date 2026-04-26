package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.common.api.f;
import java.util.AbstractList;
import java.util.Arrays;
import java.util.Collection;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzaiy extends zzahg<Float> implements zzajg<Float>, zzakw, RandomAccess {
    private static final zzaiy zza = new zzaiy(new float[0], 0, false);
    private float[] zzb;
    private int zzc;

    public zzaiy() {
        this(new float[10], 0, true);
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
        float fFloatValue = ((Float) obj).floatValue();
        zza();
        if (i4 < 0 || i4 > (i5 = this.zzc)) {
            throw new IndexOutOfBoundsException(zzb(i4));
        }
        float[] fArr = this.zzb;
        if (i5 < fArr.length) {
            System.arraycopy(fArr, i4, fArr, i4 + 1, i5 - i4);
        } else {
            float[] fArr2 = new float[a.i(i5, 3, 2, 1)];
            System.arraycopy(fArr, 0, fArr2, 0, i4);
            System.arraycopy(this.zzb, i4, fArr2, i4 + 1, this.zzc - i4);
            this.zzb = fArr2;
        }
        this.zzb[i4] = fFloatValue;
        this.zzc++;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection<? extends Float> collection) {
        zza();
        zzajc.zza(collection);
        if (!(collection instanceof zzaiy)) {
            return super.addAll(collection);
        }
        zzaiy zzaiyVar = (zzaiy) collection;
        int i4 = zzaiyVar.zzc;
        if (i4 == 0) {
            return false;
        }
        int i5 = this.zzc;
        if (f.API_PRIORITY_OTHER - i5 < i4) {
            throw new OutOfMemoryError();
        }
        int i6 = i5 + i4;
        float[] fArr = this.zzb;
        if (i6 > fArr.length) {
            this.zzb = Arrays.copyOf(fArr, i6);
        }
        System.arraycopy(zzaiyVar.zzb, 0, this.zzb, this.zzc, zzaiyVar.zzc);
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
        if (!(obj instanceof zzaiy)) {
            return super.equals(obj);
        }
        zzaiy zzaiyVar = (zzaiy) obj;
        if (this.zzc != zzaiyVar.zzc) {
            return false;
        }
        float[] fArr = zzaiyVar.zzb;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            if (Float.floatToIntBits(this.zzb[i4]) != Float.floatToIntBits(fArr[i4])) {
                return false;
            }
        }
        return true;
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* synthetic */ Object get(int i4) {
        zzc(i4);
        return Float.valueOf(this.zzb[i4]);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.Collection, java.util.List
    public final int hashCode() {
        int iFloatToIntBits = 1;
        for (int i4 = 0; i4 < this.zzc; i4++) {
            iFloatToIntBits = (iFloatToIntBits * 31) + Float.floatToIntBits(this.zzb[i4]);
        }
        return iFloatToIntBits;
    }

    @Override // java.util.AbstractList, java.util.List
    public final int indexOf(Object obj) {
        if (!(obj instanceof Float)) {
            return -1;
        }
        float fFloatValue = ((Float) obj).floatValue();
        int size = size();
        for (int i4 = 0; i4 < size; i4++) {
            if (this.zzb[i4] == fFloatValue) {
                return i4;
            }
        }
        return -1;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object remove(int i4) {
        zza();
        zzc(i4);
        float[] fArr = this.zzb;
        float f4 = fArr[i4];
        if (i4 < this.zzc - 1) {
            System.arraycopy(fArr, i4 + 1, fArr, i4, (r2 - i4) - 1);
        }
        this.zzc--;
        ((AbstractList) this).modCount++;
        return Float.valueOf(f4);
    }

    @Override // java.util.AbstractList
    public final void removeRange(int i4, int i5) {
        zza();
        if (i5 < i4) {
            throw new IndexOutOfBoundsException("toIndex < fromIndex");
        }
        float[] fArr = this.zzb;
        System.arraycopy(fArr, i5, fArr, i4, this.zzc - i5);
        this.zzc -= i5 - i4;
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object set(int i4, Object obj) {
        float fFloatValue = ((Float) obj).floatValue();
        zza();
        zzc(i4);
        float[] fArr = this.zzb;
        float f4 = fArr[i4];
        fArr[i4] = fFloatValue;
        return Float.valueOf(f4);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajg
    public final /* synthetic */ zzajg<Float> zza(int i4) {
        if (i4 >= this.zzc) {
            return new zzaiy(Arrays.copyOf(this.zzb, i4), this.zzc, true);
        }
        throw new IllegalArgumentException();
    }

    private zzaiy(float[] fArr, int i4, boolean z4) {
        super(z4);
        this.zzb = fArr;
        this.zzc = i4;
    }

    public final void zza(float f4) {
        zza();
        int i4 = this.zzc;
        float[] fArr = this.zzb;
        if (i4 == fArr.length) {
            float[] fArr2 = new float[a.i(i4, 3, 2, 1)];
            System.arraycopy(fArr, 0, fArr2, 0, i4);
            this.zzb = fArr2;
        }
        float[] fArr3 = this.zzb;
        int i5 = this.zzc;
        this.zzc = i5 + 1;
        fArr3[i5] = f4;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* synthetic */ boolean add(Object obj) {
        zza(((Float) obj).floatValue());
        return true;
    }
}
