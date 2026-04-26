package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzpk extends zzit implements zzkf {
    private static final zzpk zzb;
    private int zzd = 0;
    private Object zze;

    static {
        zzpk zzpkVar = new zzpk();
        zzb = zzpkVar;
        zzit.zzD(zzpk.class, zzpkVar);
    }

    private zzpk() {
    }

    public static /* synthetic */ void zzH(zzpk zzpkVar, double d5) {
        zzpkVar.zzd = 10;
        zzpkVar.zze = Double.valueOf(d5);
    }

    public static /* synthetic */ void zzI(zzpk zzpkVar, String str) {
        str.getClass();
        zzpkVar.zzd = 11;
        zzpkVar.zze = str;
    }

    public static /* synthetic */ void zzJ(zzpk zzpkVar, boolean z4) {
        zzpkVar.zzd = 1;
        zzpkVar.zze = Boolean.valueOf(z4);
    }

    public static /* synthetic */ void zzK(zzpk zzpkVar, zzgw zzgwVar) {
        zzpkVar.zzd = 2;
        zzpkVar.zze = zzgwVar;
    }

    public static /* synthetic */ void zzL(zzpk zzpkVar, String str) {
        str.getClass();
        zzpkVar.zzd = 3;
        zzpkVar.zze = str;
    }

    public static /* synthetic */ void zzM(zzpk zzpkVar, int i4) {
        zzpkVar.zzd = 4;
        zzpkVar.zze = Integer.valueOf(i4);
    }

    public static zzpj zzf() {
        return (zzpj) zzb.zzp();
    }

    public static /* synthetic */ void zzi(zzpk zzpkVar, int i4) {
        zzpkVar.zzd = 5;
        zzpkVar.zze = Integer.valueOf(i4);
    }

    public static /* synthetic */ void zzj(zzpk zzpkVar, long j4) {
        zzpkVar.zzd = 7;
        zzpkVar.zze = Long.valueOf(j4);
    }

    public static /* synthetic */ void zzk(zzpk zzpkVar, float f4) {
        zzpkVar.zzd = 9;
        zzpkVar.zze = Float.valueOf(f4);
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u000b\u0001\u0000\u0001\u000b\u000b\u0000\u0000\u0000\u0001:\u0000\u0002=\u0000\u0003Ȼ\u0000\u0004B\u0000\u0005B\u0000\u0006>\u0000\u0007C\u0000\b6\u0000\t4\u0000\n3\u0000\u000bȻ\u0000", new Object[]{"zze", "zzd"});
        }
        if (i5 == 3) {
            return new zzpk();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzpj(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
