package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzlj extends zzit implements zzkf {
    private static final zzlj zzb;
    private long zzd;
    private int zze;

    static {
        zzlj zzljVar = new zzlj();
        zzb = zzljVar;
        zzit.zzD(zzlj.class, zzljVar);
    }

    private zzlj() {
    }

    public static zzli zzi() {
        return (zzli) zzb.zzp();
    }

    public final int zzf() {
        return this.zze;
    }

    public final long zzg() {
        return this.zzd;
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return new zzkp(zzb, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u0002\u0002\u0004", new Object[]{"zzd", "zze"});
        }
        if (i5 == 3) {
            return new zzlj();
        }
        zzlh zzlhVar = null;
        if (i5 == 4) {
            return new zzli(zzlhVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
