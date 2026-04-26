package com.google.android.gms.internal.p002firebaseauthapi;

import java.lang.Comparable;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

/* JADX INFO: loaded from: classes.dex */
class zzalh<K extends Comparable<K>, V> extends AbstractMap<K, V> {
    private final int zza;
    private List<zzalo> zzb;
    private Map<K, V> zzc;
    private boolean zzd;
    private volatile zzalt zze;
    private Map<K, V> zzf;
    private volatile zzall zzg;

    private final SortedMap<K, V> zzf() {
        zzg();
        if (this.zzc.isEmpty() && !(this.zzc instanceof TreeMap)) {
            TreeMap treeMap = new TreeMap();
            this.zzc = treeMap;
            this.zzf = treeMap.descendingMap();
        }
        return (SortedMap) this.zzc;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzg() {
        if (this.zzd) {
            throw new UnsupportedOperationException();
        }
    }

    @Override // java.util.AbstractMap, java.util.Map
    public void clear() {
        zzg();
        if (!this.zzb.isEmpty()) {
            this.zzb.clear();
        }
        if (this.zzc.isEmpty()) {
            return;
        }
        this.zzc.clear();
    }

    @Override // java.util.AbstractMap, java.util.Map
    public boolean containsKey(Object obj) {
        Comparable comparable = (Comparable) obj;
        return zza(comparable) >= 0 || this.zzc.containsKey(comparable);
    }

    @Override // java.util.AbstractMap, java.util.Map
    public Set<Map.Entry<K, V>> entrySet() {
        if (this.zze == null) {
            this.zze = new zzalt(this);
        }
        return this.zze;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof zzalh)) {
            return super.equals(obj);
        }
        zzalh zzalhVar = (zzalh) obj;
        int size = size();
        if (size != zzalhVar.size()) {
            return false;
        }
        int iZzb = zzb();
        if (iZzb != zzalhVar.zzb()) {
            return entrySet().equals(zzalhVar.entrySet());
        }
        for (int i4 = 0; i4 < iZzb; i4++) {
            if (!zzb(i4).equals(zzalhVar.zzb(i4))) {
                return false;
            }
        }
        if (iZzb != size) {
            return this.zzc.equals(zzalhVar.zzc);
        }
        return true;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public V get(Object obj) {
        Comparable comparable = (Comparable) obj;
        int iZza = zza(comparable);
        return iZza >= 0 ? (V) this.zzb.get(iZza).getValue() : this.zzc.get(comparable);
    }

