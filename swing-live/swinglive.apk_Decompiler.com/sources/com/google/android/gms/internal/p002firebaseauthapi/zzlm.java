package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;
import java.security.spec.EllipticCurve;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzlm extends zzna<zzuo, zzut> {
    private final /* synthetic */ zzlk zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzlm(zzlk zzlkVar, Class cls) {
        super(cls);
        this.zza = zzlkVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzna
    public final /* synthetic */ zzakk zza(zzakk zzakkVar) throws GeneralSecurityException {
        byte[] bArrZza;
        byte[] bArrZza2;
        zzuo zzuoVar = (zzuo) zzakkVar;
        zzum zzumVarZzc = zzuoVar.zzc().zzc();
        int i4 = zzll.zza[zzumVarZzc.ordinal()];
        if (i4 != 1) {
            if (i4 != 2 && i4 != 3 && i4 != 4) {
                throw new GeneralSecurityException("Invalid KEM");
            }
            zzwq zzwqVarZzc = zzlq.zzc(zzuoVar.zzc().zzc());
            ECParameterSpec eCParameterSpecZza = zzwn.zza(zzwqVarZzc);
            KeyPairGenerator keyPairGeneratorZza = zzwr.zzd.zza("EC");
            keyPairGeneratorZza.initialize(eCParameterSpecZza);
            KeyPair keyPairGenerateKeyPair = keyPairGeneratorZza.generateKeyPair();
            zzwp zzwpVar = zzwp.UNCOMPRESSED;
            ECPoint w4 = ((ECPublicKey) keyPairGenerateKeyPair.getPublic()).getW();
            EllipticCurve curve = zzwn.zza(zzwqVarZzc).getCurve();
            zzmd.zza(w4, curve);
            int iZza = zzwn.zza(curve);
            int iOrdinal = zzwpVar.ordinal();
            if (iOrdinal == 0) {
                int i5 = (iZza * 2) + 1;
                byte[] bArr = new byte[i5];
                byte[] bArrZza3 = zzmb.zza(w4.getAffineX());
                byte[] bArrZza4 = zzmb.zza(w4.getAffineY());
                System.arraycopy(bArrZza4, 0, bArr, i5 - bArrZza4.length, bArrZza4.length);
                System.arraycopy(bArrZza3, 0, bArr, (iZza + 1) - bArrZza3.length, bArrZza3.length);
                bArr[0] = 4;
                bArrZza2 = bArr;
            } else if (iOrdinal == 1) {
                int i6 = iZza + 1;
                bArrZza2 = new byte[i6];
                byte[] bArrZza5 = zzmb.zza(w4.getAffineX());
                System.arraycopy(bArrZza5, 0, bArrZza2, i6 - bArrZza5.length, bArrZza5.length);
                bArrZza2[0] = (byte) (w4.getAffineY().testBit(0) ? 3 : 2);
            } else {
                if (iOrdinal != 2) {
                    throw new GeneralSecurityException("invalid format:".concat(String.valueOf(zzwpVar)));
                }
                int i7 = iZza * 2;
                bArrZza2 = new byte[i7];
                byte[] bArrZza6 = zzmb.zza(w4.getAffineX());
                if (bArrZza6.length > iZza) {
                    bArrZza6 = Arrays.copyOfRange(bArrZza6, bArrZza6.length - iZza, bArrZza6.length);
                }
                byte[] bArrZza7 = zzmb.zza(w4.getAffineY());
                if (bArrZza7.length > iZza) {
                    bArrZza7 = Arrays.copyOfRange(bArrZza7, bArrZza7.length - iZza, bArrZza7.length);
                }
                System.arraycopy(bArrZza7, 0, bArrZza2, i7 - bArrZza7.length, bArrZza7.length);
                System.arraycopy(bArrZza6, 0, bArrZza2, iZza - bArrZza6.length, bArrZza6.length);
            }
            bArrZza = zzmb.zza(((ECPrivateKey) keyPairGenerateKeyPair.getPrivate()).getS(), zzlq.zza(zzumVarZzc));
        } else {
            bArrZza = zzov.zza(32);
            bArrZza[0] = (byte) (bArrZza[0] | 7);
            byte b5 = (byte) (bArrZza[31] & 63);
            bArrZza[31] = b5;
            bArrZza[31] = (byte) (b5 | 128);
            bArrZza2 = zzxp.zza(bArrZza);
        }
        return (zzut) ((zzaja) zzut.zzb().zza(0).zza((zzuw) ((zzaja) zzuw.zzc().zza(0).zza(zzuoVar.zzc()).zza(zzahm.zza(bArrZza2)).zzf())).zza(zzahm.zza(bArrZza)).zzf());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzna
    public final /* synthetic */ void zzb(zzakk zzakkVar) throws GeneralSecurityException {
        zzlq.zza(((zzuo) zzakkVar).zzc());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzna
    public final /* synthetic */ zzakk zza(zzahm zzahmVar) {
        return zzuo.zza(zzahmVar, zzaip.zza());
    }
}
