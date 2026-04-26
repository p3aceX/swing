package com.google.android.recaptcha.internal;

import java.io.InputStream;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzol extends zzit implements zzkf {
    private static final zzol zzb;
    private int zzd;
    private long zzf;
    private int zzg;
    private String zze = "";
    private zzjb zzh = zzit.zzx();

    static {
        zzol zzolVar = new zzol();
        zzb = zzolVar;
        zzit.zzD(zzol.class, zzolVar);
    }

    private zzol() {
    }

    public static zzol zzg(InputStream inputStream) {
        return (zzol) zzit.zzt(zzb, inputStream);
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0004\u0000\u0001\u0001\u0005\u0004\u0000\u0001\u0000\u0001ለ\u0000\u0002ဂ\u0001\u0004ဌ\u0002\u0005\u001b", new Object[]{"zzd", "zze", "zzf", "zzg", "zzh", zzon.class});
        }
        if (i5 == 3) {
            return new zzol();
        }
        zzoh zzohVar = null;
        if (i5 == 4) {
            return new zzok(zzohVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final String zzi() {
        return this.zze;
    }

    public final List zzj() {
        return this.zzh;
    }
}
