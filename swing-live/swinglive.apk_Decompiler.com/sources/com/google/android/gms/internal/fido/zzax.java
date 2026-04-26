package com.google.android.gms.internal.fido;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
final class zzax extends zzau {
    static final zzax zza;
    private static final Object[] zzd;
    final transient Object[] zzb;
    final transient Object[] zzc;
    private final transient int zze;
    private final transient int zzf;
    private final transient int zzg;

    static {
        Object[] objArr = new Object[0];
        zzd = objArr;
        zza = new zzax(objArr, 0, objArr, 0, 0);
    }

    public zzax(Object[] objArr, int i4, Object[] objArr2, int i5, int i6) {
        this.zzb = objArr;
        this.zze = i4;
        this.zzc = objArr2;
        this.zzf = i5;
        this.zzg = i6;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.Set
    public final boolean contains(Object obj) {
        Object[] objArr = this.zzc;
        if (obj == null || objArr.length == 0) {
            return false;
        }
        int iZza = zzap.zza(obj.hashCode());
        while (true) {
            int i4 = iZza & this.zzf;
            Object obj2 = objArr[i4];
            if (obj2 == null) {
                return false;
            }
            if (obj2.equals(obj)) {
                return true;
            }
            iZza = i4 + 1;
        }
    }

    @Override // com.google.android.gms.internal.fido.zzau, java.util.Collection, java.util.Set
    public final int hashCode() {
        return this.zze;
    }

    @Override // com.google.android.gms.internal.fido.zzau, com.google.android.gms.internal.fido.zzaq, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable
    public final /* synthetic */ Iterator iterator() {
        return zzg().listIterator(0);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.Set
    public final int size() {
        return this.zzg;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zza(Object[] objArr, int i4) {
        System.arraycopy(this.zzb, 0, objArr, 0, this.zzg);
        return this.zzg;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zzb() {
        return this.zzg;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zzc() {
        return 0;
    }

    @Override // com.google.android.gms.internal.fido.zzau, com.google.android.gms.internal.fido.zzaq
    /* JADX INFO: renamed from: zzd */
    public final zzaz iterator() {
        return zzg().listIterator(0);
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final Object[] zze() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.fido.zzau
    public final zzat zzh() {
        return zzat.zzg(this.zzb, this.zzg);
    }

    @Override // com.google.android.gms.internal.fido.zzau
    public final boolean zzj() {
        return true;
    }
}
