package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzsx extends zzaja<zzsx, zza> implements zzakm {
    private static final zzsx zzc;
    private static volatile zzakx<zzsx> zzd;
    private int zze;
    private zzahm zzf = zzahm.zza;

    public static final class zza extends zzaja.zzb<zzsx, zza> implements zzakm {
        private zza() {
            super(zzsx.zzc);
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzsx) this.zza).zza(zzahmVar);
            return this;
        }

        public /* synthetic */ zza(zzsy zzsyVar) {
            this();
        }
    }

    static {
        zzsx zzsxVar = new zzsx();
        zzc = zzsxVar;
        zzaja.zza((Class<zzsx>) zzsx.class, zzsxVar);
    }

    private zzsx() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public static zzakx<zzsx> zze() {
        return (zzakx) zzc.zza(zzaja.zze.zzg, (Object) null, (Object) null);
    }

    public final int zza() {
        return this.zze;
    }

    public final zzahm zzd() {
        return this.zzf;
    }

    public static zzsx zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzsx) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzsy zzsyVar = null;
        switch (zzsy.zza[i4 - 1]) {
            case 1:
                return new zzsx();
            case 2:
                return new zza(zzsyVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0003\u0002\u0000\u0000\u0000\u0001\u000b\u0003\n", new Object[]{"zze", "zzf"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzsx> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzsx.class) {
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
