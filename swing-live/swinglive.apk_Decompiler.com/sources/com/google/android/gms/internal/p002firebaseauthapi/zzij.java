package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zziq;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzij extends zziv {
    private final zziq zza;
    private final zzxt zzb;
    private final zzxr zzc;
    private final Integer zzd;

    public static class zza {
        private zziq zza;
        private zzxt zzb;
        private Integer zzc;

        public final zza zza(Integer num) {
            this.zzc = num;
            return this;
        }

        private zza() {
            this.zza = null;
            this.zzb = null;
            this.zzc = null;
        }

        public final zza zza(zzxt zzxtVar) {
            this.zzb = zzxtVar;
            return this;
        }

        public final zza zza(zziq zziqVar) {
            this.zza = zziqVar;
            return this;
        }

        public final zzij zza() throws GeneralSecurityException {
            zzxr zzxrVarJ;
            zziq zziqVar = this.zza;
            if (zziqVar != null && this.zzb != null) {
                if (zziqVar.zzb() == this.zzb.zza()) {
                    if (this.zza.zza() && this.zzc == null) {
                        throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
                    }
                    if (!this.zza.zza() && this.zzc != null) {
                        throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
                    }
                    if (this.zza.zzd() == zziq.zzb.zzc) {
                        zzxrVarJ = zzxr.zza(new byte[0]);
                    } else if (this.zza.zzd() == zziq.zzb.zzb) {
                        zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 0));
                    } else if (this.zza.zzd() == zziq.zzb.zza) {
                        zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 1));
                    } else {
                        throw new IllegalStateException("Unknown AesSivParameters.Variant: ".concat(String.valueOf(this.zza.zzd())));
                    }
                    return new zzij(this.zza, this.zzb, zzxrVarJ, this.zzc);
                }
                throw new GeneralSecurityException("Key size mismatch");
            }
            throw new IllegalArgumentException("Cannot build without parameters and/or key material");
        }
    }

    public static zza zzb() {
        return new zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
    public final Integer zza() {
        return this.zzd;
    }

    public final zziq zzc() {
        return this.zza;
    }

    public final zzxr zzd() {
        return this.zzc;
    }

    public final zzxt zze() {
        return this.zzb;
    }

    private zzij(zziq zziqVar, zzxt zzxtVar, zzxr zzxrVar, Integer num) {
        this.zza = zziqVar;
        this.zzb = zzxtVar;
        this.zzc = zzxrVar;
        this.zzd = num;
    }
}
