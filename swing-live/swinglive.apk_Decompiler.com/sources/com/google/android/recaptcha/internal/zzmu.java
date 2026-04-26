package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzmu extends zzit implements zzkf {
    private static final zzmu zzb;
    private String zzd = "";
    private String zze = "";
    private String zzf = "";
    private String zzg = "";
    private String zzh = "";
    private String zzi = "";

    static {
        zzmu zzmuVar = new zzmu();
        zzb = zzmuVar;
        zzit.zzD(zzmu.class, zzmuVar);
    }

    private zzmu() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0006\u0000\u0000\u0001\u0006\u0006\u0000\u0000\u0000\u0001Ȉ\u0002Ȉ\u0003Ȉ\u0004Ȉ\u0005Ȉ\u0006Ȉ", new Object[]{"zzd", "zze", "zzf", "zzg", "zzh", "zzi"});
        }
        if (i5 == 3) {
            return new zzmu();
        }
        zzms zzmsVar = null;
        if (i5 == 4) {
            return new zzmt(zzmsVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
