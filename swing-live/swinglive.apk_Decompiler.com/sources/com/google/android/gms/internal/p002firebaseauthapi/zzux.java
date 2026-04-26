package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzux extends zzaja<zzux, zza> implements zzakm {
    private static final zzux zzc;
    private static volatile zzakx<zzux> zzd;
    private String zze = "";
    private zzahm zzf = zzahm.zza;
    private int zzg;

    public static final class zza extends zzaja.zzb<zzux, zza> implements zzakm {
        private zza() {
            super(zzux.zzc);
        }

        public final zza zza(zzb zzbVar) {
            zzh();
            ((zzux) this.zza).zza(zzbVar);
            return this;
        }

        public /* synthetic */ zza(zzuy zzuyVar) {
            this();
        }

        public final zza zza(String str) {
            zzh();
            ((zzux) this.zza).zza(str);
            return this;
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzux) this.zza).zza(zzahmVar);
            return this;
        }
    }

    static {
        zzux zzuxVar = new zzux();
        zzc = zzuxVar;
        zzaja.zza((Class<zzux>) zzux.class, zzuxVar);
    }

    private zzux() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    public static zzux zzd() {
        return zzc;
    }

    public final zzb zzb() {
        zzb zzbVarZza = zzb.zza(this.zzg);
        return zzbVarZza == null ? zzb.UNRECOGNIZED : zzbVarZza;
    }

    public final zzahm zze() {
        return this.zzf;
    }

    public final String zzf() {
        return this.zze;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzuy zzuyVar = null;
        switch (zzuy.zza[i4 - 1]) {
            case 1:
                return new zzux();
            case 2:
                return new zza(zzuyVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001Ȉ\u0002\n\u0003\f", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzux> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzux.class) {
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

    public enum zzb implements zzajf {
        UNKNOWN_KEYMATERIAL(0),
        SYMMETRIC(1),
        ASYMMETRIC_PRIVATE(2),
        ASYMMETRIC_PUBLIC(3),
        REMOTE(4),
        UNRECOGNIZED(-1);

        private static final zzaje<zzb> zzg = new zzuz();
        private final int zzi;

        zzb(int i4) {
            this.zzi = i4;
        }

        @Override // java.lang.Enum
        public final String toString() {
            StringBuilder sb = new StringBuilder("<");
            sb.append(zzb.class.getName());
            sb.append('@');
            sb.append(Integer.toHexString(System.identityHashCode(this)));
            if (this != UNRECOGNIZED) {
                sb.append(" number=");
                sb.append(zza());
            }
            sb.append(" name=");
            sb.append(name());
            sb.append('>');
            return sb.toString();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajf
        public final int zza() {
            if (this != UNRECOGNIZED) {
                return this.zzi;
            }
            throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
        }

        public static zzb zza(int i4) {
            if (i4 == 0) {
                return UNKNOWN_KEYMATERIAL;
            }
            if (i4 == 1) {
                return SYMMETRIC;
            }
            if (i4 == 2) {
                return ASYMMETRIC_PRIVATE;
            }
            if (i4 == 3) {
                return ASYMMETRIC_PUBLIC;
            }
            if (i4 != 4) {
                return null;
            }
            return REMOTE;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzb zzbVar) {
        this.zzg = zzbVar.zza();
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
