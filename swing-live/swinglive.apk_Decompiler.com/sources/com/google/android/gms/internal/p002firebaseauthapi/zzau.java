package com.google.android.gms.internal.p002firebaseauthapi;

import java.io.Serializable;
import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzau<K, V> implements Serializable, Map<K, V> {
    private static final Map.Entry<?, ?>[] zza = new Map.Entry[0];
    private transient zzav<Map.Entry<K, V>> zzb;
    private transient zzav<K> zzc;
    private transient zzal<V> zzd;

    public static <K, V> zzau<K, V> zza(Map<? extends K, ? extends V> map) {
        if ((map instanceof zzau) && !(map instanceof SortedMap)) {
            zzau<K, V> zzauVar = (zzau) map;
            zzauVar.zzd();
            return zzauVar;
        }
        Set<Map.Entry<? extends K, ? extends V>> setEntrySet = map.entrySet();
        zzat zzatVar = new zzat(setEntrySet != null ? setEntrySet.size() : 4);
        zzatVar.zza(setEntrySet);
        return zzatVar.zza();
    }

    @Override // java.util.Map
    @Deprecated
    public final void clear() {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.Map
    public boolean containsKey(Object obj) {
        return get(obj) != null;
    }

    @Override // java.util.Map
    public boolean containsValue(Object obj) {
        return ((zzal) values()).contains(obj);
    }

    @Override // java.util.Map
    public /* synthetic */ Set entrySet() {
        zzav<Map.Entry<K, V>> zzavVar = this.zzb;
        if (zzavVar != null) {
            return zzavVar;
        }
        zzav<Map.Entry<K, V>> zzavVarZzb = zzb();
        this.zzb = zzavVarZzb;
        return zzavVarZzb;
    }

    @Override // java.util.Map
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof Map) {
            return entrySet().equals(((Map) obj).entrySet());
        }
        return false;
    }

    @Override // java.util.Map
    public abstract V get(Object obj);

    @Override // java.util.Map
    public final V getOrDefault(Object obj, V v) {
        V v4 = get(obj);
        return v4 != null ? v4 : v;
    }

    @Override // java.util.Map
    public int hashCode() {
        return zzbe.zza((zzav) entrySet());
    }

    @Override // java.util.Map
    public boolean isEmpty() {
        return size() == 0;
    }

    @Override // java.util.Map
    public /* synthetic */ Set keySet() {
        zzav<K> zzavVar = this.zzc;
        if (zzavVar != null) {
            return zzavVar;
        }
        zzav<K> zzavVarZzc = zzc();
        this.zzc = zzavVarZzc;
        return zzavVarZzc;
    }

    @Override // java.util.Map
    @Deprecated
    public final V put(K k4, V v) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.Map
    @Deprecated
    public final void putAll(Map<? extends K, ? extends V> map) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.Map
    @Deprecated
    public final V remove(Object obj) {
        throw new UnsupportedOperationException();
    }

    public String toString() {
        int size = size();
        zzaj.zza(size, "size");
        StringBuilder sb = new StringBuilder((int) Math.min(((long) size) << 3, 1073741824L));
        sb.append('{');
        boolean z4 = true;
        for (Map.Entry<K, V> entry : entrySet()) {
            if (!z4) {
                sb.append(", ");
            }
            sb.append(entry.getKey());
            sb.append('=');
            sb.append(entry.getValue());
            z4 = false;
        }
        sb.append('}');
        return sb.toString();
    }

    @Override // java.util.Map
    public /* synthetic */ Collection values() {
        zzal<V> zzalVar = this.zzd;
        if (zzalVar != null) {
            return zzalVar;
        }
        zzal<V> zzalVarZza = zza();
        this.zzd = zzalVarZza;
        return zzalVarZza;
    }

    public abstract zzal<V> zza();

    public abstract zzav<Map.Entry<K, V>> zzb();

    public abstract zzav<K> zzc();

    public abstract boolean zzd();
}
