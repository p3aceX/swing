package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzqr implements zzcq<zzcf, zzcf> {
    private static final zzqr zza = new zzqr();
    private static final zzoe<zznc, zzcf> zzb = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqu
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzrj.zza((zznc) zzbuVar);
        }
    }, zznc.class, zzcf.class);

    public static void zzc() {
        zzcu.zza(zza);
        zzns.zza().zza(zzb);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcq
    public final Class<zzcf> zza() {
        return zzcf.class;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcq
    public final Class<zzcf> zzb() {
        return zzcf.class;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcq
    public final /* synthetic */ zzcf zza(zzch<zzcf> zzchVar) throws GeneralSecurityException {
        Iterator<List<zzcm<zzcf>>> it = zzchVar.zzd().iterator();
        while (it.hasNext()) {
            for (zzcm<zzcf> zzcmVar : it.next()) {
                if (zzcmVar.zzb() instanceof zzqp) {
                    zzqp zzqpVar = (zzqp) zzcmVar.zzb();
                    zzxr zzxrVarZza = zzxr.zza(zzcmVar.zzh());
                    if (!zzxrVarZza.equals(zzqpVar.zzd())) {
                        String strValueOf = String.valueOf(zzqpVar.zzc());
                        String strValueOf2 = String.valueOf(zzqpVar.zzd());
                        String strValueOf3 = String.valueOf(zzxrVarZza);
                        StringBuilder sb = new StringBuilder("Mac Key with parameters ");
                        sb.append(strValueOf);
                        sb.append(" has wrong output prefix (");
                        sb.append(strValueOf2);
                        sb.append(") instead of (");
                        throw new GeneralSecurityException(S.h(sb, strValueOf3, ")"));
                    }
                }
            }
        }
        return new zzqt(zzchVar);
    }
}
