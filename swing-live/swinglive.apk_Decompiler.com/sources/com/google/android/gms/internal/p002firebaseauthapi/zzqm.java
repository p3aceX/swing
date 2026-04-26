package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzqm extends zzqs {
    private final int zza;
    private final int zzb;
    private final zzc zzc;
    private final zzb zzd;

    public static final class zza {
        private Integer zza;
        private Integer zzb;
        private zzb zzc;
        private zzc zzd;

        public final zza zza(zzb zzbVar) {
            this.zzc = zzbVar;
            return this;
        }

        public final zza zzb(int i4) {
            this.zzb = Integer.valueOf(i4);
            return this;
        }

        private zza() {
            this.zza = null;
            this.zzb = null;
            this.zzc = null;
            this.zzd = zzc.zzd;
        }

        public final zza zza(int i4) {
            this.zza = Integer.valueOf(i4);
            return this;
        }

        public final zza zza(zzc zzcVar) {
            this.zzd = zzcVar;
            return this;
        }

        public final zzqm zza() throws GeneralSecurityException {
            Integer num = this.zza;
            if (num != null) {
                if (this.zzb != null) {
                    if (this.zzc != null) {
                        if (this.zzd != null) {
                            if (num.intValue() >= 16) {
                                Integer num2 = this.zzb;
                                int iIntValue = num2.intValue();
                                zzb zzbVar = this.zzc;
                                if (iIntValue >= 10) {
                                    if (zzbVar == zzb.zza) {
                                        if (iIntValue > 20) {
                                            throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 20 bytes for SHA1", num2));
                                        }
                                    } else if (zzbVar == zzb.zzb) {
                                        if (iIntValue > 28) {
                                            throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 28 bytes for SHA224", num2));
                                        }
                                    } else if (zzbVar == zzb.zzc) {
                                        if (iIntValue > 32) {
                                            throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 32 bytes for SHA256", num2));
                                        }
                                    } else if (zzbVar == zzb.zzd) {
                                        if (iIntValue > 48) {
                                            throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 48 bytes for SHA384", num2));
                                        }
                                    } else {
                                        if (zzbVar != zzb.zze) {
                                            throw new GeneralSecurityException("unknown hash type; must be SHA256, SHA384 or SHA512");
                                        }
                                        if (iIntValue > 64) {
                                            throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; can be at most 64 bytes for SHA512", num2));
                                        }
                                    }
                                    return new zzqm(this.zza.intValue(), this.zzb.intValue(), this.zzd, this.zzc);
                                }
                                throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; must be at least 10 bytes", num2));
                            }
                            throw new InvalidAlgorithmParameterException(String.format("Invalid key size in bytes %d; must be at least 16 bytes", this.zza));
                        }
                        throw new GeneralSecurityException("variant is not set");
                    }
                    throw new GeneralSecurityException("hash type is not set");
                }
                throw new GeneralSecurityException("tag size is not set");
            }
            throw new GeneralSecurityException("key size is not set");
        }
    }

    public static final class zzb {
        public static final zzb zza = new zzb("SHA1");
        public static final zzb zzb = new zzb("SHA224");
        public static final zzb zzc = new zzb("SHA256");
        public static final zzb zzd = new zzb("SHA384");
        public static final zzb zze = new zzb("SHA512");
        private final String zzf;

        private zzb(String str) {
            this.zzf = str;
        }

        public final String toString() {
            return this.zzf;
        }
    }

    public static final class zzc {
        public static final zzc zza = new zzc("TINK");
        public static final zzc zzb = new zzc("CRUNCHY");
        public static final zzc zzc = new zzc("LEGACY");
        public static final zzc zzd = new zzc("NO_PREFIX");
        private final String zze;

        private zzc(String str) {
            this.zze = str;
        }

        public final String toString() {
            return this.zze;
        }
    }

    public static zza zzd() {
        return new zza();
    }

    private final int zzg() {
        zzc zzcVar = this.zzc;
        if (zzcVar == zzc.zzd) {
            return this.zzb;
        }
        if (zzcVar != zzc.zza && zzcVar != zzc.zzb && zzcVar != zzc.zzc) {
            throw new IllegalStateException("Unknown variant");
        }
        int i4 = this.zzb;
        return i4 + 5;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzqm)) {
            return false;
        }
        zzqm zzqmVar = (zzqm) obj;
        return zzqmVar.zza == this.zza && zzqmVar.zzg() == zzg() && zzqmVar.zzc == this.zzc && zzqmVar.zzd == this.zzd;
    }

    public final int hashCode() {
        return Objects.hash(zzqm.class, Integer.valueOf(this.zza), Integer.valueOf(this.zzb), this.zzc, this.zzd);
    }

    public final String toString() {
        return "HMAC Parameters (variant: " + String.valueOf(this.zzc) + ", hashType: " + String.valueOf(this.zzd) + ", " + this.zzb + "-byte tags, and " + this.zza + "-byte key)";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return this.zzc != zzc.zzd;
    }

    public final int zzb() {
        return this.zzb;
    }

    public final int zzc() {
        return this.zza;
    }

    public final zzb zze() {
        return this.zzd;
    }

    public final zzc zzf() {
        return this.zzc;
    }

    private zzqm(int i4, int i5, zzc zzcVar, zzb zzbVar) {
        this.zza = i4;
        this.zzb = i5;
        this.zzc = zzcVar;
        this.zzd = zzbVar;
    }
}
