package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzakk;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
final class zzor<PrimitiveT, KeyProtoT extends zzakk, PublicKeyProtoT extends zzakk> extends zzml<PrimitiveT, KeyProtoT> implements zzcp<PrimitiveT> {
    private final zzoq<KeyProtoT, PublicKeyProtoT> zza;
    private final zznb<PublicKeyProtoT> zzb;

    public zzor(zzoq<KeyProtoT, PublicKeyProtoT> zzoqVar, zznb<PublicKeyProtoT> zznbVar, Class<PrimitiveT> cls) {
        super(zzoqVar, cls);
        this.zza = zzoqVar;
        this.zzb = zznbVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcp
    public final zzux zzc(zzahm zzahmVar) throws GeneralSecurityException {
        try {
            KeyProtoT keyprototZza = this.zza.zza(zzahmVar);
            this.zza.zzb(keyprototZza);
            zzakk zzakkVarZza = this.zza.zza(keyprototZza);
            this.zzb.zzb(zzakkVarZza);
            return (zzux) ((zzaja) zzux.zza().zza(this.zzb.zzd()).zza(zzakkVarZza.zzi()).zza(this.zzb.zzc()).zzf());
        } catch (zzajj e) {
            throw new GeneralSecurityException("expected serialized proto of type ", e);
        }
    }
}
