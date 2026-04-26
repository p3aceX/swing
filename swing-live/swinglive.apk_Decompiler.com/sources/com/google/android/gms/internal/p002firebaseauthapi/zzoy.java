package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zzoy {
    private final Map<zzpd, zzmx<?, ?>> zza;
    private final Map<zzpb, zzmt<?>> zzb;
    private final Map<zzpd, zzoa<?, ?>> zzc;
    private final Map<zzpb, zznw<?>> zzd;

    public zzoy() {
        this.zza = new HashMap();
        this.zzb = new HashMap();
        this.zzc = new HashMap();
        this.zzd = new HashMap();
    }

    public final <SerializationT extends zzow> zzoy zza(zzmt<SerializationT> zzmtVar) throws GeneralSecurityException {
        zzpb zzpbVar = new zzpb(zzmtVar.zzb(), zzmtVar.zza());
        if (!this.zzb.containsKey(zzpbVar)) {
            this.zzb.put(zzpbVar, zzmtVar);
            return this;
        }
        zzmt<?> zzmtVar2 = this.zzb.get(zzpbVar);
        if (zzmtVar2.equals(zzmtVar) && zzmtVar.equals(zzmtVar2)) {
            return this;
        }
        throw new GeneralSecurityException("Attempt to register non-equal parser for already existing object of type: ".concat(String.valueOf(zzpbVar)));
    }

    public zzoy(zzoz zzozVar) {
        this.zza = new HashMap(zzozVar.zza);
        this.zzb = new HashMap(zzozVar.zzb);
        this.zzc = new HashMap(zzozVar.zzc);
        this.zzd = new HashMap(zzozVar.zzd);
    }

    public final <KeyT extends zzbu, SerializationT extends zzow> zzoy zza(zzmx<KeyT, SerializationT> zzmxVar) throws GeneralSecurityException {
        zzpd zzpdVar = new zzpd(zzmxVar.zza(), zzmxVar.zzb());
        if (this.zza.containsKey(zzpdVar)) {
            zzmx<?, ?> zzmxVar2 = this.zza.get(zzpdVar);
            if (zzmxVar2.equals(zzmxVar) && zzmxVar.equals(zzmxVar2)) {
                return this;
            }
            throw new GeneralSecurityException("Attempt to register non-equal serializer for already existing object of type: ".concat(String.valueOf(zzpdVar)));
        }
        this.zza.put(zzpdVar, zzmxVar);
        return this;
    }

    public final <SerializationT extends zzow> zzoy zza(zznw<SerializationT> zznwVar) throws GeneralSecurityException {
        zzpb zzpbVar = new zzpb(zznwVar.zzb(), zznwVar.zza());
        if (this.zzd.containsKey(zzpbVar)) {
            zznw<?> zznwVar2 = this.zzd.get(zzpbVar);
            if (zznwVar2.equals(zznwVar) && zznwVar.equals(zznwVar2)) {
                return this;
            }
            throw new GeneralSecurityException("Attempt to register non-equal parser for already existing object of type: ".concat(String.valueOf(zzpbVar)));
        }
        this.zzd.put(zzpbVar, zznwVar);
        return this;
    }

    public final <ParametersT extends zzci, SerializationT extends zzow> zzoy zza(zzoa<ParametersT, SerializationT> zzoaVar) throws GeneralSecurityException {
        zzpd zzpdVar = new zzpd(zzoaVar.zza(), zzoaVar.zzb());
        if (this.zzc.containsKey(zzpdVar)) {
            zzoa<?, ?> zzoaVar2 = this.zzc.get(zzpdVar);
            if (zzoaVar2.equals(zzoaVar) && zzoaVar.equals(zzoaVar2)) {
                return this;
            }
            throw new GeneralSecurityException("Attempt to register non-equal serializer for already existing object of type: ".concat(String.valueOf(zzpdVar)));
        }
        this.zzc.put(zzpdVar, zzoaVar);
        return this;
    }

    public final zzoz zza() {
        return new zzoz(this);
    }
}
