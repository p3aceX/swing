package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zznd<P> implements zzbt<P> {
    private final String zza;
    private final Class<P> zzb;
    private final zzux.zzb zzc;
    private final zzakx<? extends zzakk> zzd;

    private zznd(String str, Class<P> cls, zzux.zzb zzbVar, zzakx<? extends zzakk> zzakxVar) {
        this.zzd = zzakxVar;
        this.zza = str;
        this.zzb = cls;
        this.zzc = zzbVar;
    }

    public static <P> zzbt<P> zza(String str, Class<P> cls, zzux.zzb zzbVar, zzakx<? extends zzakk> zzakxVar) {
        return new zznd(str, cls, zzbVar, zzakxVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final P zzb(zzahm zzahmVar) throws GeneralSecurityException {
        return (P) zzns.zza().zza(zznv.zza().zza(zzot.zza(this.zza, zzahmVar, this.zzc, zzvt.RAW, null), zzbr.zza()), this.zzb);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final zzux zza(zzahm zzahmVar) {
        zzot zzotVar = (zzot) zznv.zza().zza(zznk.zza().zza(zznv.zza().zza(zzos.zza((zzvd) ((zzaja) zzvd.zza().zza(this.zza).zza(zzahmVar).zza(zzvt.RAW).zzf()))), (Integer) null), zzot.class, zzbr.zza());
        return (zzux) ((zzaja) zzux.zza().zza(zzotVar.zzf()).zza(zzotVar.zzd()).zza(zzotVar.zza()).zzf());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final String zzb() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbt
    public final Class<P> zza() {
        return this.zzb;
    }
}
