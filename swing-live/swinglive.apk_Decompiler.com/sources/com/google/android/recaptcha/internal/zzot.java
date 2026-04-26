package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzot extends zzit implements zzkf {
    private static final zzot zzb;
    private String zzd = "";
    private String zze = "";
    private String zzf = "";

    static {
        zzot zzotVar = new zzot();
        zzb = zzotVar;
        zzit.zzD(zzot.class, zzotVar);
    }

    private zzot() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001Ȉ\u0002Ȉ\u0003Ȉ", new Object[]{"zzd", "zze", "zzf"});
        }
        if (i5 == 3) {
            return new zzot();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzos(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
