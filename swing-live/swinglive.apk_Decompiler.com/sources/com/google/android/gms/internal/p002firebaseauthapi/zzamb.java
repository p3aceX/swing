package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
abstract class zzamb<T, B> {
    public abstract int zza(T t4);

    public abstract B zza();

    public abstract T zza(T t4, T t5);

    public abstract void zza(B b5, int i4, int i5);

    public abstract void zza(B b5, int i4, long j4);

    public abstract void zza(B b5, int i4, zzahm zzahmVar);

    public abstract void zza(B b5, int i4, T t4);

    public abstract void zza(T t4, zzanb zzanbVar);

    public abstract boolean zza(zzald zzaldVar);

    public final boolean zza(B b5, zzald zzaldVar) throws zzajj {
        int iZzd = zzaldVar.zzd();
        int i4 = iZzd >>> 3;
        int i5 = iZzd & 7;
        if (i5 == 0) {
            zzb(b5, i4, zzaldVar.zzl());
            return true;
        }
        if (i5 == 1) {
            zza(b5, i4, zzaldVar.zzk());
            return true;
        }
        if (i5 == 2) {
            zza((Object) b5, i4, zzaldVar.zzp());
            return true;
        }
        if (i5 != 3) {
            if (i5 == 4) {
                return false;
            }
            if (i5 != 5) {
                throw zzajj.zza();
            }
            zza((Object) b5, i4, zzaldVar.zzf());
            return true;
        }
        B bZza = zza();
        int i6 = 4 | (i4 << 3);
        while (zzaldVar.zzc() != Integer.MAX_VALUE && zza((Object) bZza, zzaldVar)) {
        }
        if (i6 != zzaldVar.zzd()) {
            throw zzajj.zzb();
        }
        zza(b5, i4, zze(bZza));
        return true;
    }

    public abstract int zzb(T t4);

    public abstract void zzb(B b5, int i4, long j4);

    public abstract void zzb(T t4, zzanb zzanbVar);

    public abstract void zzb(Object obj, B b5);

    public abstract B zzc(Object obj);

    public abstract void zzc(Object obj, T t4);

    public abstract T zzd(Object obj);

    public abstract T zze(B b5);

    public abstract void zzf(Object obj);
}
