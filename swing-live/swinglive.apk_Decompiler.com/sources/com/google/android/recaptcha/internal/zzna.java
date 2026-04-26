package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzna extends zzit implements zzkf {
    private static final zzna zzb;
    private int zzd;
    private int zzf;
    private int zzh;
    private int zzj;
    private String zze = "";
    private String zzg = "";
    private String zzi = "";

    static {
        zzna zznaVar = new zzna();
        zzb = zznaVar;
        zzit.zzD(zzna.class, zznaVar);
    }

    private zzna() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0007\u0000\u0000\u0001\u0007\u0007\u0000\u0000\u0000\u0001\u0004\u0002Ȉ\u0003\u0004\u0004Ȉ\u0005\u0004\u0006Ȉ\u0007\u0004", new Object[]{"zzd", "zze", "zzf", "zzg", "zzh", "zzi", "zzj"});
        }
        if (i5 == 3) {
            return new zzna();
        }
        zzmy zzmyVar = null;
        if (i5 == 4) {
            return new zzmz(zzmyVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
