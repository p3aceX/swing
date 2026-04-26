package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzea;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzdv extends zzda {
    private final zzea zza;
    private final zzxt zzb;
    private final zzxr zzc;
    private final Integer zzd;

    public static class zza {
        private zzea zza;
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

        public final zza zza(zzea zzeaVar) {
            this.zza = zzeaVar;
            return this;
        }

        public final zzdv zza() throws GeneralSecurityException {
            zzxr zzxrVarJ;
            zzea zzeaVar = this.zza;
            if (zzeaVar != null && this.zzb != null) {
                if (zzeaVar.zzc() == this.zzb.zza()) {
                    if (this.zza.zza() && this.zzc == null) {
                        throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
                    }
                    if (!this.zza.zza() && this.zzc != null) {
                        throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
                    }
                    if (this.zza.zzf() == zzea.zzb.zzc) {
                        zzxrVarJ = zzxr.zza(new byte[0]);
                    } else if (this.zza.zzf() == zzea.zzb.zzb) {
                        zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 0));
                    } else if (this.zza.zzf() == zzea.zzb.zza) {
                        zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 1));
                    } else {
                        throw new IllegalStateException("Unknown AesEaxParameters.Variant: ".concat(String.valueOf(this.zza.zzf())));
                    }
                    return new zzdv(this.zza, this.zzb, zzxrVarJ, this.zzc);
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

    public final zzea zzc() {
        return this.zza;
    }

    public final zzxr zzd() {
        return this.zzc;
    }

    public final zzxt zze() {
        return this.zzb;
    }

    private zzdv(zzea zzeaVar, zzxt zzxtVar, zzxr zzxrVar, Integer num) {
        this.zza = zzeaVar;
        this.zzb = zzxtVar;
        this.zzc = zzxrVar;
        this.zzd = num;
    }
}
