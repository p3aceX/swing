package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import com.google.android.gms.internal.p002firebaseauthapi.zzqm;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzqe extends zznb<zzue> {
    private static final zzoe<zzqb, zzpx> zza = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqh
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return new zzrd((zzqb) zzbuVar);
        }
    }, zzqb.class, zzpx.class);
    private static final zzoe<zzqb, zzcf> zzb = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqg
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzxo.zza((zzqb) zzbuVar);
        }
    }, zzqb.class, zzcf.class);
    private static final zznp<zzqm> zzc = new zznp() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqj
    };

    public zzqe() {
        super(zzue.class, new zzqi(zzcf.class));
    }

    public static int zzh() {
        return 0;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzna<zzuf, zzue> zzb() {
        return new zzql(this, zzuf.class);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzux.zzb zzc() {
        return zzux.zzb.SYMMETRIC;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final String zzd() {
        return "type.googleapis.com/google.crypto.tink.HmacKey";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzic.zza zza() {
        return zzic.zza.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final /* synthetic */ void zzb(zzakk zzakkVar) throws GeneralSecurityException {
        zzue zzueVar = (zzue) zzakkVar;
        zzxq.zza(zzueVar.zza(), 0);
        if (zzueVar.zzf().zzb() < 16) {
            throw new GeneralSecurityException("key too short");
        }
        zzb(zzueVar.zze());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final /* synthetic */ zzakk zza(zzahm zzahmVar) {
        return zzue.zza(zzahmVar, zzaip.zza());
    }

    public static void zza(boolean z4) {
        zzcu.zza((zznb) new zzqe(), true);
        zzrg.zza();
        zzns.zza().zza(zza);
        zzns.zza().zza(zzb);
        zznt zzntVarZza = zznt.zza();
        HashMap map = new HashMap();
        map.put("HMAC_SHA256_128BITTAG", zzqv.zza);
        zzqm.zza zzaVarZzb = zzqm.zzd().zza(32).zzb(16);
        zzqm.zzc zzcVar = zzqm.zzc.zzd;
        zzqm.zza zzaVarZza = zzaVarZzb.zza(zzcVar);
        zzqm.zzb zzbVar = zzqm.zzb.zzc;
        map.put("HMAC_SHA256_128BITTAG_RAW", zzaVarZza.zza(zzbVar).zza());
        zzqm.zza zzaVarZzb2 = zzqm.zzd().zza(32).zzb(32);
        zzqm.zzc zzcVar2 = zzqm.zzc.zza;
        map.put("HMAC_SHA256_256BITTAG", zzaVarZzb2.zza(zzcVar2).zza(zzbVar).zza());
        map.put("HMAC_SHA256_256BITTAG_RAW", zzqm.zzd().zza(32).zzb(32).zza(zzcVar).zza(zzbVar).zza());
        zzqm.zza zzaVarZza2 = zzqm.zzd().zza(64).zzb(16).zza(zzcVar2);
        zzqm.zzb zzbVar2 = zzqm.zzb.zze;
        map.put("HMAC_SHA512_128BITTAG", zzaVarZza2.zza(zzbVar2).zza());
        map.put("HMAC_SHA512_128BITTAG_RAW", zzqm.zzd().zza(64).zzb(16).zza(zzcVar).zza(zzbVar2).zza());
        map.put("HMAC_SHA512_256BITTAG", zzqm.zzd().zza(64).zzb(32).zza(zzcVar2).zza(zzbVar2).zza());
        map.put("HMAC_SHA512_256BITTAG_RAW", zzqm.zzd().zza(64).zzb(32).zza(zzcVar).zza(zzbVar2).zza());
        map.put("HMAC_SHA512_512BITTAG", zzqv.zzb);
        map.put("HMAC_SHA512_512BITTAG_RAW", zzqm.zzd().zza(64).zzb(64).zza(zzcVar).zza(zzbVar2).zza());
        zzntVarZza.zza(Collections.unmodifiableMap(map));
        zznm.zza().zza(zzc, zzqm.class);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static void zzb(zzui zzuiVar) throws GeneralSecurityException {
        if (zzuiVar.zza() >= 10) {
            int i4 = zzqk.zza[zzuiVar.zzb().ordinal()];
            if (i4 == 1) {
                if (zzuiVar.zza() > 20) {
                    throw new GeneralSecurityException("tag size too big");
                }
                return;
            }
            if (i4 == 2) {
                if (zzuiVar.zza() > 28) {
                    throw new GeneralSecurityException("tag size too big");
                }
                return;
            }
            if (i4 == 3) {
                if (zzuiVar.zza() > 32) {
                    throw new GeneralSecurityException("tag size too big");
                }
                return;
            } else if (i4 == 4) {
                if (zzuiVar.zza() > 48) {
                    throw new GeneralSecurityException("tag size too big");
                }
                return;
            } else {
                if (i4 == 5) {
                    if (zzuiVar.zza() > 64) {
                        throw new GeneralSecurityException("tag size too big");
                    }
                    return;
                }
                throw new GeneralSecurityException("unknown hash type");
            }
        }
        throw new GeneralSecurityException("tag size too small");
    }
}
