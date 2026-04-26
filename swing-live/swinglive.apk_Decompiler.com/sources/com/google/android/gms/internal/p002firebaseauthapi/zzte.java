package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzte extends zzaja<zzte, zza> implements zzakm {
    private static final zzte zzc;
    private static volatile zzakx<zzte> zzd;
    private int zze;
    private int zzf;

    public static final class zza extends zzaja.zzb<zzte, zza> implements zzakm {
        private zza() {
            super(zzte.zzc);
        }

        public final zza zza(int i4) {
            zzh();
            ((zzte) this.zza).zza(i4);
            return this;
        }

        public /* synthetic */ zza(zztd zztdVar) {
            this();
        }
    }

    static {
        zzte zzteVar = new zzte();
        zzc = zzteVar;
        zzaja.zza((Class<zzte>) zzte.class, zzteVar);
    }

    private zzte() {
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

    public static zzte zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzte) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zztd zztdVar = null;
        switch (zztd.zza[i4 - 1]) {
            case 1:
                return new zzte();
            case 2:
                return new zza(zztdVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u000b\u0002\u000b", new Object[]{"zze", "zzf"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzte> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzte.class) {
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
