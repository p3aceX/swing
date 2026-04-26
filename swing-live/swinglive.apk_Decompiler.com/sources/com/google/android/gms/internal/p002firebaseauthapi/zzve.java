package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public final class zzve extends zzaja<zzve, zza> implements zzakm {
    private static final zzve zzc;
    private static volatile zzakx<zzve> zzd;
    private int zzg;
    private boolean zzh;
    private String zze = "";
    private String zzf = "";
    private String zzi = "";

    public static final class zza extends zzaja.zzb<zzve, zza> implements zzakm {
        private zza() {
            super(zzve.zzc);
        }

        public /* synthetic */ zza(zzvf zzvfVar) {
            this();
        }
    }

    static {
        zzve zzveVar = new zzve();
        zzc = zzveVar;
        zzaja.zza((Class<zzve>) zzve.class, zzveVar);
    }

    private zzve() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzvf zzvfVar = null;
        switch (zzvf.zza[i4 - 1]) {
            case 1:
                return new zzve();
            case 2:
                return new zza(zzvfVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0005\u0000\u0000\u0001\u0005\u0005\u0000\u0000\u0000\u0001Ȉ\u0002Ȉ\u0003\u000b\u0004\u0007\u0005Ȉ", new Object[]{"zze", "zzf", "zzg", "zzh", "zzi"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzve> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzve.class) {
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
