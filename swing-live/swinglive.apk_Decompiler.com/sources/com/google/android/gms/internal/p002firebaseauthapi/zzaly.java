package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzaly extends zzaja<zzaly, zza> implements zzakm {
    private static final zzaly zzc;
    private static volatile zzakx<zzaly> zzd;
    private long zze;
    private int zzf;

    public static final class zza extends zzaja.zzb<zzaly, zza> implements zzakm {
        private zza() {
            super(zzaly.zzc);
        }

        public final zza zza(int i4) {
            if (!this.zza.zzv()) {
                zzi();
            }
            ((zzaly) this.zza).zza(i4);
            return this;
        }

        public /* synthetic */ zza(zzama zzamaVar) {
            this();
        }

        public final zza zza(long j4) {
            if (!this.zza.zzv()) {
                zzi();
            }
            ((zzaly) this.zza).zza(j4);
            return this;
        }
    }

    static {
        zzaly zzalyVar = new zzaly();
        zzc = zzalyVar;
        zzaja.zza((Class<zzaly>) zzaly.class, zzalyVar);
    }

    private zzaly() {
    }

    public static zza zzc() {
        return zzc.zzl();
    }

    public final int zza() {
        return this.zzf;
    }

    public final long zzb() {
        return this.zze;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzama zzamaVar = null;
        switch (zzama.zza[i4 - 1]) {
            case 1:
                return new zzaly();
            case 2:
                return new zza(zzamaVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u0002\u0002\u0004", new Object[]{"zze", "zzf"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzaly> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzaly.class) {
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
        this.zzf = i4;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(long j4) {
        this.zze = j4;
    }
}