    @Override // java.util.AbstractMap, java.util.Map
    public int hashCode() {
        int iZzb = zzb();
        int iHashCode = 0;
        for (int i4 = 0; i4 < iZzb; i4++) {
            iHashCode += this.zzb.get(i4).hashCode();
        }
        return this.zzc.size() > 0 ? this.zzc.hashCode() + iHashCode : iHashCode;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public V remove(Object obj) {
        zzg();
        Comparable comparable = (Comparable) obj;
        int iZza = zza(comparable);
        if (iZza >= 0) {
            return zzc(iZza);
        }
        if (this.zzc.isEmpty()) {
            return null;
        }
        return this.zzc.remove(comparable);
    }

    @Override // java.util.AbstractMap, java.util.Map
    public int size() {
        return this.zzc.size() + this.zzb.size();
    }

    public final boolean zze() {
        return this.zzd;
    }

    private zzalh(int i4) {
        this.zza = i4;
        this.zzb = Collections.EMPTY_LIST;
        Map<K, V> map = Collections.EMPTY_MAP;
        this.zzc = map;
        this.zzf = map;
    }

    public final int zzb() {
        return this.zzb.size();
    }

    public final Iterable<Map.Entry<K, V>> zzc() {
        return this.zzc.isEmpty() ? zzaln.zza() : this.zzc.entrySet();
    }

    public final Set<Map.Entry<K, V>> zzd() {
        if (this.zzg == null) {
            this.zzg = new zzall(this);
        }
        return this.zzg;
    }

    /* JADX WARN: Removed duplicated region for block: B:13:0x0028  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private final int zza(K r5) {
        /*
            r4 = this;
            java.util.List<com.google.android.gms.internal.firebase-auth-api.zzalo> r0 = r4.zzb
            int r0 = r0.size()
            int r1 = r0 + (-1)
            if (r1 < 0) goto L25
            java.util.List<com.google.android.gms.internal.firebase-auth-api.zzalo> r2 = r4.zzb
            java.lang.Object r2 = r2.get(r1)
            com.google.android.gms.internal.firebase-auth-api.zzalo r2 = (com.google.android.gms.internal.p002firebaseauthapi.zzalo) r2
            java.lang.Object r2 = r2.getKey()
            java.lang.Comparable r2 = (java.lang.Comparable) r2
            int r2 = r5.compareTo(r2)
            if (r2 <= 0) goto L22
            int r0 = r0 + 1
        L20:
            int r5 = -r0
            return r5
        L22:
            if (r2 != 0) goto L25
            return r1
        L25:
            r0 = 0
        L26:
            if (r0 > r1) goto L49
            int r2 = r0 + r1
            int r2 = r2 / 2
            java.util.List<com.google.android.gms.internal.firebase-auth-api.zzalo> r3 = r4.zzb
            java.lang.Object r3 = r3.get(r2)
            com.google.android.gms.internal.firebase-auth-api.zzalo r3 = (com.google.android.gms.internal.p002firebaseauthapi.zzalo) r3
            java.lang.Object r3 = r3.getKey()
            java.lang.Comparable r3 = (java.lang.Comparable) r3
            int r3 = r5.compareTo(r3)
            if (r3 >= 0) goto L43
            int r1 = r2 + (-1)
            goto L26
        L43:
            if (r3 <= 0) goto L48
            int r0 = r2 + 1
            goto L26
        L48:
            return r2
        L49:
            int r0 = r0 + 1
            goto L20
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzalh.zza(java.lang.Comparable):int");
    }

    public final Map.Entry<K, V> zzb(int i4) {
        return this.zzb.get(i4);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final V zzc(int i4) {
        zzg();
        V v = (V) this.zzb.remove(i4).getValue();
        if (!this.zzc.isEmpty()) {
            Iterator<Map.Entry<K, V>> it = zzf().entrySet().iterator();
            this.zzb.add(new zzalo(this, it.next()));
            it.remove();
        }
        return v;
    }

    public static <FieldDescriptorType extends zzaiu<FieldDescriptorType>> zzalh<FieldDescriptorType, Object> zza(int i4) {
        return new zzalg(i4);
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // java.util.AbstractMap, java.util.Map
    /* JADX INFO: renamed from: zza, reason: merged with bridge method [inline-methods] */
    public final V put(K k4, V v) {
        zzg();
        int iZza = zza(k4);
        if (iZza >= 0) {
            return (V) this.zzb.get(iZza).setValue(v);
        }
        zzg();
        if (this.zzb.isEmpty() && !(this.zzb instanceof ArrayList)) {
            this.zzb = new ArrayList(this.zza);
        }
        int i4 = -(iZza + 1);
        if (i4 >= this.zza) {
            return zzf().put(k4, v);
        }
        int size = this.zzb.size();
        int i5 = this.zza;
        if (size == i5) {
            zzalo zzaloVarRemove = this.zzb.remove(i5 - 1);
            zzf().put((Comparable) zzaloVarRemove.getKey(), zzaloVarRemove.getValue());
        }
        this.zzb.add(i4, new zzalo(this, k4, v));
        return null;
    }

    public void zza() {
        Map<K, V> mapUnmodifiableMap;
        Map<K, V> mapUnmodifiableMap2;
        if (this.zzd) {
            return;
        }
        if (this.zzc.isEmpty()) {
            mapUnmodifiableMap = Collections.EMPTY_MAP;
        } else {
            mapUnmodifiableMap = Collections.unmodifiableMap(this.zzc);
        }
        this.zzc = mapUnmodifiableMap;
        if (this.zzf.isEmpty()) {
            mapUnmodifiableMap2 = Collections.EMPTY_MAP;
        } else {
            mapUnmodifiableMap2 = Collections.unmodifiableMap(this.zzf);
        }
        this.zzf = mapUnmodifiableMap2;
        this.zzd = true;
    }
}
