package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzfo;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzfl extends zzda {
    private final zzfo zza;
    private final zzxt zzb;
    private final zzxr zzc;
    private final Integer zzd;

    private zzfl(zzfo zzfoVar, zzxt zzxtVar, zzxr zzxrVar, Integer num) {
        this.zza = zzfoVar;
        this.zzb = zzxtVar;
        this.zzc = zzxrVar;
        this.zzd = num;
    }

    public static zzfl zza(zzfo.zza zzaVar, zzxt zzxtVar, Integer num) throws GeneralSecurityException {
        zzxr zzxrVarJ;
        zzfo.zza zzaVar2 = zzfo.zza.zzc;
        if (zzaVar != zzaVar2 && num == null) {
            throw new GeneralSecurityException(S.g("For given Variant ", String.valueOf(zzaVar), " the value of idRequirement must be non-null"));
        }
        if (zzaVar == zzaVar2 && num != null) {
            throw new GeneralSecurityException("For given Variant NO_PREFIX the value of idRequirement must be null");
        }
        if (zzxtVar.zza() != 32) {
            throw new GeneralSecurityException(S.d(zzxtVar.zza(), "ChaCha20Poly1305 key must be constructed with key of length 32 bytes, not "));
        }
        zzfo zzfoVarZza = zzfo.zza(zzaVar);
        if (zzfoVarZza.zzb() == zzaVar2) {
            zzxrVarJ = zzxr.zza(new byte[0]);
        } else if (zzfoVarZza.zzb() == zzfo.zza.zzb) {
            zzxrVarJ = a.j(num, ByteBuffer.allocate(5).put((byte) 0));
        } else {
            if (zzfoVarZza.zzb() != zzfo.zza.zza) {
                throw new IllegalStateException("Unknown Variant: ".concat(String.valueOf(zzfoVarZza.zzb())));
            }
            zzxrVarJ = a.j(num, ByteBuffer.allocate(5).put((byte) 1));
        }
        return new zzfl(zzfoVarZza, zzxtVar, zzxrVarJ, num);
    }

    public final zzfo zzb() {
        return this.zza;
    }

    public final zzxr zzc() {
        return this.zzc;
    }

    public final zzxt zzd() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
    public final Integer zza() {
        return this.zzd;
    }
}
