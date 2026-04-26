package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzmx extends zzit implements zzkf {
    private static final zzmx zzb;
    private String zzd = "";
    private String zze = "";

    static {
        zzmx zzmxVar = new zzmx();
        zzb = zzmxVar;
        zzit.zzD(zzmx.class, zzmxVar);
    }

    private zzmx() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001Ȉ\u0002Ȉ", new Object[]{"zzd", "zze"});
        }
        if (i5 == 3) {
            return new zzmx();
        }
        zzmv zzmvVar = null;
        if (i5 == 4) {
            return new zzmw(zzmvVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
