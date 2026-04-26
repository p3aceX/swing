package com.google.android.recaptcha.internal;

import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
final class zzls extends zzlu {
    public zzls(Unsafe unsafe) {
        super(unsafe);
    }

    @Override // com.google.android.recaptcha.internal.zzlu
    public final double zza(Object obj, long j4) {
        return Double.longBitsToDouble(this.zza.getLong(obj, j4));
    }

    @Override // com.google.android.recaptcha.internal.zzlu
    public final float zzb(Object obj, long j4) {
        return Float.intBitsToFloat(this.zza.getInt(obj, j4));
    }

    /* JADX WARN: Failed to inline method: com.google.android.recaptcha.internal.zzlv.zzi(java.lang.Object, long, boolean):void */
    /* JADX WARN: Failed to inline method: com.google.android.recaptcha.internal.zzlv.zzj(java.lang.Object, long, boolean):void */
    /* JADX WARN: Unknown register number '(r5v0 'z4' boolean)' in method call: com.google.android.recaptcha.internal.zzlv.zzi(java.lang.Object, long, boolean):void */
    /* JADX WARN: Unknown register number '(r5v0 'z4' boolean)' in method call: com.google.android.recaptcha.internal.zzlv.zzj(java.lang.Object, long, boolean):void */
    @Override // com.google.android.recaptcha.internal.zzlu
    public final void zzc(Object obj, long j4, boolean z4) {
        if (zzlv.zzb) {
            zzlv.zzi(obj, j4, z4);
        } else {
            zzlv.zzj(obj, j4, z4);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzlu
    public final void zzd(Object obj, long j4, byte b5) {
        if (zzlv.zzb) {
            zzlv.zzD(obj, j4, b5);
        } else {
            zzlv.zzE(obj, j4, b5);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzlu
    public final void zze(Object obj, long j4, double d5) {
        this.zza.putLong(obj, j4, Double.doubleToLongBits(d5));
    }

    @Override // com.google.android.recaptcha.internal.zzlu
    public final void zzf(Object obj, long j4, float f4) {
        this.zza.putInt(obj, j4, Float.floatToIntBits(f4));
    }

    @Override // com.google.android.recaptcha.internal.zzlu
    public final boolean zzg(Object obj, long j4) {
        return zzlv.zzb ? zzlv.zzt(obj, j4) : zzlv.zzu(obj, j4);
    }
}
