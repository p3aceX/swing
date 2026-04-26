package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzjx;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.spec.EllipticCurve;

/* JADX INFO: loaded from: classes.dex */
public final class zzkk extends zzkr {
    private final zzjx zza;
    private final zzxr zzb;
    private final zzxr zzc;
    private final Integer zzd;

    private zzkk(zzjx zzjxVar, zzxr zzxrVar, zzxr zzxrVar2, Integer num) {
        this.zza = zzjxVar;
        this.zzb = zzxrVar;
        this.zzc = zzxrVar2;
        this.zzd = num;
    }

    public static zzkk zza(zzjx zzjxVar, zzxr zzxrVar, Integer num) throws GeneralSecurityException {
        EllipticCurve curve;
        zzxr zzxrVarJ;
        zzjx.zzf zzfVarZzf = zzjxVar.zzf();
        zzjx.zzf zzfVar = zzjx.zzf.zzc;
        if (!zzfVarZzf.equals(zzfVar) && num == null) {
            throw new GeneralSecurityException(S.g("'idRequirement' must be non-null for ", String.valueOf(zzfVarZzf), " variant."));
        }
        if (zzfVarZzf.equals(zzfVar) && num != null) {
            throw new GeneralSecurityException("'idRequirement' must be null for NO_PREFIX variant.");
        }
        zzjx.zzd zzdVarZze = zzjxVar.zze();
        int iZza = zzxrVar.zza();
        String str = "Encoded public key byte length for " + String.valueOf(zzdVarZze) + " must be %d, not " + iZza;
        zzjx.zzd zzdVar = zzjx.zzd.zza;
        if (zzdVarZze == zzdVar) {
            if (iZza != 65) {
                throw new GeneralSecurityException(String.format(str, 65));
            }
        } else if (zzdVarZze == zzjx.zzd.zzb) {
            if (iZza != 97) {
                throw new GeneralSecurityException(String.format(str, 97));
            }
        } else if (zzdVarZze == zzjx.zzd.zzc) {
            if (iZza != 133) {
                throw new GeneralSecurityException(String.format(str, 133));
            }
        } else {
            if (zzdVarZze != zzjx.zzd.zzd) {
                throw new GeneralSecurityException("Unable to validate public key length for ".concat(String.valueOf(zzdVarZze)));
            }
            if (iZza != 32) {
                throw new GeneralSecurityException(String.format(str, 32));
            }
        }
        if (zzdVarZze == zzdVar || zzdVarZze == zzjx.zzd.zzb || zzdVarZze == zzjx.zzd.zzc) {
            if (zzdVarZze == zzdVar) {
                curve = zzmd.zza.getCurve();
            } else if (zzdVarZze == zzjx.zzd.zzb) {
                curve = zzmd.zzb.getCurve();
            } else {
                if (zzdVarZze != zzjx.zzd.zzc) {
                    throw new IllegalArgumentException("Unable to determine NIST curve type for ".concat(String.valueOf(zzdVarZze)));
                }
                curve = zzmd.zzc.getCurve();
            }
            zzmd.zza(zzwn.zza(curve, zzwp.UNCOMPRESSED, zzxrVar.zzb()), curve);
        }
        zzjx.zzf zzfVarZzf2 = zzjxVar.zzf();
        if (zzfVarZzf2 == zzfVar) {
            zzxrVarJ = zzxr.zza(new byte[0]);
        } else {
            if (num == null) {
                throw new IllegalStateException("idRequirement must be non-null for HpkeParameters.Variant ".concat(String.valueOf(zzfVarZzf2)));
            }
            if (zzfVarZzf2 == zzjx.zzf.zzb) {
                zzxrVarJ = a.j(num, ByteBuffer.allocate(5).put((byte) 0));
            } else {
                if (zzfVarZzf2 != zzjx.zzf.zza) {
                    throw new IllegalStateException("Unknown HpkeParameters.Variant: ".concat(String.valueOf(zzfVarZzf2)));
                }
                zzxrVarJ = a.j(num, ByteBuffer.allocate(5).put((byte) 1));
            }
        }
        return new zzkk(zzjxVar, zzxrVar, zzxrVarJ, num);
    }

    public final zzjx zzb() {
        return this.zza;
    }

    public final zzxr zzc() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
    public final Integer zza() {
        return this.zzd;
    }
}
