package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
final class zzbb extends zzaq<Object> {
    private final transient Object[] zza;
    private final transient int zzb;
    private final transient int zzc;

    public zzbb(Object[] objArr, int i4, int i5) {
        this.zza = objArr;
        this.zzb = i4;
        this.zzc = i5;
    }

    @Override // java.util.List
    public final Object get(int i4) {
        zzz.zza(i4, this.zzc);
        Object obj = this.zza[(i4 * 2) + this.zzb];
        Objects.requireNonNull(obj);
        return obj;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal
    public final boolean zze() {
        return true;
    }
}
