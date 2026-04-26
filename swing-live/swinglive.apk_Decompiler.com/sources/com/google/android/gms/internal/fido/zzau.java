package com.google.android.gms.internal.fido;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzau extends zzaq implements Set {
    private transient zzat zza;

    public static int zzf(int i4) {
        int iMax = Math.max(i4, 2);
        if (iMax >= 751619276) {
            if (iMax < 1073741824) {
                return 1073741824;
            }
            throw new IllegalArgumentException("collection too large");
        }
        int iHighestOneBit = Integer.highestOneBit(iMax - 1);
        do {
            iHighestOneBit += iHighestOneBit;
        } while (((double) iHighestOneBit) * 0.7d < iMax);
        return iHighestOneBit;
    }

    public static zzau zzi(Object obj, Object obj2) {
        return zzk(2, obj, obj2);
    }

    private static zzau zzk(int i4, Object... objArr) {
        if (i4 == 0) {
            return zzax.zza;
        }
        if (i4 == 1) {
            Object obj = objArr[0];
            obj.getClass();
            return new zzay(obj);
        }
        int iZzf = zzf(i4);
        Object[] objArr2 = new Object[iZzf];
        int i5 = iZzf - 1;
        int i6 = 0;
        int i7 = 0;
        for (int i8 = 0; i8 < i4; i8++) {
            Object obj2 = objArr[i8];
            if (obj2 == null) {
                throw new NullPointerException(S.d(i8, "at index "));
            }
            int iHashCode = obj2.hashCode();
            int iZza = zzap.zza(iHashCode);
            while (true) {
                int i9 = iZza & i5;
                Object obj3 = objArr2[i9];
                if (obj3 == null) {
                    objArr[i7] = obj2;
                    objArr2[i9] = obj2;
                    i6 += iHashCode;
                    i7++;
                    break;
                }
                if (!obj3.equals(obj2)) {
                    iZza++;
                }
            }
        }
        Arrays.fill(objArr, i7, i4, (Object) null);
        if (i7 == 1) {
            Object obj4 = objArr[0];
            obj4.getClass();
            return new zzay(obj4);
        }
        if (zzf(i7) < iZzf / 2) {
            return zzk(i7, objArr);
        }
        if (i7 <= 0) {
            objArr = Arrays.copyOf(objArr, i7);
        }
        return new zzax(objArr, i6, objArr2, i5, i7);
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if ((obj instanceof zzau) && zzj() && ((zzau) obj).zzj() && hashCode() != obj.hashCode()) {
            return false;
        }
        if (obj == this) {
            return true;
        }
        if (obj instanceof Set) {
            Set set = (Set) obj;
            try {
                if (size() == set.size()) {
                    return containsAll(set);
                }
            } catch (ClassCastException | NullPointerException unused) {
            }
        }
        return false;
    }

    @Override // java.util.Collection, java.util.Set
    public int hashCode() {
        Iterator it = iterator();
        int iHashCode = 0;
        while (it.hasNext()) {
            Object next = it.next();
            iHashCode += next != null ? next.hashCode() : 0;
        }
        return iHashCode;
    }

    @Override // com.google.android.gms.internal.fido.zzaq, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable
    /* JADX INFO: renamed from: zzd */
    public abstract zzaz iterator();

    public final zzat zzg() {
        zzat zzatVar = this.zza;
        if (zzatVar != null) {
            return zzatVar;
        }
        zzat zzatVarZzh = zzh();
        this.zza = zzatVarZzh;
        return zzatVarZzh;
    }

    public zzat zzh() {
        Object[] array = toArray();
        int i4 = zzat.zzd;
        return zzat.zzg(array, array.length);
    }

    public boolean zzj() {
        return false;
    }
}
