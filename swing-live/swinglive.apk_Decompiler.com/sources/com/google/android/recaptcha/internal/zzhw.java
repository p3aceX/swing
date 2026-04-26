package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzhw extends zzit implements zzkf {
    private static final zzhw zzb;
    private int zzd;
    private boolean zzf;
    private byte zzg = 2;
    private String zze = "";

    static {
        zzhw zzhwVar = new zzhw();
        zzb = zzhwVar;
        zzit.zzD(zzhw.class, zzhwVar);
    }

    private zzhw() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return Byte.valueOf(this.zzg);
        }
        if (i5 == 2) {
            return new zzkp(zzb, "\u0001\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0002\u0001ᔈ\u0000\u0002ᔇ\u0001", new Object[]{"zzd", "zze", "zzf"});
        }
        if (i5 == 3) {
            return new zzhw();
        }
        zzhj zzhjVar = null;
        if (i5 == 4) {
            return new zzhv(zzhjVar);
        }
        if (i5 == 5) {
            return zzb;
        }
        this.zzg = obj == null ? (byte) 0 : (byte) 1;
        return null;
    }
}
