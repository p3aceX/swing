package com.google.android.recaptcha.internal;

import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class zzoz extends zzit implements zzkf {
    private static final zzoz zzb;
    private int zzd;
    private int zze;
    private int zzf;

    static {
        zzoz zzozVar = new zzoz();
        zzb = zzozVar;
        zzit.zzD(zzoz.class, zzozVar);
    }

    private zzoz() {
    }

    public static zzoz zzg(InputStream inputStream) {
        return (zzoz) zzit.zzt(zzb, inputStream);
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001ဌ\u0000\u0002ဌ\u0001", new Object[]{"zzd", "zze", "zzf"});
        }
        if (i5 == 3) {
            return new zzoz();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzoy(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final zzpb zzi() {
        zzpb zzpbVarZzb = zzpb.zzb(this.zzf);
        return zzpbVarZzb == null ? zzpb.UNRECOGNIZED : zzpbVarZzb;
    }
}
