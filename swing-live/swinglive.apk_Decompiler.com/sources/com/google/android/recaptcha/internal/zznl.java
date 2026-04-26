package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zznl extends zzit implements zzkf {
    private static final zznl zzb;
    private int zzd;
    private int zze = 0;
    private Object zzf;
    private zzno zzg;
    private int zzh;
    private zzmr zzi;
    private zzna zzj;

    static {
        zznl zznlVar = new zznl();
        zzb = zznlVar;
        zzit.zzD(zznl.class, zznlVar);
    }

    private zznl() {
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000(\u0001\u0001\u0001((\u0000\u0000\u0000\u0001ဉ\u0000\u0002\f\u0003ဉ\u0001\u0004?\u0000\u0005?\u0000\u0006?\u0000\u0007?\u0000\b?\u0000\t?\u0000\n?\u0000\u000b?\u0000\f?\u0000\r?\u0000\u000e?\u0000\u000f?\u0000\u0010?\u0000\u0011?\u0000\u0012?\u0000\u0013?\u0000\u0014?\u0000\u0015?\u0000\u0016?\u0000\u0017?\u0000\u0018?\u0000\u0019ဉ\u0002\u001a?\u0000\u001b?\u0000\u001c?\u0000\u001d?\u0000\u001e?\u0000\u001f?\u0000 ?\u0000!?\u0000\"?\u0000#?\u0000$?\u0000%?\u0000&?\u0000'?\u0000(?\u0000", new Object[]{"zzf", "zze", "zzd", "zzg", "zzh", "zzi", "zzj"});
        }
        if (i5 == 3) {
            return new zznl();
        }
        zznj zznjVar = null;
        if (i5 == 4) {
            return new zznk(zznjVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
