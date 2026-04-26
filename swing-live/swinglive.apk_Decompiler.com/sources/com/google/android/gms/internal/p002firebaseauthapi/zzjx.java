package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzjx extends zzkp {
    private final zzd zza;
    private final zze zzb;
    private final zza zzc;
    private final zzf zzd;

    public static final class zza extends zzb {
        public static final zza zza = new zza("AES_128_GCM", 1);
        public static final zza zzb = new zza("AES_256_GCM", 2);
        public static final zza zzc = new zza("CHACHA20_POLY1305", 3);

        private zza(String str, int i4) {
            super(str, i4);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzjx.zzb
        public final /* bridge */ /* synthetic */ String toString() {
            return super.toString();
        }
    }

    public static class zzb {
        private final String zza;
        private final int zzb;

        public String toString() {
            return String.format("%s(0x%04x)", this.zza, Integer.valueOf(this.zzb));
        }

        private zzb(String str, int i4) {
            this.zza = str;
            this.zzb = i4;
        }
    }

    public static final class zzc {
        private zzd zza;
        private zze zzb;
        private zza zzc;
        private zzf zzd;

        public final zzc zza(zza zzaVar) {
            this.zzc = zzaVar;
            return this;
        }

        private zzc() {
            this.zza = null;
            this.zzb = null;
            this.zzc = null;
            this.zzd = zzf.zzc;
        }

        public final zzc zza(zze zzeVar) {
            this.zzb = zzeVar;
            return this;
        }

        public final zzc zza(zzd zzdVar) {
            this.zza = zzdVar;
            return this;
        }

        public final zzc zza(zzf zzfVar) {
            this.zzd = zzfVar;
            return this;
        }

        public final zzjx zza() throws GeneralSecurityException {
            zzd zzdVar = this.zza;
            if (zzdVar != null) {
                zze zzeVar = this.zzb;
                if (zzeVar != null) {
                    zza zzaVar = this.zzc;
                    if (zzaVar != null) {
                        zzf zzfVar = this.zzd;
                        if (zzfVar != null) {
                            return new zzjx(zzdVar, zzeVar, zzaVar, zzfVar);
                        }
                        throw new GeneralSecurityException("HPKE variant is not set");
                    }
                    throw new GeneralSecurityException("HPKE AEAD parameter is not set");
                }
                throw new GeneralSecurityException("HPKE KDF parameter is not set");
            }
            throw new GeneralSecurityException("HPKE KEM parameter is not set");
        }
    }

    public static final class zzd extends zzb {
        public static final zzd zza = new zzd("DHKEM_P256_HKDF_SHA256", 16);
        public static final zzd zzb = new zzd("DHKEM_P384_HKDF_SHA384", 17);
        public static final zzd zzc = new zzd("DHKEM_P521_HKDF_SHA512", 18);
        public static final zzd zzd = new zzd("DHKEM_X25519_HKDF_SHA256", 32);

        private zzd(String str, int i4) {
            super(str, i4);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzjx.zzb
        public final /* bridge */ /* synthetic */ String toString() {
            return super.toString();
        }
    }

    public static final class zze extends zzb {
        public static final zze zza = new zze("HKDF_SHA256", 1);
        public static final zze zzb = new zze("HKDF_SHA384", 2);
        public static final zze zzc = new zze("HKDF_SHA512", 3);

        private zze(String str, int i4) {
            super(str, i4);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzjx.zzb
        public final /* bridge */ /* synthetic */ String toString() {
            return super.toString();
        }
    }

    public static final class zzf {
        public static final zzf zza = new zzf("TINK");
        public static final zzf zzb = new zzf("CRUNCHY");
        public static final zzf zzc = new zzf("NO_PREFIX");
        private final String zzd;

        private zzf(String str) {
            this.zzd = str;
        }

        public final String toString() {
            return this.zzd;
        }
    }

    public static zzc zzc() {
        return new zzc();
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzjx)) {
            return false;
        }
        zzjx zzjxVar = (zzjx) obj;
        return this.zza == zzjxVar.zza && this.zzb == zzjxVar.zzb && this.zzc == zzjxVar.zzc && this.zzd == zzjxVar.zzd;
    }

    public final int hashCode() {
        return Objects.hash(zzjx.class, this.zza, this.zzb, this.zzc, this.zzd);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return this.zzd != zzf.zzc;
    }

    public final zza zzb() {
        return this.zzc;
    }

    public final zze zzd() {
        return this.zzb;
    }

    public final zzd zze() {
        return this.zza;
    }

    public final zzf zzf() {
        return this.zzd;
    }

    private zzjx(zzd zzdVar, zze zzeVar, zza zzaVar, zzf zzfVar) {
        this.zza = zzdVar;
        this.zzb = zzeVar;
        this.zzc = zzaVar;
        this.zzd = zzfVar;
    }
}
