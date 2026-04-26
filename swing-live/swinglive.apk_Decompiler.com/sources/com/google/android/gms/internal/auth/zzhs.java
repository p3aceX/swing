package com.google.android.gms.internal.auth;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzhs extends zzev implements zzfy {
    private static final zzhs zzb;
    private zzez zzd = zzev.zzf();

    static {
        zzhs zzhsVar = new zzhs();
        zzb = zzhsVar;
        zzev.zzk(zzhs.class, zzhsVar);
    }

    private zzhs() {
    }

    public static zzhs zzp(byte[] bArr) {
        return (zzhs) zzev.zzd(zzb, bArr);
    }

    @Override // com.google.android.gms.internal.auth.zzev
    public final Object zzn(int i4, Object obj, Object obj2) {
        int i5 = i4 - 1;
        if (i5 == 0) {
            return (byte) 1;
        }
        if (i5 == 2) {
            return zzev.zzh(zzb, "\u0001\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0001\u0000\u0001\u001a", new Object[]{"zzd"});
        }
        if (i5 == 3) {
            return new zzhs();
        }
        zzhq zzhqVar = null;
        if (i5 == 4) {
            return new zzhr(zzhqVar);
        }
        if (i5 != 5) {
            return null;
        }
        return zzb;
    }

    public final List zzq() {
        return this.zzd;
    }
}
