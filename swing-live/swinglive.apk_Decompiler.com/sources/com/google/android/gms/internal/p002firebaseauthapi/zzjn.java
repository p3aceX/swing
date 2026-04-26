package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzjl;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzjn extends zzks {
    private final zzjv zza;
    private final zzxu zzb;
    private final zzxt zzc;

    private zzjn(zzjv zzjvVar, zzxu zzxuVar, zzxt zzxtVar) {
        this.zza = zzjvVar;
        this.zzb = zzxuVar;
        this.zzc = zzxtVar;
    }

    public static zzjn zza(zzjv zzjvVar, zzxt zzxtVar) throws GeneralSecurityException {
        if (zzjvVar == null) {
            throw new GeneralSecurityException("ECIES private key cannot be constructed without an ECIES public key");
        }
        if (zzjvVar.zzc() == null) {
            throw new GeneralSecurityException("ECIES private key for X25519 curve cannot be constructed with NIST-curve public key");
        }
        if (zzxtVar == null) {
            throw new GeneralSecurityException("ECIES private key cannot be constructed without secret");
        }
        byte[] bArrZza = zzxtVar.zza(zzbr.zza());
        byte[] bArrZzb = zzjvVar.zzc().zzb();
        if (bArrZza.length != 32) {
            throw new GeneralSecurityException("Private key bytes length for X25519 curve must be 32");
        }
        if (Arrays.equals(zzxp.zza(bArrZza), bArrZzb)) {
            return new zzjn(zzjvVar, null, zzxtVar);
        }
        throw new GeneralSecurityException("Invalid private key for public key.");
    }

    public final zzjl zzb() {
        return this.zza.zzb();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzks
    public final /* synthetic */ zzkr zzc() {
        return this.zza;
    }

    public final zzxu zzd() {
        return this.zzb;
    }

    public final zzxt zze() {
        return this.zzc;
    }

    public static zzjn zza(zzjv zzjvVar, zzxu zzxuVar) throws GeneralSecurityException {
        if (zzjvVar != null) {
            if (zzjvVar.zzd() == null) {
                throw new GeneralSecurityException("ECIES private key for NIST curve cannot be constructed with X25519-curve public key");
            }
            if (zzxuVar != null) {
                BigInteger bigIntegerZza = zzxuVar.zza(zzbr.zza());
                ECPoint eCPointZzd = zzjvVar.zzd();
                zzjl.zzc zzcVarZzd = zzjvVar.zzb().zzd();
                BigInteger order = zza(zzcVarZzd).getOrder();
                if (bigIntegerZza.signum() > 0 && bigIntegerZza.compareTo(order) < 0) {
                    if (zzmd.zza(bigIntegerZza, zza(zzcVarZzd)).equals(eCPointZzd)) {
                        return new zzjn(zzjvVar, zzxuVar, null);
                    }
                    throw new GeneralSecurityException("Invalid private value");
                }
                throw new GeneralSecurityException("Invalid private value");
            }
            throw new GeneralSecurityException("ECIES private key cannot be constructed without secret");
        }
        throw new GeneralSecurityException("ECIES private key cannot be constructed without an ECIES public key");
    }

    private static ECParameterSpec zza(zzjl.zzc zzcVar) {
        if (zzcVar == zzjl.zzc.zza) {
            return zzmd.zza;
        }
        if (zzcVar == zzjl.zzc.zzb) {
            return zzmd.zzb;
        }
        if (zzcVar == zzjl.zzc.zzc) {
            return zzmd.zzc;
        }
        throw new IllegalArgumentException("Unable to determine NIST curve type for ".concat(String.valueOf(zzcVar)));
    }
}
