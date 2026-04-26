package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzjl;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.spec.ECPoint;
import java.security.spec.EllipticCurve;

/* JADX INFO: loaded from: classes.dex */
public final class zzjv extends zzkr {
    private final zzjl zza;
    private final ECPoint zzb;
    private final zzxr zzc;
    private final zzxr zzd;
    private final Integer zze;

    private zzjv(zzjl zzjlVar, ECPoint eCPoint, zzxr zzxrVar, zzxr zzxrVar2, Integer num) {
        this.zza = zzjlVar;
        this.zzb = eCPoint;
        this.zzc = zzxrVar;
        this.zzd = zzxrVar2;
        this.zze = num;
    }

    public static zzjv zza(zzjl zzjlVar, zzxr zzxrVar, Integer num) throws GeneralSecurityException {
        if (!zzjlVar.zzd().equals(zzjl.zzc.zzd)) {
            throw new GeneralSecurityException("createForCurveX25519 may only be called with parameters for curve X25519");
        }
        zzb(zzjlVar.zzg(), num);
        if (zzxrVar.zza() == 32) {
            return new zzjv(zzjlVar, null, zzxrVar, zza(zzjlVar.zzg(), num), num);
        }
        throw new GeneralSecurityException("Encoded public point byte length for X25519 curve must be 32");
    }

    public final zzjl zzb() {
        return this.zza;
    }

    public final zzxr zzc() {
        return this.zzc;
    }

    public final ECPoint zzd() {
        return this.zzb;
    }

    private static void zzb(zzjl.zzd zzdVar, Integer num) throws GeneralSecurityException {
        zzjl.zzd zzdVar2 = zzjl.zzd.zzc;
        if (!zzdVar.equals(zzdVar2) && num == null) {
            throw new GeneralSecurityException(S.g("'idRequirement' must be non-null for ", String.valueOf(zzdVar), " variant."));
        }
        if (zzdVar.equals(zzdVar2) && num != null) {
            throw new GeneralSecurityException("'idRequirement' must be null for NO_PREFIX variant.");
        }
    }

    public static zzjv zza(zzjl zzjlVar, ECPoint eCPoint, Integer num) throws GeneralSecurityException {
        EllipticCurve curve;
        if (!zzjlVar.zzd().equals(zzjl.zzc.zzd)) {
            zzb(zzjlVar.zzg(), num);
            zzjl.zzc zzcVarZzd = zzjlVar.zzd();
            if (zzcVarZzd == zzjl.zzc.zza) {
                curve = zzmd.zza.getCurve();
            } else if (zzcVarZzd == zzjl.zzc.zzb) {
                curve = zzmd.zzb.getCurve();
            } else if (zzcVarZzd == zzjl.zzc.zzc) {
                curve = zzmd.zzc.getCurve();
            } else {
                throw new IllegalArgumentException("Unable to determine NIST curve type for ".concat(String.valueOf(zzcVarZzd)));
            }
            zzmd.zza(eCPoint, curve);
            return new zzjv(zzjlVar, eCPoint, null, zza(zzjlVar.zzg(), num), num);
        }
        throw new GeneralSecurityException("createForNistCurve may only be called with parameters for NIST curve");
    }

    private static zzxr zza(zzjl.zzd zzdVar, Integer num) {
        if (zzdVar == zzjl.zzd.zzc) {
            return zzxr.zza(new byte[0]);
        }
        if (num != null) {
            if (zzdVar == zzjl.zzd.zzb) {
                return a.j(num, ByteBuffer.allocate(5).put((byte) 0));
            }
            if (zzdVar == zzjl.zzd.zza) {
                return a.j(num, ByteBuffer.allocate(5).put((byte) 1));
            }
            throw new IllegalStateException("Unknown EciesParameters.Variant: ".concat(String.valueOf(zzdVar)));
        }
        throw new IllegalStateException("idRequirement must be non-null for EciesParameters.Variant: ".concat(String.valueOf(zzdVar)));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
    public final Integer zza() {
        return this.zze;
    }
}
