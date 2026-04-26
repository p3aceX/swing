package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzus extends zzaja<zzus, zza> implements zzakm {
    private static final zzus zzc;
    private static volatile zzakx<zzus> zzd;
    private int zze;
    private int zzf;
    private int zzg;

    public static final class zza extends zzaja.zzb<zzus, zza> implements zzakm {
        private zza() {
            super(zzus.zzc);
        }

        public final zza zza(zzuj zzujVar) {
            zzh();
            ((zzus) this.zza).zza(zzujVar);
            return this;
        }

        public /* synthetic */ zza(zzur zzurVar) {
            this();
        }

        public final zza zza(zzuk zzukVar) {
            zzh();
            ((zzus) this.zza).zza(zzukVar);
            return this;
        }

        public final zza zza(zzum zzumVar) {
            zzh();
            ((zzus) this.zza).zza(zzumVar);
            return this;
        }
    }

    static {
        zzus zzusVar = new zzus();
        zzc = zzusVar;
        zzaja.zza((Class<zzus>) zzus.class, zzusVar);
    }

    private zzus() {
    }

    public static zza zzd() {
        return zzc.zzl();
    }

    public static zzus zzf() {
        return zzc;
    }

    public final zzuj zza() {
        zzuj zzujVarZza = zzuj.zza(this.zzg);
        return zzujVarZza == null ? zzuj.UNRECOGNIZED : zzujVarZza;
    }

    public final zzuk zzb() {
        zzuk zzukVarZza = zzuk.zza(this.zzf);
        return zzukVarZza == null ? zzuk.UNRECOGNIZED : zzukVarZza;
    }

    public final zzum zzc() {
        zzum zzumVarZza = zzum.zza(this.zze);
        return zzumVarZza == null ? zzum.UNRECOGNIZED : zzumVarZza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzur zzurVar = null;
        switch (zzur.zza[i4 - 1]) {
            case 1:
                return new zzus();
            case 2:
                return new zza(zzurVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001\f\u0002\f\u0003\f", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzus> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzus.class) {
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
    public final void zza(zzuj zzujVar) {
        this.zzg = zzujVar.zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzuk zzukVar) {
        this.zzf = zzukVar.zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzum zzumVar) {
        this.zze = zzumVar.zza();
    }
}
