package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzvz extends zzaja<zzvz, zza> implements zzakm {
    private static final zzvz zzc;
    private static volatile zzakx<zzvz> zzd;
    private int zze;

    public static final class zza extends zzaja.zzb<zzvz, zza> implements zzakm {
        private zza() {
            super(zzvz.zzc);
        }

        public /* synthetic */ zza(zzvy zzvyVar) {
            this();
        }
    }

    static {
        zzvz zzvzVar = new zzvz();
        zzc = zzvzVar;
        zzaja.zza((Class<zzvz>) zzvz.class, zzvzVar);
    }

    private zzvz() {
    }

    public static zzvz zzc() {
        return zzc;
    }

    public final int zza() {
        return this.zze;
    }

    public static zzvz zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzvz) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzvy zzvyVar = null;
        switch (zzvy.zza[i4 - 1]) {
            case 1:
                return new zzvz();
            case 2:
                return new zza(zzvyVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0000\u0000\u0001\u000b", new Object[]{"zze"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzvz> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzvz.class) {
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
}
