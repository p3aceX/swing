package com.google.android.gms.internal.auth;

import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
final class zzhg extends zzhi {
    public zzhg(Unsafe unsafe) {
        super(unsafe);
    }

    @Override // com.google.android.gms.internal.auth.zzhi
    public final double zza(Object obj, long j4) {
        return Double.longBitsToDouble(this.zza.getLong(obj, j4));
    }

    @Override // com.google.android.gms.internal.auth.zzhi
    public final float zzb(Object obj, long j4) {
        return Float.intBitsToFloat(this.zza.getInt(obj, j4));
    }

    @Override // com.google.android.gms.internal.auth.zzhi
    public final void zzc(Object obj, long j4, boolean z4) {
        if (zzhj.zza) {
            zzhj.zzi(obj, j4, z4);
        } else {
            zzhj.zzj(obj, j4, z4);
        }
    }

    @Override // com.google.android.gms.internal.auth.zzhi
    public final void zzd(Object obj, long j4, double d5) {
        this.zza.putLong(obj, j4, Double.doubleToLongBits(d5));
    }

    @Override // com.google.android.gms.internal.auth.zzhi
    public final void zze(Object obj, long j4, float f4) {
        this.zza.putInt(obj, j4, Float.floatToIntBits(f4));
    }

    @Override // com.google.android.gms.internal.auth.zzhi
    public final boolean zzf(Object obj, long j4) {
        return zzhj.zza ? zzhj.zzq(obj, j4) : zzhj.zzr(obj, j4);
    }
}
