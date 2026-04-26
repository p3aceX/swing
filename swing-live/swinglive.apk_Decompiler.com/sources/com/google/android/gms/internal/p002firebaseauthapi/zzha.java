package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzhd;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzha extends zzda {
    private final zzhd zza;
    private final zzxt zzb;
    private final zzxr zzc;
    private final Integer zzd;

    private zzha(zzhd zzhdVar, zzxt zzxtVar, zzxr zzxrVar, Integer num) {
        this.zza = zzhdVar;
        this.zzb = zzxtVar;
        this.zzc = zzxrVar;
        this.zzd = num;
    }

    public static zzha zza(zzhd.zza zzaVar, zzxt zzxtVar, Integer num) throws GeneralSecurityException {
        zzxr zzxrVarJ;
        zzhd.zza zzaVar2 = zzhd.zza.zzc;
        if (zzaVar != zzaVar2 && num == null) {
            throw new GeneralSecurityException(S.g("For given Variant ", String.valueOf(zzaVar), " the value of idRequirement must be non-null"));
        }
        if (zzaVar == zzaVar2 && num != null) {
            throw new GeneralSecurityException("For given Variant NO_PREFIX the value of idRequirement must be null");
        }
        if (zzxtVar.zza() != 32) {
            throw new GeneralSecurityException(S.d(zzxtVar.zza(), "XChaCha20Poly1305 key must be constructed with key of length 32 bytes, not "));
        }
        zzhd zzhdVarZza = zzhd.zza(zzaVar);
        if (zzhdVarZza.zzb() == zzaVar2) {
            zzxrVarJ = zzxr.zza(new byte[0]);
        } else if (zzhdVarZza.zzb() == zzhd.zza.zzb) {
            zzxrVarJ = a.j(num, ByteBuffer.allocate(5).put((byte) 0));
        } else {
            if (zzhdVarZza.zzb() != zzhd.zza.zza) {
                throw new IllegalStateException("Unknown Variant: ".concat(String.valueOf(zzhdVarZza.zzb())));
            }
            zzxrVarJ = a.j(num, ByteBuffer.allocate(5).put((byte) 1));
        }
        return new zzha(zzhdVarZza, zzxtVar, zzxrVarJ, num);
    }

    public final zzhd zzb() {
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
