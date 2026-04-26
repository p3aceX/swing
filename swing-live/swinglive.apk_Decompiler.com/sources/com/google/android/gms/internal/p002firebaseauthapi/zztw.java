package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zztw extends zzaja<zztw, zza> implements zzakm {
    private static final zztw zzc;
    private static volatile zzakx<zztw> zzd;
    private int zze;
    private int zzf;
    private zzahm zzg = zzahm.zza;

    public static final class zza extends zzaja.zzb<zztw, zza> implements zzakm {
        private zza() {
            super(zztw.zzc);
        }

        public final zza zza(zztx zztxVar) {
            zzh();
            ((zztw) this.zza).zza(zztxVar);
            return this;
        }

        public /* synthetic */ zza(zztv zztvVar) {
            this();
        }

        public final zza zza(zzuc zzucVar) {
            zzh();
            ((zztw) this.zza).zza(zzucVar);
            return this;
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zztw) this.zza).zza(zzahmVar);
            return this;
        }
    }

    static {
        zztw zztwVar = new zztw();
        zzc = zztwVar;
        zzaja.zza((Class<zztw>) zztw.class, zztwVar);
    }

    private zztw() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    public static zztw zzc() {
        return zzc;
    }

    public final zztx zzd() {
        zztx zztxVarZza = zztx.zza(this.zze);
        return zztxVarZza == null ? zztx.UNRECOGNIZED : zztxVarZza;
    }

    public final zzuc zze() {
        zzuc zzucVarZza = zzuc.zza(this.zzf);
        return zzucVarZza == null ? zzuc.UNRECOGNIZED : zzucVarZza;
    }

    public final zzahm zzf() {
        return this.zzg;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zztv zztvVar = null;
        switch (zztv.zza[i4 - 1]) {
            case 1:
                return new zztw();
            case 2:
                return new zza(zztvVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0000\u0001\u000b\u0003\u0000\u0000\u0000\u0001\f\u0002\f\u000b\n", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zztw> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zztw.class) {
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
    public final void zza(zztx zztxVar) {
        this.zze = zztxVar.zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzuc zzucVar) {
        this.zzf = zzucVar.zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzahm zzahmVar) {
        zzahmVar.getClass();
        this.zzg = zzahmVar;
    }
}
