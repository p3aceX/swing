package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzml extends zzit implements zzkf {
    private static final zzml zzb;
    private int zzd;
    private zzib zze;
    private int zzf;

    static {
        zzml zzmlVar = new zzml();
        zzb = zzmlVar;
        zzit.zzD(zzml.class, zzmlVar);
    }

    private zzml() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001ဉ\u0000\u0002\u0004", new Object[]{"zzd", "zze", "zzf"});
        }
        if (i5 == 3) {
            return new zzml();
        }
        zzmj zzmjVar = null;
        if (i5 == 4) {
            return new zzmk(zzmjVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
