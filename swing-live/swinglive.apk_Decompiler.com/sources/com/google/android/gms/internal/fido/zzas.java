package com.google.android.gms.internal.fido;

/* JADX INFO: loaded from: classes.dex */
final class zzas extends zzat {
    final transient int zza;
    final transient int zzb;
    final /* synthetic */ zzat zzc;

    public zzas(zzat zzatVar, int i4, int i5) {
        this.zzc = zzatVar;
        this.zza = i4;
        this.zzb = i5;
    }

    @Override // java.util.List
    public final Object get(int i4) {
        zzam.zza(i4, this.zzb, "index");
        return this.zzc.get(i4 + this.zza);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zzb() {
        return this.zzc.zzc() + this.zza + this.zzb;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final int zzc() {
        return this.zzc.zzc() + this.zza;
    }

    @Override // com.google.android.gms.internal.fido.zzaq
    public final Object[] zze() {
        return this.zzc.zze();
    }

    @Override // com.google.android.gms.internal.fido.zzat, java.util.List
    /* JADX INFO: renamed from: zzf, reason: merged with bridge method [inline-methods] */
    public final zzat subList(int i4, int i5) {
        zzam.zze(i4, i5, this.zzb);
        zzat zzatVar = this.zzc;
        int i6 = this.zza;
        return zzatVar.subList(i4 + i6, i5 + i6);
    }
}
