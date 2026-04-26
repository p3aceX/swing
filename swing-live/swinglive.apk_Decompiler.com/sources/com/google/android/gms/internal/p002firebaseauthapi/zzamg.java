package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.AbstractList;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public final class zzamg extends AbstractList<String> implements zzajq, RandomAccess {
    private final zzajq zza;

    public zzamg(zzajq zzajqVar) {
        this.zza = zzajqVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final zzajq a_() {
        return this;
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* synthetic */ Object get(int i4) {
        return (String) this.zza.get(i4);
    }

    @Override // java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable, java.util.List
    public final Iterator<String> iterator() {
        return new zzami(this);
    }

    @Override // java.util.AbstractList, java.util.List
    public final ListIterator<String> listIterator(int i4) {
        return new zzamf(this, i4);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zza.size();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final Object zzb(int i4) {
        return this.zza.zzb(i4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final void zza(zzahm zzahmVar) {
        throw new UnsupportedOperationException();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajq
    public final List<?> zzb() {
        return this.zza.zzb();
    }
}
