package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzba<K, V> extends zzav<Map.Entry<K, V>> {
    private final transient zzau<K, V> zza;
    private final transient Object[] zzb;
    private final transient int zzc = 0;
    private final transient int zzd;

    public zzba(zzau<K, V> zzauVar, Object[] objArr, int i4, int i5) {
        this.zza = zzauVar;
        this.zzb = objArr;
        this.zzd = i5;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal, java.util.AbstractCollection, java.util.Collection
    public final boolean contains(Object obj) {
        if (obj instanceof Map.Entry) {
            Map.Entry entry = (Map.Entry) obj;
            Object key = entry.getKey();
            Object value = entry.getValue();
            if (value != null && value.equals(this.zza.get(key))) {
                return true;
            }
        }
        return false;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.Set
    public final int size() {
        return this.zzd;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzav, com.google.android.gms.internal.p002firebaseauthapi.zzal, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable
    /* JADX INFO: renamed from: zzd */
    public final zzbd<Map.Entry<K, V>> iterator() {
        return (zzbd) zzc().iterator();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal
    public final boolean zze() {
        return true;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzav
    public final zzaq<Map.Entry<K, V>> zzg() {
        return new zzaz(this);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzal
    public final int zza(Object[] objArr, int i4) {
        return zzc().zza(objArr, i4);
    }
}
