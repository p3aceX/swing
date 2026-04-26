package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzdm;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzdf extends zzda {
    private final zzdm zza;
    private final zzxt zzb;
    private final zzxt zzc;
    private final zzxr zzd;
    private final Integer zze;

    public static class zza {
        private zzdm zza;
        private zzxt zzb;
        private zzxt zzc;
        private Integer zzd;

        public final zza zza(zzxt zzxtVar) {
            this.zzb = zzxtVar;
            return this;
        }

        public final zza zzb(zzxt zzxtVar) {
            this.zzc = zzxtVar;
            return this;
        }

        private zza() {
            this.zza = null;
            this.zzb = null;
            this.zzc = null;
            this.zzd = null;
        }

        public final zza zza(Integer num) {
            this.zzd = num;
            return this;
        }

        public final zza zza(zzdm zzdmVar) {
            this.zza = zzdmVar;
            return this;
        }

        public final zzdf zza() throws GeneralSecurityException {
            zzxr zzxrVarJ;
            zzdm zzdmVar = this.zza;
            if (zzdmVar != null) {
                if (this.zzb != null && this.zzc != null) {
                    if (zzdmVar.zzb() == this.zzb.zza()) {
                        if (this.zza.zzc() == this.zzc.zza()) {
                            if (this.zza.zza() && this.zzd == null) {
                                throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
                            }
                            if (!this.zza.zza() && this.zzd != null) {
                                throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
                            }
                            if (this.zza.zzh() == zzdm.zzc.zzc) {
                                zzxrVarJ = zzxr.zza(new byte[0]);
                            } else if (this.zza.zzh() == zzdm.zzc.zzb) {
                                zzxrVarJ = a.j(this.zzd, ByteBuffer.allocate(5).put((byte) 0));
                            } else if (this.zza.zzh() == zzdm.zzc.zza) {
                                zzxrVarJ = a.j(this.zzd, ByteBuffer.allocate(5).put((byte) 1));
                            } else {
                                throw new IllegalStateException("Unknown AesCtrHmacAeadParameters.Variant: ".concat(String.valueOf(this.zza.zzh())));
                            }
                            return new zzdf(this.zza, this.zzb, this.zzc, zzxrVarJ, this.zzd);
                        }
                        throw new GeneralSecurityException("HMAC key size mismatch");
                    }
                    throw new GeneralSecurityException("AES key size mismatch");
                }
                throw new GeneralSecurityException("Cannot build without key material");
            }
            throw new GeneralSecurityException("Cannot build without parameters");
        }
    }

    public static zza zzb() {
        return new zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
    public final Integer zza() {
        return this.zze;
    }

    public final zzdm zzc() {
        return this.zza;
    }

    public final zzxr zzd() {
        return this.zzd;
    }

    public final zzxt zze() {
        return this.zzb;
    }

    public final zzxt zzf() {
        return this.zzc;
    }

    private zzdf(zzdm zzdmVar, zzxt zzxtVar, zzxt zzxtVar2, zzxr zzxrVar, Integer num) {
        this.zza = zzdmVar;
        this.zzb = zzxtVar;
        this.zzc = zzxtVar2;
        this.zzd = zzxrVar;
        this.zze = num;
    }
}
