package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzon extends zzit implements zzkf {
    private static final zzon zzb;
    private int zzd;
    private String zze = "";
    private String zzf = "";

    static {
        zzon zzonVar = new zzon();
        zzb = zzonVar;
        zzit.zzD(zzon.class, zzonVar);
    }

    private zzon() {
    }

    public final String zzg() {
        return this.zze;
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001ለ\u0000\u0002ለ\u0001", new Object[]{"zzd", "zze", "zzf"});
        }
        if (i5 == 3) {
            return new zzon();
        }
        zzoh zzohVar = null;
        if (i5 == 4) {
            return new zzom(zzohVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final String zzi() {
        return this.zzf;
    }
}
