package com.google.android.recaptcha.internal;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzpn extends zzit implements zzkf {
    private static final zzpn zzb;
    private String zzd = "";
    private zziy zze = zzit.zzv();
    private zzja zzf = zzit.zzw();

    static {
        zzpn zzpnVar = new zzpn();
        zzb = zzpnVar;
        zzit.zzD(zzpn.class, zzpnVar);
    }

    private zzpn() {
    }

    public static zzpn zzg(byte[] bArr) {
        return (zzpn) zzit.zzu(zzb, bArr);
    }

    @Override // com.google.android.recaptcha.internal.zzit
    public final Object zzh(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzit.zzA(zzb, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0002\u0000\u0001Ȉ\u0002'\u0003%", new Object[]{"zzd", "zze", "zzf"});
        }
        if (i5 == 3) {
            return new zzpn();
        }
        zzor zzorVar = null;
        if (i5 == 4) {
            return new zzpm(zzorVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final String zzi() {
        return this.zzd;
    }

    public final List zzj() {
        return this.zzf;
    }
}
