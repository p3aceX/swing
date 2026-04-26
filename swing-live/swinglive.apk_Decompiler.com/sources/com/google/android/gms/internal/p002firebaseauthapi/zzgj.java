package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzgj extends zzdc {
    private final String zza;
    private final zzb zzb;
    private final zzdc zzc;

    public static class zza {
        private String zza;
        private zzb zzb;
        private zzdc zzc;

        private zza() {
        }

        public final zza zza(zzdc zzdcVar) {
            this.zzc = zzdcVar;
            return this;
        }

        public final zza zza(zzb zzbVar) {
            this.zzb = zzbVar;
            return this;
        }

        public final zza zza(String str) {
            this.zza = str;
            return this;
        }

        public final zzgj zza() throws GeneralSecurityException {
            if (this.zza != null) {
                if (this.zzb != null) {
                    zzdc zzdcVar = this.zzc;
                    if (zzdcVar != null) {
                        if (!zzdcVar.zza()) {
                            zzb zzbVar = this.zzb;
                            zzdc zzdcVar2 = this.zzc;
                            if ((zzbVar.equals(zzb.zza) && (zzdcVar2 instanceof zzer)) || ((zzbVar.equals(zzb.zzc) && (zzdcVar2 instanceof zzfo)) || ((zzbVar.equals(zzb.zzb) && (zzdcVar2 instanceof zzhd)) || ((zzbVar.equals(zzb.zzd) && (zzdcVar2 instanceof zzdm)) || ((zzbVar.equals(zzb.zze) && (zzdcVar2 instanceof zzea)) || (zzbVar.equals(zzb.zzf) && (zzdcVar2 instanceof zzfa))))))) {
                                return new zzgj(this.zza, this.zzb, this.zzc);
                            }
                            throw new GeneralSecurityException("Cannot use parsing strategy " + this.zzb.toString() + " when new keys are picked according to " + String.valueOf(this.zzc) + ".");
                        }
                        throw new GeneralSecurityException("dekParametersForNewKeys must note have ID Requirements");
                    }
                    throw new GeneralSecurityException("dekParametersForNewKeys must be set");
                }
                throw new GeneralSecurityException("dekParsingStrategy must be set");
            }
            throw new GeneralSecurityException("kekUri must be set");
        }
    }

    public static final class zzb {
        public static final zzb zza = new zzb("ASSUME_AES_GCM");
        public static final zzb zzb = new zzb("ASSUME_XCHACHA20POLY1305");
        public static final zzb zzc = new zzb("ASSUME_CHACHA20POLY1305");
        public static final zzb zzd = new zzb("ASSUME_AES_CTR_HMAC");
        public static final zzb zze = new zzb("ASSUME_AES_EAX");
        public static final zzb zzf = new zzb("ASSUME_AES_GCM_SIV");
        private final String zzg;

        private zzb(String str) {
            this.zzg = str;
        }

        public final String toString() {
            return this.zzg;
        }
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzgj)) {
            return false;
        }
        zzgj zzgjVar = (zzgj) obj;
        return zzgjVar.zzb.equals(this.zzb) && zzgjVar.zzc.equals(this.zzc) && zzgjVar.zza.equals(this.zza);
    }

    public final int hashCode() {
        return Objects.hash(zzgj.class, this.zza, this.zzb, this.zzc);
    }

    public final String toString() {
        String str = this.zza;
        String strValueOf = String.valueOf(this.zzb);
        String strValueOf2 = String.valueOf(this.zzc);
        StringBuilder sb = new StringBuilder("LegacyKmsEnvelopeAead Parameters (kekUri: ");
        sb.append(str);
        sb.append(", dekParsingStrategy: ");
        sb.append(strValueOf);
        sb.append(", dekParametersForNewKeys: ");
        return S.h(sb, strValueOf2, ")");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return false;
    }

    public final zzdc zzb() {
        return this.zzc;
    }

    public final String zzc() {
        return this.zza;
    }

    private zzgj(String str, zzb zzbVar, zzdc zzdcVar) {
        this.zza = str;
        this.zzb = zzbVar;
        this.zzc = zzdcVar;
    }
}
