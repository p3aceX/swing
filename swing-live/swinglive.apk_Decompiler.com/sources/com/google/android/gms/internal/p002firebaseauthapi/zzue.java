package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzue extends zzaja<zzue, zza> implements zzakm {
    private static final zzue zzc;
    private static volatile zzakx<zzue> zzd;
    private int zze;
    private int zzf;
    private zzui zzg;
    private zzahm zzh = zzahm.zza;

    public static final class zza extends zzaja.zzb<zzue, zza> implements zzakm {
        private zza() {
            super(zzue.zzc);
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzue) this.zza).zza(zzahmVar);
            return this;
        }

        public /* synthetic */ zza(zzud zzudVar) {
            this();
        }

        public final zza zza(zzui zzuiVar) {
            zzh();
            ((zzue) this.zza).zza(zzuiVar);
            return this;
        }

        public final zza zza(int i4) {
            zzh();
            ((zzue) this.zza).zza(i4);
            return this;
        }
    }

    static {
        zzue zzueVar = new zzue();
        zzc = zzueVar;
        zzaja.zza((Class<zzue>) zzue.class, zzueVar);
    }

    private zzue() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public static zzue zzd() {
        return zzc;
    }

    public final int zza() {
        return this.zzf;
    }

    public final zzui zze() {
        zzui zzuiVar = this.zzg;
        return zzuiVar == null ? zzui.zze() : zzuiVar;
    }

    public final zzahm zzf() {
        return this.zzh;
    }

    public static zzue zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzue) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzud zzudVar = null;
        switch (zzud.zza[i4 - 1]) {
            case 1:
                return new zzue();
            case 2:
                return new zza(zzudVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000\u0003\n", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzue> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzue.class) {
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
    public final void zza(zzui zzuiVar) {
        zzuiVar.getClass();
        this.zzg = zzuiVar;
        this.zze |= 1;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(int i4) {
        this.zzf = i4;
    }
}
