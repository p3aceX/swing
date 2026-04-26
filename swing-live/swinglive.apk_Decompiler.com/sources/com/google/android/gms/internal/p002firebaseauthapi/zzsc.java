package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzsc extends zzaja<zzsc, zza> implements zzakm {
    private static final zzsc zzc;
    private static volatile zzakx<zzsc> zzd;
    private int zze;

    public static final class zza extends zzaja.zzb<zzsc, zza> implements zzakm {
        private zza() {
            super(zzsc.zzc);
        }

        public final zza zza(int i4) {
            zzh();
            ((zzsc) this.zza).zza(i4);
            return this;
        }

        public /* synthetic */ zza(zzsb zzsbVar) {
            this();
        }
    }

    static {
        zzsc zzscVar = new zzsc();
        zzc = zzscVar;
        zzaja.zza((Class<zzsc>) zzsc.class, zzscVar);
    }

    private zzsc() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public static zzsc zzd() {
        return zzc;
    }

    public final int zza() {
        return this.zze;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzsb zzsbVar = null;
        switch (zzsb.zza[i4 - 1]) {
            case 1:
                return new zzsc();
            case 2:
                return new zza(zzsbVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0000\u0000\u0001\u000b", new Object[]{"zze"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzsc> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzsc.class) {
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
