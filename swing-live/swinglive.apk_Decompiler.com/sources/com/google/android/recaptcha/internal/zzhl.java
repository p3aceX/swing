package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzhl extends zzip implements zzkf {
    private static final zzhl zzd;
    private int zze;
    private boolean zzf;
    private zzht zzg;
    private boolean zzh;
    private byte zzj = 2;
    private zzjb zzi = zzko.zze();

    static {
        zzhl zzhlVar = new zzhl();
        zzd = zzhlVar;
        zzit.zzD(zzhl.class, zzhlVar);
    }

    private zzhl() {
    }

    public static zzhl zzg() {
        return zzd;
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return Byte.valueOf(this.zzj);
        }
        if (i5 == 2) {
            return new zzkp(zzd, "\u0001\u0004\u0000\u0001\u0001ϧ\u0004\u0000\u0001\u0002\u0001ဇ\u0000\u0002ᐉ\u0001\u0003ဇ\u0002ϧЛ", new Object[]{"zze", "zzf", "zzg", "zzh", "zzi", zzhx.class});
        }
        if (i5 == 3) {
            return new zzhl();
        }
        zzhj zzhjVar = null;
        if (i5 == 4) {
            return new zzhk(zzhjVar);
        }
        if (i5 == 5) {
            return zzd;
        }
        this.zzj = obj == null ? (byte) 0 : (byte) 1;
        return null;
    }
}
