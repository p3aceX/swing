package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzox extends zzit implements zzkf {
    private static final zzox zzb;
    private int zzd;

    static {
        zzox zzoxVar = new zzox();
        zzb = zzoxVar;
        zzit.zzD(zzox.class, zzoxVar);
    }

    private zzox() {
    }

    public static zzox zzg(byte[] bArr) {
        return (zzox) zzit.zzu(zzb, bArr);
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0000\u0000\u0001\f", new Object[]{"zzd"});
        }
        if (i5 == 3) {
            return new zzox();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzow(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final zzpb zzi() {
        zzpb zzpbVarZzb = zzpb.zzb(this.zzd);
        return zzpbVarZzb == null ? zzpb.UNRECOGNIZED : zzpbVarZzb;
    }
}
