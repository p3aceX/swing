package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzuo extends zzaja<zzuo, zza> implements zzakm {
    private static final zzuo zzc;
    private static volatile zzakx<zzuo> zzd;
    private int zze;
    private zzus zzf;

    public static final class zza extends zzaja.zzb<zzuo, zza> implements zzakm {
        private zza() {
            super(zzuo.zzc);
        }

        public final zza zza(zzus zzusVar) {
            zzh();
            ((zzuo) this.zza).zza(zzusVar);
            return this;
        }

        public /* synthetic */ zza(zzuq zzuqVar) {
            this();
        }
    }

    static {
        zzuo zzuoVar = new zzuo();
        zzc = zzuoVar;
        zzaja.zza((Class<zzuo>) zzuo.class, zzuoVar);
    }

    private zzuo() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    public final zzus zzc() {
        zzus zzusVar = this.zzf;
        return zzusVar == null ? zzus.zzf() : zzusVar;
    }

    public static zzuo zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzuo) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzuq zzuqVar = null;
        switch (zzuq.zza[i4 - 1]) {
            case 1:
                return new zzuo();
            case 2:
                return new zza(zzuqVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0001\u0000\u0001\u0001\u0001\u0001\u0000\u0000\u0000\u0001ဉ\u0000", new Object[]{"zze", "zzf"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzuo> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzuo.class) {
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
    public final void zza(zzus zzusVar) {
        zzusVar.getClass();
        this.zzf = zzusVar;
        this.zze |= 1;
    }
}
