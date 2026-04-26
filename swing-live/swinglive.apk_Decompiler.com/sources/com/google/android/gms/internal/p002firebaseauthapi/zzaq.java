package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzaq<E> extends zzal<E> implements List<E>, RandomAccess {
    private static final zzbg<Object> zza = new zzas(zzay.zza, 0);

    public static <E> zzaq<E> zzb(Object[] objArr, int i4) {
        return i4 == 0 ? (zzaq<E>) zzay.zza : new zzay(objArr, i4);
    }

    public static <E> zzap<E> zzg() {
        return new zzap<>();
    }

    public static <E> zzaq<E> zzh() {
        return (zzaq<E>) zzay.zza;
    }

    @Override // java.util.List
    @Deprecated
    public final void add(int i4, E e) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.List
    @Deprecated
    public final boolean addAll(int i4, Collection<? extends E> collection) {
        throw new UnsupportedOperationException();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal, java.util.AbstractCollection, java.util.Collection
    public boolean contains(Object obj) {
        return indexOf(obj) >= 0;
    }

    @Override // java.util.Collection, java.util.List
    public boolean equals(Object obj) {
        if (obj == zzz.zza(this)) {
            return true;
        }
        if (obj instanceof List) {
            List list = (List) obj;
            int size = size();
            if (size == list.size()) {
                if (list instanceof RandomAccess) {
                    for (int i4 = 0; i4 < size; i4++) {
                        if (zzw.zza(get(i4), list.get(i4))) {
                        }
                    }
                    return true;
                }
                int size2 = size();
                Iterator<E> it = list.iterator();
                int i5 = 0;
                while (true) {
                    if (i5 < size2) {
                        if (!it.hasNext()) {
                            break;
                        }
                        E e = get(i5);
                        i5++;
                        if (!zzw.zza(e, it.next())) {
                            break;
                        }
                    } else if (!it.hasNext()) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    @Override // java.util.Collection, java.util.List
    public int hashCode() {
        int size = size();
        int i4 = 1;
        for (int i5 = 0; i5 < size; i5++) {
            i4 = ~(~(get(i5).hashCode() + (i4 * 31)));
        }
        return i4;
    }

    @Override // java.util.List
    public int indexOf(Object obj) {
        if (obj == null) {
            return -1;
        }
        int size = size();
        for (int i4 = 0; i4 < size; i4++) {
            if (obj.equals(get(i4))) {
                return i4;
            }
        }
        return -1;
    }

    @Override // java.util.List
    public int lastIndexOf(Object obj) {
        if (obj == null) {
            return -1;
        }
        for (int size = size() - 1; size >= 0; size--) {
            if (obj.equals(get(size))) {
                return size;
            }
        }
        return -1;
    }

    @Override // java.util.List
    public /* synthetic */ ListIterator listIterator() {
        return (zzbg) listIterator(0);
    }

    @Override // java.util.List
    @Deprecated
    public final E remove(int i4) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.List
    @Deprecated
    public final E set(int i4, E e) {
        throw new UnsupportedOperationException();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal
    public int zza(Object[] objArr, int i4) {
        int size = size();
        for (int i5 = 0; i5 < size; i5++) {
            objArr[i4 + i5] = get(i5);
        }
        return i4 + size;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal
    @Deprecated
    public final zzaq<E> zzc() {
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable
    /* JADX INFO: renamed from: zzd, reason: merged with bridge method [inline-methods] */
    public final zzbd<E> iterator() {
        return (zzbg) listIterator();
    }

    @Override // java.util.List
    public /* synthetic */ ListIterator listIterator(int i4) {
        zzz.zzb(i4, size());
        return isEmpty() ? zza : new zzas(this, i4);
    }

    public static <E> zzaq<E> zza(Object[] objArr) {
        return zzb(objArr, objArr.length);
    }

    private static <E> zzaq<E> zzb(Object... objArr) {
        int length = objArr.length;
        for (int i4 = 0; i4 < length; i4++) {
            if (objArr[i4] == null) {
                throw new NullPointerException(S.d(i4, "at index "));
            }
        }
        return zzb(objArr, objArr.length);
    }

    public static <E> zzaq<E> zza(Collection<? extends E> collection) {
        if (collection instanceof zzal) {
            zzaq<E> zzaqVarZzc = ((zzal) collection).zzc();
            if (!zzaqVarZzc.zze()) {
                return zzaqVarZzc;
            }
            Object[] array = zzaqVarZzc.toArray();
            return zzb(array, array.length);
        }
        return zzb(collection.toArray());
    }

    public static <E> zzaq<E> zza(E e, E e4, E e5, E e6, E e7, E e8, E e9, E e10) {
        return zzb(e, e4, e5, e6, e7, e8, e9, e10);
    }

    @Override // java.util.List
    /* JADX INFO: renamed from: zza, reason: merged with bridge method [inline-methods] */
    public zzaq<E> subList(int i4, int i5) {
        zzz.zza(i4, i5, size());
        int i6 = i5 - i4;
        if (i6 == size()) {
            return this;
        }
        if (i6 == 0) {
            return (zzaq<E>) zzay.zza;
        }
        return new zzar(this, i4, i6);
    }
}
