package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public class zzajo {
    private static final zzaip zza = zzaip.zza;
    private zzahm zzb;
    private volatile zzakk zzc;
    private volatile zzahm zzd;

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof zzajo)) {
            return false;
        }
        zzajo zzajoVar = (zzajo) obj;
        zzakk zzakkVar = this.zzc;
        zzakk zzakkVar2 = zzajoVar.zzc;
        return (zzakkVar == null && zzakkVar2 == null) ? zzc().equals(zzajoVar.zzc()) : (zzakkVar == null || zzakkVar2 == null) ? zzakkVar != null ? zzakkVar.equals(zzajoVar.zzb(zzakkVar.zzr())) : zzb(zzakkVar2.zzr()).equals(zzakkVar2) : zzakkVar.equals(zzakkVar2);
    }

    public int hashCode() {
        return 1;
    }

    public final zzakk zza(zzakk zzakkVar) {
        zzakk zzakkVar2 = this.zzc;
        this.zzb = null;
        this.zzd = null;
        this.zzc = zzakkVar;
        return zzakkVar2;
    }

    public final int zzb() {
        if (this.zzd != null) {
            return this.zzd.zzb();
        }
        if (this.zzc != null) {
            return this.zzc.zzk();
        }
        return 0;
    }

    public final zzahm zzc() {
        if (this.zzd != null) {
            return this.zzd;
        }
        synchronized (this) {
            try {
                if (this.zzd != null) {
                    return this.zzd;
                }
                if (this.zzc == null) {
                    this.zzd = zzahm.zza;
                } else {
                    this.zzd = this.zzc.zzi();
                }
                return this.zzd;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    private final zzakk zzb(zzakk zzakkVar) {
        if (this.zzc == null) {
            synchronized (this) {
                if (this.zzc == null) {
                    try {
                        this.zzc = zzakkVar;
                        this.zzd = zzahm.zza;
                    } catch (zzajj unused) {
                        this.zzc = zzakkVar;
                        this.zzd = zzahm.zza;
                    }
                }
            }
        }
        return this.zzc;
    }
}
