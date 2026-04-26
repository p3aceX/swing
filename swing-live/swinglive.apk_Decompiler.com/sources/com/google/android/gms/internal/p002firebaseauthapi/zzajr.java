package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public final class zzajr extends zzahg<String> implements zzajq, RandomAccess {
    private static final zzajr zza;

    @Deprecated
    private static final zzajq zzb;
    private final List<Object> zzc;

    static {
        zzajr zzajrVar = new zzajr(false);
        zza = zzajrVar;
        zzb = zzajrVar;
    }

    public zzajr() {
        this(10);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final zzajq a_() {
        return zzc() ? new zzamg(this) : this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ void add(int i4, Object obj) {
        zza();
        this.zzc.add(i4, (String) obj);
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection<? extends String> collection) {
        return addAll(size(), collection);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final void clear() {
        zza();
        this.zzc.clear();
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ boolean equals(Object obj) {
        return super.equals(obj);
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* synthetic */ Object get(int i4) {
        Object obj = this.zzc.get(i4);
        if (obj instanceof String) {
            return (String) obj;
        }
        if (obj instanceof zzahm) {
            zzahm zzahmVar = (zzahm) obj;
            String strZzd = zzahmVar.zzd();
            if (zzahmVar.zzf()) {
                this.zzc.set(i4, strZzd);
            }
            return strZzd;
        }
        byte[] bArr = (byte[]) obj;
        String strZzb = zzajc.zzb(bArr);
        if (zzajc.zzc(bArr)) {
            this.zzc.set(i4, strZzb);
        }
        return strZzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ int hashCode() {
        return super.hashCode();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object remove(int i4) {
        zza();
        Object objRemove = this.zzc.remove(i4);
        ((AbstractList) this).modCount++;
        return zza(objRemove);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ boolean removeAll(Collection collection) {
        return super.removeAll(collection);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ boolean retainAll(Collection collection) {
        return super.retainAll(collection);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final /* synthetic */ Object set(int i4, Object obj) {
        zza();
        return zza(this.zzc.set(i4, (String) obj));
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc.size();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajg
    public final /* synthetic */ zzajg zza(int i4) {
        if (i4 < size()) {
            throw new IllegalArgumentException();
        }
        ArrayList arrayList = new ArrayList(i4);
        arrayList.addAll(this.zzc);
        return new zzajr((ArrayList<Object>) arrayList);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final Object zzb(int i4) {
        return this.zzc.get(i4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, com.google.android.gms.internal.p002firebaseauthapi.zzajg
    public final /* bridge */ /* synthetic */ boolean zzc() {
        return super.zzc();
    }

    public zzajr(int i4) {
        this((ArrayList<Object>) new ArrayList(i4));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.List
    public final boolean addAll(int i4, Collection<? extends String> collection) {
        zza();
        if (collection instanceof zzajq) {
            collection = ((zzajq) collection).zzb();
        }
        boolean zAddAll = this.zzc.addAll(i4, collection);
        ((AbstractList) this).modCount++;
        return zAddAll;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final List<?> zzb() {
        return Collections.unmodifiableList(this.zzc);
    }

    private zzajr(ArrayList<Object> arrayList) {
        this.zzc = arrayList;
    }

    private zzajr(boolean z4) {
        super(false);
        this.zzc = Collections.EMPTY_LIST;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ boolean add(Object obj) {
        return super.add(obj);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahg, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final /* bridge */ /* synthetic */ boolean remove(Object obj) {
        return super.remove(obj);
    }

    private static String zza(Object obj) {
        if (obj instanceof String) {
            return (String) obj;
        }
        if (obj instanceof zzahm) {
            return ((zzahm) obj).zzd();
        }
        return zzajc.zzb((byte[]) obj);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final void zza(zzahm zzahmVar) {
        zza();
        this.zzc.add(zzahmVar);
        ((AbstractList) this).modCount++;
    }
}
