package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzvh;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzck<P> {
    private final Class<P> zza;
    private ConcurrentMap<zzcl, List<zzcm<P>>> zzb;
    private final List<zzcm<P>> zzc;
    private zzcm<P> zzd;
    private zzrl zze;

    public final zzck<P> zza(P p4, P p5, zzvh.zza zzaVar) {
        return zza(p4, p5, zzaVar, false);
    }

    public final zzck<P> zzb(P p4, P p5, zzvh.zza zzaVar) {
        return zza(p4, p5, zzaVar, true);
    }

    private zzck(Class<P> cls) {
        this.zzb = new ConcurrentHashMap();
        this.zzc = new ArrayList();
        this.zza = cls;
        this.zze = zzrl.zza;
    }

    private final zzck<P> zza(P p4, P p5, zzvh.zza zzaVar, boolean z4) throws GeneralSecurityException {
        byte[] bArrArray;
        if (this.zzb == null) {
            throw new IllegalStateException("addPrimitive cannot be called after build");
        }
        if (p4 == null && p5 == null) {
            throw new GeneralSecurityException("at least one of the `fullPrimitive` or `primitive` must be set");
        }
        if (zzaVar.zzc() != zzvb.ENABLED) {
            throw new GeneralSecurityException("only ENABLED key is allowed");
        }
        Integer numValueOf = Integer.valueOf(zzaVar.zza());
        if (zzaVar.zzf() == zzvt.RAW) {
            numValueOf = null;
        }
        zzbu zzbuVarZza = zznv.zza().zza(zzot.zza(zzaVar.zzb().zzf(), zzaVar.zzb().zze(), zzaVar.zzb().zzb(), zzaVar.zzf(), numValueOf), zzct.zza());
        int i4 = zzbn.zza[zzaVar.zzf().ordinal()];
        if (i4 == 1 || i4 == 2) {
            bArrArray = ByteBuffer.allocate(5).put((byte) 0).putInt(zzaVar.zza()).array();
        } else if (i4 == 3) {
            bArrArray = ByteBuffer.allocate(5).put((byte) 1).putInt(zzaVar.zza()).array();
        } else {
            if (i4 != 4) {
                throw new GeneralSecurityException("unknown output prefix type");
            }
            bArrArray = zzbo.zza;
        }
        zzcm<P> zzcmVar = new zzcm<>(p4, p5, bArrArray, zzaVar.zzc(), zzaVar.zzf(), zzaVar.zza(), zzaVar.zzb().zzf(), zzbuVarZza);
        ConcurrentMap<zzcl, List<zzcm<P>>> concurrentMap = this.zzb;
        List<zzcm<P>> list = this.zzc;
        ArrayList arrayList = new ArrayList();
        arrayList.add(zzcmVar);
        zzcl zzclVar = new zzcl(zzcmVar.zzh());
        List<zzcm<P>> listPut = concurrentMap.put(zzclVar, Collections.unmodifiableList(arrayList));
        if (listPut != null) {
            ArrayList arrayList2 = new ArrayList();
            arrayList2.addAll(listPut);
            arrayList2.add(zzcmVar);
            concurrentMap.put(zzclVar, Collections.unmodifiableList(arrayList2));
        }
        list.add(zzcmVar);
        if (!z4) {
            return this;
        }
        if (this.zzd != null) {
            throw new IllegalStateException("you cannot set two primary primitives");
        }
        this.zzd = zzcmVar;
        return this;
    }

    public final zzck<P> zza(zzrl zzrlVar) {
        if (this.zzb != null) {
            this.zze = zzrlVar;
            return this;
        }
        throw new IllegalStateException("setAnnotations cannot be called after build");
    }

    public final zzch<P> zza() {
        ConcurrentMap<zzcl, List<zzcm<P>>> concurrentMap = this.zzb;
        if (concurrentMap != null) {
            zzch<P> zzchVar = new zzch<>(concurrentMap, this.zzc, this.zzd, this.zze, this.zza);
            this.zzb = null;
            return zzchVar;
        }
        throw new IllegalStateException("build cannot be called twice");
    }
}
