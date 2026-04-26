package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzvp extends zzaja<zzvp, zza> implements zzakm {
    private static final zzvp zzc;
    private static volatile zzakx<zzvp> zzd;
    private int zze;
    private int zzf;
    private zzvq zzg;

    public static final class zza extends zzaja.zzb<zzvp, zza> implements zzakm {
        private zza() {
            super(zzvp.zzc);
        }

        public final zza zza(zzvq zzvqVar) {
            zzh();
            ((zzvp) this.zza).zza(zzvqVar);
            return this;
        }

        public /* synthetic */ zza(zzvo zzvoVar) {
            this();
        }
    }

    static {
        zzvp zzvpVar = new zzvp();
        zzc = zzvpVar;
        zzaja.zza((Class<zzvp>) zzvp.class, zzvpVar);
    }

    private zzvp() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public static zzakx<zzvp> zze() {
        return (zzakx) zzc.zza(zzaja.zze.zzg, (Object) null, (Object) null);
    }

    public final int zza() {
        return this.zzf;
    }

    public final zzvq zzd() {
        zzvq zzvqVar = this.zzg;
        return zzvqVar == null ? zzvq.zzd() : zzvqVar;
    }

    public static zzvp zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzvp) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzvo zzvoVar = null;
        switch (zzvo.zza[i4 - 1]) {
            case 1:
                return new zzvp();
            case 2:
                return new zza(zzvoVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzvp> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzvp.class) {
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
    public final void zza(zzvq zzvqVar) {
        zzvqVar.getClass();
        this.zzg = zzvqVar;
        this.zze |= 1;
    }
}
