package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzsw extends zzaja<zzsw, zza> implements zzakm {
    private static final zzsw zzc;
    private static volatile zzakx<zzsw> zzd;
    private int zze;
    private int zzf;

    public static final class zza extends zzaja.zzb<zzsw, zza> implements zzakm {
        private zza() {
            super(zzsw.zzc);
        }

        public final zza zza(int i4) {
            zzh();
            ((zzsw) this.zza).zza(i4);
            return this;
        }

        public /* synthetic */ zza(zzsv zzsvVar) {
            this();
        }
    }

    static {
        zzsw zzswVar = new zzsw();
        zzc = zzswVar;
        zzaja.zza((Class<zzsw>) zzsw.class, zzswVar);
    }

    private zzsw() {
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

    public static zzsw zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzsw) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzsv zzsvVar = null;
        switch (zzsv.zza[i4 - 1]) {
            case 1:
                return new zzsw();
            case 2:
                return new zza(zzsvVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0002\u0003\u0002\u0000\u0000\u0000\u0002\u000b\u0003\u000b", new Object[]{"zze", "zzf"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzsw> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzsw.class) {
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
