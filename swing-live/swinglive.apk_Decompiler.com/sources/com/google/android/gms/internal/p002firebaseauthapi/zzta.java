package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzta extends zzaja<zzta, zza> implements zzakm {
    private static final zzta zzc;
    private static volatile zzakx<zzta> zzd;
    private int zze;
    private int zzf;

    public static final class zza extends zzaja.zzb<zzta, zza> implements zzakm {
        private zza() {
            super(zzta.zzc);
        }

        public final zza zza(int i4) {
            zzh();
            ((zzta) this.zza).zza(i4);
            return this;
        }

        public /* synthetic */ zza(zzsz zzszVar) {
            this();
        }
    }

    static {
        zzta zztaVar = new zzta();
        zzc = zztaVar;
        zzaja.zza((Class<zzta>) zzta.class, zztaVar);
    }

    private zzta() {
    }

    public static zza zzc() {
        return zzc.zzl();
    }

    public final int zza() {
        return this.zze;
    }

    public final int zzb() {
        return this.zzf;
    }

    public static zzta zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzta) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzsz zzszVar = null;
        switch (zzsz.zza[i4 - 1]) {
            case 1:
                return new zzta();
            case 2:
                return new zza(zzszVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u000b\u0002\u000b", new Object[]{"zzf", "zze"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzta> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzta.class) {
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

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(int i4) {
        this.zze = i4;
    }
}
