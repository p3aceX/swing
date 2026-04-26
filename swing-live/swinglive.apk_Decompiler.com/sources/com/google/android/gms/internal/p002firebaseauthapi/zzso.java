package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzso extends zzaja<zzso, zza> implements zzakm {
    private static final zzso zzc;
    private static volatile zzakx<zzso> zzd;
    private int zze;
    private int zzf;
    private zzss zzg;
    private zzahm zzh = zzahm.zza;

    public static final class zza extends zzaja.zzb<zzso, zza> implements zzakm {
        private zza() {
            super(zzso.zzc);
        }

        public final zza zza(zzahm zzahmVar) {
            zzh();
            ((zzso) this.zza).zza(zzahmVar);
            return this;
        }

        public /* synthetic */ zza(zzsn zzsnVar) {
            this();
        }

        public final zza zza(zzss zzssVar) {
            zzh();
            ((zzso) this.zza).zza(zzssVar);
            return this;
        }
    }

    static {
        zzso zzsoVar = new zzso();
        zzc = zzsoVar;
        zzaja.zza((Class<zzso>) zzso.class, zzsoVar);
    }

    private zzso() {
    }

    public static zza zzb() {
        return zzc.zzl();
    }

    public static zzakx<zzso> zzf() {
        return (zzakx) zzc.zza(zzaja.zze.zzg, (Object) null, (Object) null);
    }

    public final int zza() {
        return this.zzf;
    }

    public final zzss zzd() {
        zzss zzssVar = this.zzg;
        return zzssVar == null ? zzss.zzd() : zzssVar;
    }

    public final zzahm zze() {
        return this.zzh;
    }

    public static zzso zza(zzahm zzahmVar, zzaip zzaipVar) {
        return (zzso) zzaja.zza(zzc, zzahmVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzsn zzsnVar = null;
        switch (zzsn.zza[i4 - 1]) {
            case 1:
                return new zzso();
            case 2:
                return new zza(zzsnVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000\u0003\n", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzakx<zzso> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzso.class) {
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
        this.zzh = zzahmVar;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzss zzssVar) {
        zzssVar.getClass();
        this.zzg = zzssVar;
        this.zze |= 1;
    }
}
