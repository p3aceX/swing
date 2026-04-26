package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zztb extends zzaja<zztb, zza> implements zzakm {
    private static final zztb zzc;
    private static volatile zzakx<zztb> zzd;
    private int zze;
    private zzahm zzf = zzahm.zza;

    public static final class zza extends zzaja.zzb<zztb, zza> implements zzakm {
        private zza() {
            super(zztb.zzc);
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zztb) this.zza).zza(zzahmVar);
            return this;
        }

        public /* synthetic */ zza(zztc zztcVar) {
            this();
        }
    }

    static {
        zztb zztbVar = new zztb();
        zzc = zztbVar;
        zzaja.zza((Class<zztb>) zztb.class, zztbVar);
    }

    private zztb() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public static zzakx<zztb> zze() {
        return (zzakx) zzc.zza(zzaja.zze.zzg, (Object) null, (Object) null);
    }

    public final int zza() {
        return this.zze;
    }

    public final zzahm zzd() {
        return this.zzf;
    }

    public static zztb zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zztb) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zztc zztcVar = null;
        switch (zztc.zza[i4 - 1]) {
            case 1:
                return new zztb();
            case 2:
                return new zza(zztcVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u000b\u0002\n", new Object[]{"zze", "zzf"});
            case 4:
                return zzc;
            case 5:
                zzakx<zztb> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zztb.class) {
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
        this.zzf = zzahmVar;
    }
}
