package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import java.security.GeneralSecurityException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public final class zzmn {
    private static final Logger zza = Logger.getLogger(zzmn.class.getName());
    private static final zzmn zzb = new zzmn();
    private ConcurrentMap<String, zza> zzc = new ConcurrentHashMap();
    private ConcurrentMap<String, Boolean> zzd = new ConcurrentHashMap();

    public interface zza {
        zzbt<?> zza();

        <P> zzbt<P> zza(Class<P> cls);

        Class<?> zzb();

        Set<Class<?>> zzc();
    }

    private final synchronized zza zzc(String str) {
        if (!this.zzc.containsKey(str)) {
            throw new GeneralSecurityException("No key manager found for key type " + str);
        }
        return this.zzc.get(str);
    }

    public final <P> zzbt<P> zza(String str, Class<P> cls) throws GeneralSecurityException {
        zza zzaVarZzc = zzc(str);
        if (zzaVarZzc.zzc().contains(cls)) {
            return zzaVarZzc.zza(cls);
        }
        String name = cls.getName();
        String strValueOf = String.valueOf(zzaVarZzc.zzb());
        Set<Class<?>> setZzc = zzaVarZzc.zzc();
        StringBuilder sb = new StringBuilder();
        boolean z4 = true;
        for (Class<?> cls2 : setZzc) {
            if (!z4) {
                sb.append(", ");
            }
            sb.append(cls2.getCanonicalName());
            z4 = false;
        }
        throw new GeneralSecurityException("Primitive type " + name + " not supported by key manager of type " + strValueOf + ", supported primitives: " + sb.toString());
    }

    public final boolean zzb(String str) {
        return this.zzd.get(str).booleanValue();
    }

    public final zzbt<?> zza(String str) {
        return zzc(str).zza();
    }

    private static <KeyProtoT extends zzakk> zza zza(zznb<KeyProtoT> zznbVar) {
        return new zzmp(zznbVar);
    }

    public static zzmn zza() {
        return zzb;
    }

    public final synchronized <KeyProtoT extends zzakk, PublicKeyProtoT extends zzakk> void zza(zzoq<KeyProtoT, PublicKeyProtoT> zzoqVar, zznb<PublicKeyProtoT> zznbVar, boolean z4) {
        zzic.zza zzaVarZza = zzoqVar.zza();
        zzic.zza zzaVarZza2 = zznbVar.zza();
        if (zzaVarZza.zza()) {
            if (zzaVarZza2.zza()) {
                zza((zza) new zzmr(zzoqVar, zznbVar), true, true);
                zza(zza(zznbVar), false, false);
            } else {
                throw new GeneralSecurityException("failed to register key manager " + String.valueOf(zznbVar.getClass()) + " as it is not FIPS compatible.");
            }
        } else {
            throw new GeneralSecurityException("failed to register key manager " + String.valueOf(zzoqVar.getClass()) + " as it is not FIPS compatible.");
        }
    }

    public final synchronized <P> void zza(zzbt<P> zzbtVar, boolean z4) {
        zza((zzbt) zzbtVar, zzic.zza.zza, true);
    }

    public final synchronized <KeyProtoT extends zzakk> void zza(zznb<KeyProtoT> zznbVar, boolean z4) {
        if (zznbVar.zza().zza()) {
            zza(zza(zznbVar), false, true);
        } else {
            throw new GeneralSecurityException("failed to register key manager " + String.valueOf(zznbVar.getClass()) + " as it is not FIPS compatible.");
        }
    }

    private final synchronized void zza(zza zzaVar, boolean z4, boolean z5) {
        try {
            String strZzb = zzaVar.zza().zzb();
            if (z5 && this.zzd.containsKey(strZzb) && !this.zzd.get(strZzb).booleanValue()) {
                throw new GeneralSecurityException("New keys are already disallowed for key type " + strZzb);
            }
            zza zzaVar2 = this.zzc.get(strZzb);
            if (zzaVar2 != null && !zzaVar2.zzb().equals(zzaVar.zzb())) {
                zza.logp(Level.WARNING, "com.google.crypto.tink.internal.KeyManagerRegistry", "registerKeyManagerContainer", "Attempted overwrite of a registered key manager for key type " + strZzb);
                throw new GeneralSecurityException("typeUrl (" + strZzb + ") is already registered with " + zzaVar2.zzb().getName() + ", cannot be re-registered with " + zzaVar.zzb().getName());
            }
            if (!z4) {
                this.zzc.putIfAbsent(strZzb, zzaVar);
            } else {
                this.zzc.put(strZzb, zzaVar);
            }
            this.zzd.put(strZzb, Boolean.valueOf(z5));
        } catch (Throwable th) {
            throw th;
        }
    }

    public final synchronized <P> void zza(zzbt<P> zzbtVar, zzic.zza zzaVar, boolean z4) {
        if (zzaVar.zza()) {
            zza((zza) new zzmq(zzbtVar), false, z4);
        } else {
            throw new GeneralSecurityException("Cannot register key manager: FIPS compatibility insufficient");
        }
    }
}
