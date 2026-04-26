package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzuf extends zzaja<zzuf, zza> implements zzakm {
    private static final zzuf zzc;
    private static volatile zzakx<zzuf> zzd;
    private int zze;
    private zzui zzf;
    private int zzg;
    private int zzh;

    public static final class zza extends zzaja.zzb<zzuf, zza> implements zzakm {
        private zza() {
            super(zzuf.zzc);
        }

        public final zza zza(int i4) {
            zzh();
            ((zzuf) this.zza).zza(i4);
            return this;
        }

        public /* synthetic */ zza(zzug zzugVar) {
            this();
        }

        public final zza zza(zzui zzuiVar) {
            zzh();
            ((zzuf) this.zza).zza(zzuiVar);
            return this;
        }
    }

    static {
        zzuf zzufVar = new zzuf();
        zzc = zzufVar;
        zzaja.zza((Class<zzuf>) zzuf.class, zzufVar);
    }

    private zzuf() {
    }

    public static zza zzc() {
        return zzc.zzl();
    }

    public static zzuf zze() {
        return zzc;
    }

    public final int zza() {
        return this.zzg;
    }

    public final int zzb() {
        return this.zzh;
    }

    public final zzui zzf() {
        zzui zzuiVar = this.zzf;
        return zzuiVar == null ? zzui.zze() : zzuiVar;
    }

    public static zzuf zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzuf) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzug zzugVar = null;
        switch (zzug.zza[i4 - 1]) {
            case 1:
                return new zzuf();
            case 2:
                return new zza(zzugVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001ဉ\u0000\u0002\u000b\u0003\u000b", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzuf> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzuf.class) {
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
        this.zzg = i4;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzui zzuiVar) {
        zzuiVar.getClass();
        this.zzf = zzuiVar;
        this.zze |= 1;
    }
}
