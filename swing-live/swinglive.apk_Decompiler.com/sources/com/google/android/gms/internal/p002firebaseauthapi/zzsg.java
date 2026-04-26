package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzsg extends zzaja<zzsg, zza> implements zzakm {
    private static final zzsg zzc;
    private static volatile zzakx<zzsg> zzd;
    private int zze;
    private zzsk zzf;
    private zzuf zzg;

    public static final class zza extends zzaja.zzb<zzsg, zza> implements zzakm {
        private zza() {
            super(zzsg.zzc);
        }

        public final zza zza(zzsk zzskVar) {
            zzh();
            ((zzsg) this.zza).zza(zzskVar);
            return this;
        }

        public /* synthetic */ zza(zzsf zzsfVar) {
            this();
        }

        public final zza zza(zzuf zzufVar) {
            zzh();
            ((zzsg) this.zza).zza(zzufVar);
            return this;
        }
    }

    static {
        zzsg zzsgVar = new zzsg();
        zzc = zzsgVar;
        zzaja.zza((Class<zzsg>) zzsg.class, zzsgVar);
    }

    private zzsg() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    public final zzsk zzc() {
        zzsk zzskVar = this.zzf;
        return zzskVar == null ? zzsk.zzd() : zzskVar;
    }

    public final zzuf zzd() {
        zzuf zzufVar = this.zzg;
        return zzufVar == null ? zzuf.zze() : zzufVar;
    }

    public static zzsg zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzsg) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzsf zzsfVar = null;
        switch (zzsf.zza[i4 - 1]) {
            case 1:
                return new zzsg();
            case 2:
                return new zza(zzsfVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001ဉ\u0000\u0002ဉ\u0001", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzsg> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzsg.class) {
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
    public final void zza(zzsk zzskVar) {
        zzskVar.getClass();
        this.zzf = zzskVar;
        this.zze |= 1;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzuf zzufVar) {
        zzufVar.getClass();
        this.zzg = zzufVar;
        this.zze |= 2;
    }
}
