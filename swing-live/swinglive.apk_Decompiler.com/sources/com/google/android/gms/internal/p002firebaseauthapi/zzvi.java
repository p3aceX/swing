package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
public final class zzvi extends zzaja<zzvi, zza> implements zzakm {
    private static final zzvi zzc;
    private static volatile zzakx<zzvi> zzd;
    private int zze;
    private zzajg<zzb> zzf = zzaja.zzo();

    public static final class zza extends zzaja.zzb<zzvi, zza> implements zzakm {
        private zza() {
            super(zzvi.zzc);
        }

        public final zza zza(zzb zzbVar) {
            zzh();
            ((zzvi) this.zza).zza(zzbVar);
            return this;
        }

        public /* synthetic */ zza(zzvj zzvjVar) {
            this();
        }

        public final zza zza(int i4) {
            zzh();
            ((zzvi) this.zza).zzc(i4);
            return this;
        }
    }

    public static final class zzb extends zzaja<zzb, zza> implements zzakm {
        private static final zzb zzc;
        private static volatile zzakx<zzb> zzd;
        private String zze = "";
        private int zzf;
        private int zzg;
        private int zzh;

        public static final class zza extends zzaja.zzb<zzb, zza> implements zzakm {
            private zza() {
                super(zzb.zzc);
            }

            public final zza zza(int i4) {
                zzh();
                ((zzb) this.zza).zza(i4);
                return this;
            }

            public /* synthetic */ zza(zzvj zzvjVar) {
                this();
            }

            public final zza zza(zzvt zzvtVar) {
                zzh();
                ((zzb) this.zza).zza(zzvtVar);
                return this;
            }

            public final zza zza(zzvb zzvbVar) {
                zzh();
                ((zzb) this.zza).zza(zzvbVar);
                return this;
            }

            public final zza zza(String str) {
                zzh();
                ((zzb) this.zza).zza(str);
                return this;
            }
        }

        static {
            zzb zzbVar = new zzb();
            zzc = zzbVar;
            zzaja.zza((Class<zzb>) zzb.class, zzbVar);
        }

        private zzb() {
        }

        public static zza zzb() {
            return zzc.zzl();
        }

        public final int zza() {
            return this.zzg;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
        public final Object zza(int i4, Object obj, Object obj2) {
            zzakx zzaVar;
            zzvj zzvjVar = null;
            switch (zzvj.zza[i4 - 1]) {
                case 1:
                    return new zzb();
                case 2:
                    return new zza(zzvjVar);
                case 3:
                    return zzaja.zza(zzc, "\u0000\u0004\u0000\u0000\u0001\u0004\u0004\u0000\u0000\u0000\u0001Ȉ\u0002\f\u0003\u000b\u0004\f", new Object[]{"zze", "zzf", "zzg", "zzh"});
                case 4:
                    return zzc;
                case 5:
                    zzakx<zzb> zzakxVar = zzd;
                    if (zzakxVar != null) {
                        return zzakxVar;
                    }
                    synchronized (zzb.class) {
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
        public final void zza(zzvt zzvtVar) {
            this.zzh = zzvtVar.zza();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public final void zza(zzvb zzvbVar) {
            this.zzf = zzvbVar.zza();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public final void zza(String str) {
            str.getClass();
            this.zze = str;
        }
    }

    static {
        zzvi zzviVar = new zzvi();
        zzc = zzviVar;
        zzaja.zza((Class<zzvi>) zzvi.class, zzviVar);
    }

    private zzvi() {
    }

    public static zza zza() {
        return zzc.zzl();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzc(int i4) {
        this.zze = i4;
    }

    public final zzb zza(int i4) {
        return this.zzf.get(0);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaja
    public final Object zza(int i4, Object obj, Object obj2) {
        zzakx zzaVar;
        zzvj zzvjVar = null;
        switch (zzvj.zza[i4 - 1]) {
            case 1:
                return new zzvi();
            case 2:
                return new zza(zzvjVar);
            case 3:
                return zzaja.zza(zzc, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0001\u0000\u0001\u000b\u0002\u001b", new Object[]{"zze", "zzf", zzb.class});
            case 4:
                return zzc;
            case 5:
                zzakx<zzvi> zzakxVar = zzd;
                if (zzakxVar != null) {
                    return zzakxVar;
                }
                synchronized (zzvi.class) {
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
    public final void zza(zzb zzbVar) {
        zzbVar.getClass();
        zzajg<zzb> zzajgVar = this.zzf;
        if (!zzajgVar.zzc()) {
            this.zzf = zzaja.zza(zzajgVar);
        }
        this.zzf.add(zzbVar);
    }
}
