package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzvd extends zzaja<zzvd, zza> implements zzakm {
    private static final zzvd zzc;
    private static volatile zzakx<zzvd> zzd;
    private String zze = "";
    private zzahm zzf = zzahm.zza;
    private int zzg;

    public static final class zza extends zzaja.zzb<zzvd, zza> implements zzakm {
        private zza() {
            super(zzvd.zzc);
        }

        public final zza zza(zzvt zzvtVar) {
            zzh();
            ((zzvd) this.zza).zza(zzvtVar);
            return this;
        }

        public /* synthetic */ zza(zzvc zzvcVar) {
            this();
        }

        public final zza zza(String str) {
            zzh();
            ((zzvd) this.zza).zza(str);
            return this;
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzvd) this.zza).zza(zzahmVar);
            return this;
        }
    }

    static {
        zzvd zzvdVar = new zzvd();
        zzc = zzvdVar;
        zzaja.zza((Class<zzvd>) zzvd.class, zzvdVar);
    }

    private zzvd() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    public static zzvd zzc() {
        return zzc;
    }

    public final zzvt zzd() {
        zzvt zzvtVarZza = zzvt.zza(this.zzg);
        return zzvtVarZza == null ? zzvt.UNRECOGNIZED : zzvtVarZza;
    }

    public final zzahm zze() {
        return this.zzf;
    }

    public final String zzf() {
        return this.zze;
    }

    public static zzvd zza(byte[] bArr, zzaip zzaipVar) {
        return (zzvd) zzaja.zza(zzc, bArr, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzvc zzvcVar = null;
        switch (zzvc.zza[i4 - 1]) {
            case 1:
                return new zzvd();
            case 2:
                return new zza(zzvcVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001Ȉ\u0002\n\u0003\f", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzvd> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzvd.class) {
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
    public final void zza(zzvt zzvtVar) {
        this.zzg = zzvtVar.zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(String str) {
        str.getClass();
        this.zze = str;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzahm zzahmVar) {
        zzahmVar.getClass();
        this.zzf = zzahmVar;
    }
}
