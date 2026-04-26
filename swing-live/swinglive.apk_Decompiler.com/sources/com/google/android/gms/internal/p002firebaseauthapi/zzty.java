package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class zzty extends zzaja<zzty, zza> implements zzakm {
    private static final zzty zzc;
    private static volatile zzakx<zzty> zzd;
    private int zze;
    private zzahm zzf = zzahm.zza;
    private zzvi zzg;

    public static final class zza extends zzaja.zzb<zzty, zza> implements zzakm {
        private zza() {
            super(zzty.zzc);
        }

        public final zza zza() {
            zzh();
            ((zzty) this.zza).zzd();
            return this;
        }

        public /* synthetic */ zza(zzua zzuaVar) {
            this();
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzty) this.zza).zza(zzahmVar);
            return this;
        }

        public final zza zza(zzvi zzviVar) {
            zzh();
            ((zzty) this.zza).zza(zzviVar);
            return this;
        }
    }

    static {
        zzty zztyVar = new zzty();
        zzc = zztyVar;
        zzaja.zza((Class<zzty>) zzty.class, zztyVar);
    }

    private zzty() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzd() {
        this.zzg = null;
        this.zze &= -2;
    }

    public final zzahm zzc() {
        return this.zzf;
    }

    public static zzty zza(InputStream inputStream, zzaip zzaipVar) {
        return (zzty) zzaja.zza(zzc, inputStream, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzua zzuaVar = null;
        switch (zzua.zza[i4 - 1]) {
            case 1:
                return new zzty();
            case 2:
                return new zza(zzuaVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0001\u0002\u0003\u0002\u0000\u0000\u0000\u0002\n\u0003ဉ\u0000", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzty> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzty.class) {
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

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzvi zzviVar) {
        zzviVar.getClass();
        this.zzg = zzviVar;
        this.zze |= 1;
    }
}
