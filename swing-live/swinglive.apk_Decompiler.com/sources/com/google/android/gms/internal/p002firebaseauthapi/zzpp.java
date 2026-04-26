package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzpp extends zzqs {
    private final int zza;
    private final int zzb;
    private final zzb zzc;

    public static final class zza {
        private Integer zza;
        private Integer zzb;
        private zzb zzc;

        public final zza zza(int i4) throws InvalidAlgorithmParameterException {
            if (i4 != 16 && i4 != 32) {
                throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 128-bit and 256-bit AES keys are supported", Integer.valueOf(i4 << 3)));
            }
            this.zza = Integer.valueOf(i4);
            return this;
        }

        public final zza zzb(int i4) throws GeneralSecurityException {
            if (i4 < 10 || 16 < i4) {
                throw new GeneralSecurityException(S.d(i4, "Invalid tag size for AesCmacParameters: "));
            }
            this.zzb = Integer.valueOf(i4);
            return this;
        }

        private zza() {
            this.zza = null;
            this.zzb = null;
            this.zzc = zzb.zzd;
        }

        public final zza zza(zzb zzbVar) {
            this.zzc = zzbVar;
            return this;
        }

        public final zzpp zza() throws GeneralSecurityException {
            Integer num = this.zza;
            if (num != null) {
                if (this.zzb != null) {
                    if (this.zzc != null) {
                        return new zzpp(num.intValue(), this.zzb.intValue(), this.zzc);
                    }
                    throw new GeneralSecurityException("variant not set");
                }
                throw new GeneralSecurityException("tag size not set");
            }
            throw new GeneralSecurityException("key size not set");
        }
    }

    public static final class zzb {
        public static final zzb zza = new zzb("TINK");
        public static final zzb zzb = new zzb("CRUNCHY");
        public static final zzb zzc = new zzb("LEGACY");
        public static final zzb zzd = new zzb("NO_PREFIX");
        private final String zze;

        private zzb(String str) {
            this.zze = str;
        }

        public final String toString() {
            return this.zze;
        }
    }

    public static zza zzd() {
        return new zza();
    }

    private final int zzf() {
        zzb zzbVar = this.zzc;
        if (zzbVar == zzb.zzd) {
            return this.zzb;
        }
        if (zzbVar != zzb.zza && zzbVar != zzb.zzb && zzbVar != zzb.zzc) {
            throw new IllegalStateException("Unknown variant");
        }
        int i4 = this.zzb;
        return i4 + 5;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzpp)) {
            return false;
        }
        zzpp zzppVar = (zzpp) obj;
        return zzppVar.zza == this.zza && zzppVar.zzf() == zzf() && zzppVar.zzc == this.zzc;
    }

    public final int hashCode() {
        return Objects.hash(zzpp.class, Integer.valueOf(this.zza), Integer.valueOf(this.zzb), this.zzc);
    }

    public final String toString() {
        String strValueOf = String.valueOf(this.zzc);
        int i4 = this.zzb;
        int i5 = this.zza;
        StringBuilder sb = new StringBuilder("AES-CMAC Parameters (variant: ");
        sb.append(strValueOf);
        sb.append(", ");
        sb.append(i4);
        sb.append("-byte tags, and ");
        return a.n(sb, i5, "-byte key)");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return this.zzc != zzb.zzd;
    }

    public final int zzb() {
        return this.zzb;
    }

    public final int zzc() {
        return this.zza;
    }

    public final zzb zze() {
        return this.zzc;
    }

    private zzpp(int i4, int i5, zzb zzbVar) {
        this.zza = i4;
        this.zzb = i5;
        this.zzc = zzbVar;
    }
}
