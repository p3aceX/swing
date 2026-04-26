package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
abstract class zzll {
    public abstract int zza(Object obj);

    public abstract int zzb(Object obj);

    public abstract Object zzc(Object obj);

    public abstract Object zzd(Object obj);

    public abstract Object zze(Object obj, Object obj2);

    public abstract Object zzf();

    public abstract Object zzg(Object obj);

    public abstract void zzh(Object obj, int i4, int i5);

    public abstract void zzi(Object obj, int i4, long j4);

    public abstract void zzj(Object obj, int i4, Object obj2);

    public abstract void zzk(Object obj, int i4, zzgw zzgwVar);

    public abstract void zzl(Object obj, int i4, long j4);

    public abstract void zzm(Object obj);

    public abstract void zzn(Object obj, Object obj2);

    public abstract void zzo(Object obj, Object obj2);

    public abstract void zzp(Object obj, zzmd zzmdVar);

    public abstract void zzq(Object obj, zzmd zzmdVar);

    public final boolean zzr(Object obj, zzkq zzkqVar) throws zzje {
        int iZzd = zzkqVar.zzd();
        int i4 = iZzd >>> 3;
        int i5 = iZzd & 7;
        if (i5 == 0) {
            zzl(obj, i4, zzkqVar.zzl());
            return true;
        }
        if (i5 == 1) {
            zzi(obj, i4, zzkqVar.zzk());
            return true;
        }
        if (i5 == 2) {
            zzk(obj, i4, zzkqVar.zzp());
            return true;
        }
        if (i5 != 3) {
            if (i5 == 4) {
                return false;
            }
            if (i5 != 5) {
                throw zzje.zza();
            }
            zzh(obj, i4, zzkqVar.zzf());
            return true;
        }
        Object objZzf = zzf();
        int i6 = i4 << 3;
        while (zzkqVar.zzc() != Integer.MAX_VALUE && zzr(objZzf, zzkqVar)) {
        }
        if ((4 | i6) != zzkqVar.zzd()) {
            throw zzje.zzb();
        }
        zzg(objZzf);
        zzj(obj, i4, objZzf);
        return true;
    }

    public abstract boolean zzs(zzkq zzkqVar);
}
