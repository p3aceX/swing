package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzakk;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
class zzml<PrimitiveT, KeyProtoT extends zzakk> implements zzbt<PrimitiveT> {
    private final zznb<KeyProtoT> zza;
    private final Class<PrimitiveT> zzb;

    public zzml(zznb<KeyProtoT> zznbVar, Class<PrimitiveT> cls) {
        if (zznbVar.zzg().contains(cls) || Void.class.equals(cls)) {
            this.zza = zznbVar;
            this.zzb = cls;
            return;
        }
        throw new IllegalArgumentException("Given internalKeyMananger " + zznbVar.toString() + " does not support primitive class " + cls.getName());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final zzux zza(zzahm zzahmVar) throws GeneralSecurityException {
        try {
            return (zzux) ((zzaja) zzux.zza().zza(this.zza.zzd()).zza(new zzmo(this.zza.zzb()).zza(zzahmVar).zzi()).zza(this.zza.zzc()).zzf());
        } catch (zzajj e) {
            throw new GeneralSecurityException("Unexpected proto", e);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final PrimitiveT zzb(zzahm zzahmVar) throws GeneralSecurityException {
        try {
            zzakk zzakkVarZza = this.zza.zza(zzahmVar);
            if (Void.class.equals(this.zzb)) {
                throw new GeneralSecurityException("Cannot create a primitive for Void");
            }
            this.zza.zzb(zzakkVarZza);
            return (PrimitiveT) this.zza.zza(zzakkVarZza, this.zzb);
        } catch (zzajj e) {
            throw new GeneralSecurityException("Failures parsing proto of type ".concat(this.zza.zzf().getName()), e);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final String zzb() {
        return this.zza.zzd();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final Class<PrimitiveT> zza() {
        return this.zzb;
    }
}
