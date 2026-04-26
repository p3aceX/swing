package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import com.google.android.gms.internal.p002firebaseauthapi.zzvh;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzby {
    private final zzvh zza;
    private final List<zzca> zzb;
    private final zzrl zzc = zzrl.zza;

    private zzby(zzvh zzvhVar, List<zzca> list) {
        this.zza = zzvhVar;
        this.zzb = list;
    }

    public static final zzby zza(zzvh zzvhVar) throws GeneralSecurityException {
        zzc(zzvhVar);
        return new zzby(zzvhVar, zzb(zzvhVar));
    }

    public final String toString() {
        return zzcy.zza(this.zza).toString();
    }

    public final zzvh zzb() {
        return this.zza;
    }

    public final zzvi zzc() {
        return zzcy.zza(this.zza);
    }

    private static List<zzca> zzb(zzvh zzvhVar) {
        zzbu zzbuVarZza;
        int i4;
        zzbw zzbwVar;
        ArrayList arrayList = new ArrayList(zzvhVar.zza());
        for (zzvh.zza zzaVar : zzvhVar.zze()) {
            int iZza = zzaVar.zza();
            try {
                zzbuVarZza = zznv.zza().zza(zza(zzaVar), zzct.zza());
                i4 = zzbx.zza[zzaVar.zzc().ordinal()];
            } catch (GeneralSecurityException unused) {
                arrayList.add(null);
            }
            if (i4 == 1) {
                zzbwVar = zzbw.zza;
            } else if (i4 == 2) {
                zzbwVar = zzbw.zzb;
            } else {
                if (i4 != 3) {
                    throw new GeneralSecurityException("Unknown key status");
                }
                zzbwVar = zzbw.zzc;
            }
            arrayList.add(new zzca(zzbuVarZza, zzbwVar, iZza, iZza == zzvhVar.zzb()));
        }
        return Collections.unmodifiableList(arrayList);
    }

    private static void zzc(zzvh zzvhVar) throws GeneralSecurityException {
        if (zzvhVar == null || zzvhVar.zza() <= 0) {
            throw new GeneralSecurityException("empty keyset");
        }
    }

    public final zzby zza() throws GeneralSecurityException {
        if (this.zza != null) {
            zzvh.zzb zzbVarZzc = zzvh.zzc();
            for (zzvh.zza zzaVar : this.zza.zze()) {
                zzux zzuxVarZzb = zzaVar.zzb();
                if (zzuxVarZzb.zzb() == zzux.zzb.ASYMMETRIC_PRIVATE) {
                    zzbVarZzc.zza((zzvh.zza) ((zzaja) zzaVar.zzm().zza(zzcu.zza(zzuxVarZzb.zzf(), zzuxVarZzb.zze())).zzf()));
                } else {
                    throw new GeneralSecurityException("The keyset contains a non-private key");
                }
            }
            zzbVarZzc.zza(this.zza.zzb());
            return zza((zzvh) ((zzaja) zzbVarZzc.zzf()));
        }
        throw new GeneralSecurityException("cleartext keyset is not available");
    }

    public static final zzby zza(zzcb zzcbVar, zzbh zzbhVar) throws GeneralSecurityException {
        byte[] bArr = new byte[0];
        zzty zztyVarZza = zzcbVar.zza();
        if (zztyVarZza != null && zztyVarZza.zzc().zzb() != 0) {
            return zza(zza(zztyVarZza, zzbhVar, bArr));
        }
        throw new GeneralSecurityException("empty keyset");
    }

    private static zzot zza(zzvh.zza zzaVar) {
        try {
            return zzot.zza(zzaVar.zzb().zzf(), zzaVar.zzb().zze(), zzaVar.zzb().zzb(), zzaVar.zzf(), zzaVar.zzf() == zzvt.RAW ? null : Integer.valueOf(zzaVar.zza()));
        } catch (GeneralSecurityException e) {
            throw new zzpe("Creating a protokey serialization failed", e);
        }
    }

    private static zzty zza(zzvh zzvhVar, zzbh zzbhVar, byte[] bArr) throws GeneralSecurityException {
        byte[] bArrZzb = zzbhVar.zzb(zzvhVar.zzj(), bArr);
        try {
            if (zzvh.zza(zzbhVar.zza(bArrZzb, bArr), zzaip.zza()).equals(zzvhVar)) {
                return (zzty) ((zzaja) zzty.zza().zza(zzahm.zza(bArrZzb)).zza(zzcy.zza(zzvhVar)).zzf());
            }
            throw new GeneralSecurityException("cannot encrypt keyset");
        } catch (zzajj unused) {
            throw new GeneralSecurityException("invalid keyset, corrupted key material");
        }
    }

    private static zzvh zza(zzty zztyVar, zzbh zzbhVar, byte[] bArr) throws GeneralSecurityException {
        try {
            zzvh zzvhVarZza = zzvh.zza(zzbhVar.zza(zztyVar.zzc().zzg(), bArr), zzaip.zza());
            zzc(zzvhVarZza);
            return zzvhVarZza;
        } catch (zzajj unused) {
            throw new GeneralSecurityException("invalid keyset, corrupted key material");
        }
    }

    private static <B> B zza(zzmm zzmmVar, zzbu zzbuVar, Class<B> cls) {
        try {
            return (B) zzmmVar.zza(zzbuVar, cls);
        } catch (GeneralSecurityException unused) {
            return null;
        }
    }

    private static <B> B zza(zzmm zzmmVar, zzvh.zza zzaVar, Class<B> cls) throws GeneralSecurityException {
        try {
            return (B) zzmmVar.zza(zzaVar.zzb(), cls);
        } catch (UnsupportedOperationException unused) {
            return null;
        } catch (GeneralSecurityException e) {
            if (e.getMessage().contains("No key manager found for key type ") || e.getMessage().contains(" not supported by key manager of type ")) {
                return null;
            }
            throw e;
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final <P> P zza(Class<P> cls) throws GeneralSecurityException {
        zzox zzoxVarZza = zzox.zza();
        if (zzoxVarZza != null) {
            Class<?> clsZza = zzoxVarZza.zza(cls);
            if (clsZza != null) {
                zzcy.zzb(this.zza);
                zzck zzckVar = new zzck(clsZza);
                zzckVar.zza(this.zzc);
                for (int i4 = 0; i4 < this.zza.zza(); i4++) {
                    zzvh.zza zzaVarZza = this.zza.zza(i4);
                    if (zzaVarZza.zzc().equals(zzvb.ENABLED)) {
                        Object objZza = zza(zzoxVarZza, zzaVarZza, clsZza);
                        Object objZza2 = this.zzb.get(i4) != null ? zza(zzoxVarZza, this.zzb.get(i4).zza(), clsZza) : null;
                        if (objZza2 == null && objZza == null) {
                            throw new GeneralSecurityException("Unable to get primitive " + String.valueOf(clsZza) + " for key of type " + zzaVarZza.zzb().zzf());
                        }
                        if (zzaVarZza.zza() == this.zza.zzb()) {
                            zzckVar.zzb(objZza2, objZza, zzaVarZza);
                        } else {
                            zzckVar.zza(objZza2, objZza, zzaVarZza);
                        }
                    }
                }
                return (P) zzoxVarZza.zza(zzckVar.zza(), cls);
            }
            throw new GeneralSecurityException("No wrapper found for ".concat(cls.getName()));
        }
        throw new GeneralSecurityException("Currently only subclasses of InternalConfiguration are accepted");
    }

    public final void zza(zzce zzceVar, zzbh zzbhVar) {
        zzceVar.zza(zza(this.zza, zzbhVar, new byte[0]));
    }

    public final void zza(zzce zzceVar) throws GeneralSecurityException {
        for (zzvh.zza zzaVar : this.zza.zze()) {
            if (zzaVar.zzb().zzb() == zzux.zzb.UNKNOWN_KEYMATERIAL || zzaVar.zzb().zzb() == zzux.zzb.SYMMETRIC || zzaVar.zzb().zzb() == zzux.zzb.ASYMMETRIC_PRIVATE) {
                throw new GeneralSecurityException("keyset contains key material of type " + zzaVar.zzb().zzb().name() + " for type url " + zzaVar.zzb().zzf());
            }
        }
        zzceVar.zza(this.zza);
    }
}
