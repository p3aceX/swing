package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzpp;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzpi extends zzqp {
    private final zzpp zza;
    private final zzxt zzb;
    private final zzxr zzc;
    private final Integer zzd;

    public static class zza {
        private zzpp zza;
        private zzxt zzb;
        private Integer zzc;

        public final zza zza(zzxt zzxtVar) {
            this.zzb = zzxtVar;
            return this;
        }

        private zza() {
            this.zza = null;
            this.zzb = null;
            this.zzc = null;
        }

        public final zza zza(Integer num) {
            this.zzc = num;
            return this;
        }

        public final zza zza(zzpp zzppVar) {
            this.zza = zzppVar;
            return this;
        }

        public final zzpi zza() throws GeneralSecurityException {
            zzxr zzxrVarJ;
            zzpp zzppVar = this.zza;
            if (zzppVar != null && this.zzb != null) {
                if (zzppVar.zzc() == this.zzb.zza()) {
                    if (this.zza.zza() && this.zzc == null) {
                        throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
                    }
                    if (!this.zza.zza() && this.zzc != null) {
                        throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
                    }
                    if (this.zza.zze() == zzpp.zzb.zzd) {
                        zzxrVarJ = zzxr.zza(new byte[0]);
                    } else if (this.zza.zze() != zzpp.zzb.zzc && this.zza.zze() != zzpp.zzb.zzb) {
                        if (this.zza.zze() == zzpp.zzb.zza) {
                            zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 1));
                        } else {
                            throw new IllegalStateException("Unknown AesCmacParametersParameters.Variant: ".concat(String.valueOf(this.zza.zze())));
                        }
                    } else {
                        zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 0));
                    }
                    return new zzpi(this.zza, this.zzb, zzxrVarJ, this.zzc);
                }
                throw new GeneralSecurityException("Key size mismatch");
            }
            throw new GeneralSecurityException("Cannot build without parameters and/or key material");
        }
    }

    public static zza zzb() {
        return new zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
    public final Integer zza() {
        return this.zzd;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzqp
    public final /* synthetic */ zzqs zzc() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzqp
    public final zzxr zzd() {
        return this.zzc;
    }

    public final zzxt zze() {
        return this.zzb;
    }

    private zzpi(zzpp zzppVar, zzxt zzxtVar, zzxr zzxrVar, Integer num) {
        this.zza = zzppVar;
        this.zzb = zzxtVar;
        this.zzc = zzxrVar;
        this.zzd = num;
    }
}
