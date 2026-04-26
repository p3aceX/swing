package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zznr extends zzit implements zzkf {
    private static final zznr zzb;
    private int zzd;
    private zzmu zzf;
    private zzmo zzg;
    private zzmx zzh;
    private String zze = "";
    private String zzi = "";
    private String zzj = "";

    static {
        zznr zznrVar = new zznr();
        zzb = zznrVar;
        zzit.zzD(zznr.class, zznrVar);
    }

    private zznr() {
    }

    public static /* synthetic */ void zzH(zznr zznrVar, zzmo zzmoVar) {
        zzmoVar.getClass();
        zznrVar.zzg = zzmoVar;
        zznrVar.zzd |= 2;
    }

    public static zznq zzf() {
        return (zznq) zzb.zzp();
    }

    public static /* synthetic */ void zzi(zznr zznrVar, String str) {
        str.getClass();
        zznrVar.zze = str;
    }

    public static /* synthetic */ void zzj(zznr zznrVar, String str) {
        str.getClass();
        zznrVar.zzi = str;
    }

    public static /* synthetic */ void zzk(zznr zznrVar, String str) {
        str.getClass();
        zznrVar.zzj = str;
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0006\u0000\u0001\u0001\u0006\u0006\u0000\u0000\u0000\u0001Ȉ\u0002ဉ\u0000\u0003ဉ\u0001\u0004ဉ\u0002\u0005Ȉ\u0006Ȉ", new Object[]{"zzd", "zze", "zzf", "zzg", "zzh", "zzi", "zzj"});
        }
        if (i5 == 3) {
            return new zznr();
        }
        zznp zznpVar = null;
        if (i5 == 4) {
            return new zznq(zznpVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }
}
