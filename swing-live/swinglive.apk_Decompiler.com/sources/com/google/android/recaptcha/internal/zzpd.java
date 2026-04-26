package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzpd extends zzit implements zzkf {
    private static final zzpd zzb;
    private int zzd = 0;
    private Object zze;

    static {
        zzpd zzpdVar = new zzpd();
        zzb = zzpdVar;
        zzit.zzD(zzpd.class, zzpdVar);
    }

    private zzpd() {
    }

    public static /* synthetic */ void zzH(zzpd zzpdVar, zznf zznfVar) {
        zznfVar.getClass();
        zzpdVar.zze = zznfVar;
        zzpdVar.zzd = 1;
    }

    public static /* synthetic */ void zzI(zzpd zzpdVar, zznu zznuVar) {
        zznuVar.getClass();
        zzpdVar.zze = zznuVar;
        zzpdVar.zzd = 2;
    }

    public static zzpc zzi() {
        return (zzpc) zzb.zzp();
    }

    public static zzpd zzk(byte[] bArr) {
        return (zzpd) zzit.zzu(zzb, bArr);
    }

    public final int zzJ() {
        int i4 = this.zzd;
        if (i4 == 0) {
            return 3;
        }
        int i5 = 1;
        if (i4 != 1) {
            i5 = 2;
            if (i4 != 2) {
                return 0;
            }
        }
        return i5;
    }

    public final zznf zzf() {
        return this.zzd == 1 ? (zznf) this.zze : zznf.zzH();
    }

    public final zznu zzg() {
        return this.zzd == 2 ? (zznu) this.zze : zznu.zzg();
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0002\u0001\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001<\u0000\u0002<\u0000", new Object[]{"zze", "zzd", zznf.class, zznu.class});
        }
        if (i5 == 3) {
            return new zzpd();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzpc(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
