package com.google.android.gms.internal.fido;

/* JADX INFO: loaded from: classes.dex */
final class zzaw extends zzat {
    static final zzat zza = new zzaw(new Object[0], 0);
    final transient Object[] zzb;
    private final transient int zzc;

    public zzaw(Object[] objArr, int i4) {
        this.zzb = objArr;
        this.zzc = i4;
    }

    @Override // java.util.List
    public final Object get(int i4) {
        zzam.zza(i4, this.zzc, "index");
        Object obj = this.zzb[i4];
        obj.getClass();
        return obj;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.fido.zzat, com.google.android.gms.internal.fido.zzaq
    public final int zza(Object[] objArr, int i4) {
        System.arraycopy(this.zzb, 0, objArr, 0, this.zzc);
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zzb() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zzc() {
        return 0;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final Object[] zze() {
        return this.zzb;
    }
}
