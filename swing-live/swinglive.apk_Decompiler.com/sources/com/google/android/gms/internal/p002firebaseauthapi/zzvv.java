package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public final class zzvv extends zzaja<zzvv, zza> implements zzakm {
    private static final zzvv zzc;
    private static volatile zzakx<zzvv> zzd;
    private String zze = "";
    private zzajg<zzve> zzf = zzaja.zzo();

    public static final class zza extends zzaja.zzb<zzvv, zza> implements zzakm {
        private zza() {
            super(zzvv.zzc);
        }

        public /* synthetic */ zza(zzvu zzvuVar) {
            this();
        }
    }

    static {
        zzvv zzvvVar = new zzvv();
        zzc = zzvvVar;
        zzaja.zza((Class<zzvv>) zzvv.class, zzvvVar);
    }

    private zzvv() {
    }

    public static zzvv zzb() {
        return zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzvu zzvuVar = null;
        switch (zzvu.zza[i4 - 1]) {
            case 1:
                return new zzvv();
            case 2:
                return new zza(zzvuVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0001\u0000\u0001Ȉ\u0002\u001b", new Object[]{"zze", "zzf", zzve.class});
            case 4:
                return zzc;
            case 5:
                zzakx<zzvv> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzvv.class) {
                    try {
                        zzaVar = zzd;
                        if (zzaVar == null) {
                            zzaVar = new zzaja.zza(zzc);
                            zzd = zzaVar;
                        }
                    } catch (Throwable th) {
                        throw th;
                    }
                    break;
                }
                return zzaVar;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return (byte) 1;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return null;
            default:
                throw new UnsupportedOperationException();
        }
    }
}
