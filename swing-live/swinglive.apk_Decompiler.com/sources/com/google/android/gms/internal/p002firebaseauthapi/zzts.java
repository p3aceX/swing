package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzts extends zzaja<zzts, zza> implements zzakm {
    private static final zzts zzc;
    private static volatile zzakx<zzts> zzd;
    private int zze;
    private int zzf;
    private zztt zzg;
    private zzahm zzh = zzahm.zza;

    public static final class zza extends zzaja.zzb<zzts, zza> implements zzakm {
        private zza() {
            super(zzts.zzc);
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzts) this.zza).zza(zzahmVar);
            return this;
        }

        public /* synthetic */ zza(zztr zztrVar) {
            this();
        }

        public final zza zza(zztt zzttVar) {
            zzh();
            ((zzts) this.zza).zza(zzttVar);
            return this;
        }

        public final zza zza(int i4) {
            zzh();
            ((zzts) this.zza).zza(0);
            return this;
        }
    }

    static {
        zzts zztsVar = new zzts();
        zzc = zztsVar;
        zzaja.zza((Class<zzts>) zzts.class, zztsVar);
    }

    private zzts() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public final int zza() {
        return this.zzf;
    }

    public final zztt zzd() {
        zztt zzttVar = this.zzg;
        return zzttVar == null ? zztt.zze() : zzttVar;
    }

    public final zzahm zze() {
        return this.zzh;
    }

    public static zzts zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzts) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zztr zztrVar = null;
        switch (zztr.zza[i4 - 1]) {
            case 1:
                return new zzts();
            case 2:
                return new zza(zztrVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000\u0003\n", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzts> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzts.class) {
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
    public final void zza(zzahm zzahmVar) {
        zzahmVar.getClass();
        this.zzh = zzahmVar;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zztt zzttVar) {
        zzttVar.getClass();
        this.zzg = zzttVar;
        this.zze |= 1;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(int i4) {
        this.zzf = i4;
    }
}
