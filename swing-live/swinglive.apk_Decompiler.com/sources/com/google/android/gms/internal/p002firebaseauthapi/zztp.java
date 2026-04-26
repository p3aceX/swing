package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zztp extends zzaja<zztp, zza> implements zzakm {
    private static final zztp zzc;
    private static volatile zzakx<zztp> zzd;
    private int zze;
    private zztw zzf;
    private zztk zzg;
    private int zzh;

    public static final class zza extends zzaja.zzb<zztp, zza> implements zzakm {
        private zza() {
            super(zztp.zzc);
        }

        public final zza zza(zztk zztkVar) {
            zzh();
            ((zztp) this.zza).zza(zztkVar);
            return this;
        }

        public /* synthetic */ zza(zztq zztqVar) {
            this();
        }

        public final zza zza(zztj zztjVar) {
            zzh();
            ((zztp) this.zza).zza(zztjVar);
            return this;
        }

        public final zza zza(zztw zztwVar) {
            zzh();
            ((zztp) this.zza).zza(zztwVar);
            return this;
        }
    }

    static {
        zztp zztpVar = new zztp();
        zzc = zztpVar;
        zzaja.zza((Class<zztp>) zztp.class, zztpVar);
    }

    private zztp() {
    }

    public static zza zzc() {
        return zzc.zzl();
    }

    public static zztp zze() {
        return zzc;
    }

    public final zztj zza() {
        zztj zztjVarZza = zztj.zza(this.zzh);
        return zztjVarZza == null ? zztj.UNRECOGNIZED : zztjVarZza;
    }

    public final zztk zzb() {
        zztk zztkVar = this.zzg;
        return zztkVar == null ? zztk.zzc() : zztkVar;
    }

    public final zztw zzf() {
        zztw zztwVar = this.zzf;
        return zztwVar == null ? zztw.zzc() : zztwVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zztq zztqVar = null;
        switch (zztq.zza[i4 - 1]) {
            case 1:
                return new zztp();
            case 2:
                return new zza(zztqVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001ဉ\u0000\u0002ဉ\u0001\u0003\f", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzakx<zztp> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zztp.class) {
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
    public final void zza(zztk zztkVar) {
        zztkVar.getClass();
        this.zzg = zztkVar;
        this.zze |= 2;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zztj zztjVar) {
        this.zzh = zztjVar.zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zztw zztwVar) {
        zztwVar.getClass();
        this.zzf = zztwVar;
        this.zze |= 1;
    }
}
