package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzqm;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzqb extends zzqp {
    private final zzqm zza;
    private final zzxt zzb;
    private final zzxr zzc;
    private final Integer zzd;

    public static class zza {
        private zzqm zza;
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

        public final zza zza(zzqm zzqmVar) {
            this.zza = zzqmVar;
            return this;
        }

        public final zzqb zza() throws GeneralSecurityException {
            zzxr zzxrVarJ;
            zzqm zzqmVar = this.zza;
            if (zzqmVar != null && this.zzb != null) {
                if (zzqmVar.zzc() == this.zzb.zza()) {
                    if (this.zza.zza() && this.zzc == null) {
                        throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
                    }
                    if (!this.zza.zza() && this.zzc != null) {
                        throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
                    }
                    if (this.zza.zzf() == zzqm.zzc.zzd) {
                        zzxrVarJ = zzxr.zza(new byte[0]);
                    } else if (this.zza.zzf() != zzqm.zzc.zzc && this.zza.zzf() != zzqm.zzc.zzb) {
                        if (this.zza.zzf() == zzqm.zzc.zza) {
                            zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 1));
                        } else {
                            throw new IllegalStateException("Unknown HmacParameters.Variant: ".concat(String.valueOf(this.zza.zzf())));
                        }
                    } else {
                        zzxrVarJ = a.j(this.zzc, ByteBuffer.allocate(5).put((byte) 0));
                    }
                    return new zzqb(this.zza, this.zzb, zzxrVarJ, this.zzc);
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

    private zzqb(zzqm zzqmVar, zzxt zzxtVar, zzxr zzxrVar, Integer num) {
        this.zza = zzqmVar;
        this.zzb = zzxtVar;
        this.zzc = zzxrVar;
        this.zzd = num;
    }
}
