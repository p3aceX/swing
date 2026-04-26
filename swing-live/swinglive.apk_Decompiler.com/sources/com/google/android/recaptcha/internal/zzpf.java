package com.google.android.recaptcha.internal;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzpf extends zzit implements zzkf {
    private static final zzpf zzb;
    private zzjb zzd = zzit.zzx();

    static {
        zzpf zzpfVar = new zzpf();
        zzb = zzpfVar;
        zzit.zzD(zzpf.class, zzpfVar);
    }

    private zzpf() {
    }

    public static zzpf zzg(byte[] bArr) {
        return (zzpf) zzit.zzu(zzb, bArr);
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0001\u0000\u0001\u001b", new Object[]{"zzd", zzpr.class});
        }
        if (i5 == 3) {
            return new zzpf();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzpe(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final List zzi() {
        return this.zzd;
    }
}
