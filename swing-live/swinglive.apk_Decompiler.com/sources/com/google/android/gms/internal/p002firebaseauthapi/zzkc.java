package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzjx;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.spec.ECParameterSpec;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzkc extends zzks {
    private final zzkk zza;
    private final zzxt zzb;

    private zzkc(zzkk zzkkVar, zzxt zzxtVar) {
        this.zza = zzkkVar;
        this.zzb = zzxtVar;
    }

    public static zzkc zza(zzkk zzkkVar, zzxt zzxtVar) throws GeneralSecurityException {
        ECParameterSpec eCParameterSpec;
        if (zzkkVar == null) {
            throw new GeneralSecurityException("HPKE private key cannot be constructed without an HPKE public key");
        }
        if (zzxtVar == null) {
            throw new GeneralSecurityException("HPKE private key cannot be constructed without secret");
        }
        zzjx.zzd zzdVarZze = zzkkVar.zzb().zze();
        int iZza = zzxtVar.zza();
        String str = "Encoded private key byte length for " + String.valueOf(zzdVarZze) + " must be %d, not " + iZza;
        zzjx.zzd zzdVar = zzjx.zzd.zza;
        if (zzdVarZze == zzdVar) {
            if (iZza != 32) {
                throw new GeneralSecurityException(String.format(str, 32));
            }
        } else if (zzdVarZze == zzjx.zzd.zzb) {
            if (iZza != 48) {
                throw new GeneralSecurityException(String.format(str, 48));
            }
        } else if (zzdVarZze == zzjx.zzd.zzc) {
            if (iZza != 66) {
                throw new GeneralSecurityException(String.format(str, 66));
            }
        } else {
            if (zzdVarZze != zzjx.zzd.zzd) {
                throw new GeneralSecurityException("Unable to validate private key length for ".concat(String.valueOf(zzdVarZze)));
            }
            if (iZza != 32) {
                throw new GeneralSecurityException(String.format(str, 32));
            }
        }
        zzjx.zzd zzdVarZze2 = zzkkVar.zzb().zze();
        byte[] bArrZzb = zzkkVar.zzc().zzb();
        byte[] bArrZza = zzxtVar.zza(zzbr.zza());
        if (zzdVarZze2 == zzdVar || zzdVarZze2 == zzjx.zzd.zzb || zzdVarZze2 == zzjx.zzd.zzc) {
            if (zzdVarZze2 == zzdVar) {
                eCParameterSpec = zzmd.zza;
            } else if (zzdVarZze2 == zzjx.zzd.zzb) {
                eCParameterSpec = zzmd.zzb;
            } else {
                if (zzdVarZze2 != zzjx.zzd.zzc) {
                    throw new IllegalArgumentException("Unable to determine NIST curve params for ".concat(String.valueOf(zzdVarZze2)));
                }
                eCParameterSpec = zzmd.zzc;
            }
            BigInteger order = eCParameterSpec.getOrder();
            BigInteger bigIntegerZza = zzmb.zza(bArrZza);
            if (bigIntegerZza.signum() <= 0 || bigIntegerZza.compareTo(order) >= 0) {
                throw new GeneralSecurityException("Invalid private key.");
            }
            if (!zzmd.zza(bigIntegerZza, eCParameterSpec).equals(zzwn.zza(eCParameterSpec.getCurve(), zzwp.UNCOMPRESSED, bArrZzb))) {
                throw new GeneralSecurityException("Invalid private key for public key.");
            }
        } else {
            if (zzdVarZze2 != zzjx.zzd.zzd) {
                throw new IllegalArgumentException("Unable to validate key pair for ".concat(String.valueOf(zzdVarZze2)));
            }
            if (!Arrays.equals(zzxp.zza(bArrZza), bArrZzb)) {
                throw new GeneralSecurityException("Invalid private key for public key.");
            }
        }
        return new zzkc(zzkkVar, zzxtVar);
    }

    public final zzjx zzb() {
        return this.zza.zzb();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzks
    public final /* synthetic */ zzkr zzc() {
        return this.zza;
    }

    public final zzxt zzd() {
        return this.zzb;
    }
}
