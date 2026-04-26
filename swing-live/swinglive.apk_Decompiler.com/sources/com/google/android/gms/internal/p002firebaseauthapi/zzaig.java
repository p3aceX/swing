package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.common.api.f;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzaig implements zzald {
    private final zzaib zza;
    private int zzb;
    private int zzc;
    private int zzd = 0;

    private zzaig(zzaib zzaibVar) {
        zzaib zzaibVar2 = (zzaib) zzajc.zza(zzaibVar, "input");
        this.zza = zzaibVar2;
        zzaibVar2.zzd = this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final double zza() throws zzaji {
        zzb(1);
        return this.zza.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final float zzb() throws zzaji {
        zzb(5);
        return this.zza.zzb();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzc() {
        int i4 = this.zzd;
        if (i4 != 0) {
            this.zzb = i4;
            this.zzd = 0;
        } else {
            this.zzb = this.zza.zzi();
        }
        int i5 = this.zzb;
        return (i5 == 0 || i5 == this.zzc) ? f.API_PRIORITY_OTHER : i5 >>> 3;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzd() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zze() throws zzaji {
        zzb(0);
        return this.zza.zzd();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzf() throws zzaji {
        zzb(5);
        return this.zza.zze();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzg() throws zzaji {
        zzb(0);
        return this.zza.zzf();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzh() throws zzaji {
        zzb(5);
        return this.zza.zzg();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzi() throws zzaji {
        zzb(0);
        return this.zza.zzh();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final int zzj() throws zzaji {
        zzb(0);
        return this.zza.zzj();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final long zzk() throws zzaji {
        zzb(1);
        return this.zza.zzk();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final long zzl() throws zzaji {
        zzb(0);
        return this.zza.zzl();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final long zzm() throws zzaji {
        zzb(1);
        return this.zza.zzn();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final long zzn() throws zzaji {
        zzb(0);
        return this.zza.zzo();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final long zzo() throws zzaji {
        zzb(0);
        return this.zza.zzp();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final zzahm zzp() throws zzaji {
        zzb(2);
        return this.zza.zzq();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final String zzq() throws zzaji {
        zzb(2);
        return this.zza.zzr();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final String zzr() throws zzaji {
        zzb(2);
        return this.zza.zzs();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final boolean zzs() throws zzaji {
        zzb(0);
        return this.zza.zzu();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final boolean zzt() {
        int i4;
        if (this.zza.zzt() || (i4 = this.zzb) == this.zzc) {
            return false;
        }
        return this.zza.zzd(i4);
    }

    private final <T> void zzd(T t4, zzalc<T> zzalcVar, zzaip zzaipVar) throws zzajj {
        int iZzj = this.zza.zzj();
        zzaib zzaibVar = this.zza;
        if (zzaibVar.zza >= zzaibVar.zzb) {
            throw new zzajj("Protocol message had too many levels of nesting.  May be malicious.  Use CodedInputStream.setRecursionLimit() to increase the depth limit.");
        }
        int iZza = zzaibVar.zza(iZzj);
        this.zza.zza++;
        zzalcVar.zza(t4, this, zzaipVar);
        this.zza.zzb(0);
        r5.zza--;
        this.zza.zzc(iZza);
    }

    public static zzaig zza(zzaib zzaibVar) {
        zzaig zzaigVar = zzaibVar.zzd;
        return zzaigVar != null ? zzaigVar : new zzaig(zzaibVar);
    }

    private final <T> T zzb(zzalc<T> zzalcVar, zzaip zzaipVar) throws zzajj {
        T tZza = zzalcVar.zza();
        zzd(tZza, zzalcVar, zzaipVar);
        zzalcVar.zzc(tZza);
        return tZza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zze(List<Integer> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajd) {
            zzajd zzajdVar = (zzajd) list;
            int i4 = this.zzb & 7;
            if (i4 == 2) {
                int iZzj = this.zza.zzj();
                zzc(iZzj);
                int iZzc = this.zza.zzc() + iZzj;
                do {
                    zzajdVar.zzc(this.zza.zze());
                } while (this.zza.zzc() < iZzc);
                return;
            }
            if (i4 == 5) {
                do {
                    zzajdVar.zzc(this.zza.zze());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 2) {
            int iZzj2 = this.zza.zzj();
            zzc(iZzj2);
            int iZzc2 = this.zza.zzc() + iZzj2;
            do {
                list.add(Integer.valueOf(this.zza.zze()));
            } while (this.zza.zzc() < iZzc2);
            return;
        }
        if (i5 == 5) {
            do {
                list.add(Integer.valueOf(this.zza.zze()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzf(List<Long> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajz) {
            zzajz zzajzVar = (zzajz) list;
            int i4 = this.zzb & 7;
            if (i4 == 1) {
                do {
                    zzajzVar.zza(this.zza.zzk());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzj = this.zza.zzj();
                zzd(iZzj);
                int iZzc = this.zza.zzc() + iZzj;
                do {
                    zzajzVar.zza(this.zza.zzk());
                } while (this.zza.zzc() < iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 1) {
            do {
                list.add(Long.valueOf(this.zza.zzk()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzj2 = this.zza.zzj();
            zzd(iZzj2);
            int iZzc2 = this.zza.zzc() + iZzj2;
            do {
                list.add(Long.valueOf(this.zza.zzk()));
            } while (this.zza.zzc() < iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzg(List<Float> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzaiy) {
            zzaiy zzaiyVar = (zzaiy) list;
            int i4 = this.zzb & 7;
            if (i4 == 2) {
                int iZzj = this.zza.zzj();
                zzc(iZzj);
                int iZzc = this.zza.zzc() + iZzj;
                do {
                    zzaiyVar.zza(this.zza.zzb());
                } while (this.zza.zzc() < iZzc);
                return;
            }
            if (i4 == 5) {
                do {
                    zzaiyVar.zza(this.zza.zzb());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 2) {
            int iZzj2 = this.zza.zzj();
            zzc(iZzj2);
            int iZzc2 = this.zza.zzc() + iZzj2;
            do {
                list.add(Float.valueOf(this.zza.zzb()));
            } while (this.zza.zzc() < iZzc2);
            return;
        }
        if (i5 == 5) {
            do {
                list.add(Float.valueOf(this.zza.zzb()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzh(List<Integer> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajd) {
            zzajd zzajdVar = (zzajd) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajdVar.zzc(this.zza.zzf());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajdVar.zzc(this.zza.zzf());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Integer.valueOf(this.zza.zzf()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Integer.valueOf(this.zza.zzf()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzi(List<Long> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajz) {
            zzajz zzajzVar = (zzajz) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajzVar.zza(this.zza.zzl());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajzVar.zza(this.zza.zzl());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Long.valueOf(this.zza.zzl()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Long.valueOf(this.zza.zzl()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzj(List<Integer> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajd) {
            zzajd zzajdVar = (zzajd) list;
            int i4 = this.zzb & 7;
            if (i4 == 2) {
                int iZzj = this.zza.zzj();
                zzc(iZzj);
                int iZzc = this.zza.zzc() + iZzj;
                do {
                    zzajdVar.zzc(this.zza.zzg());
                } while (this.zza.zzc() < iZzc);
                return;
            }
            if (i4 == 5) {
                do {
                    zzajdVar.zzc(this.zza.zzg());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 2) {
            int iZzj2 = this.zza.zzj();
            zzc(iZzj2);
            int iZzc2 = this.zza.zzc() + iZzj2;
            do {
                list.add(Integer.valueOf(this.zza.zzg()));
            } while (this.zza.zzc() < iZzc2);
            return;
        }
        if (i5 == 5) {
            do {
                list.add(Integer.valueOf(this.zza.zzg()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzk(List<Long> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajz) {
            zzajz zzajzVar = (zzajz) list;
            int i4 = this.zzb & 7;
            if (i4 == 1) {
                do {
                    zzajzVar.zza(this.zza.zzn());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzj = this.zza.zzj();
                zzd(iZzj);
                int iZzc = this.zza.zzc() + iZzj;
                do {
                    zzajzVar.zza(this.zza.zzn());
                } while (this.zza.zzc() < iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 1) {
            do {
                list.add(Long.valueOf(this.zza.zzn()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzj2 = this.zza.zzj();
            zzd(iZzj2);
            int iZzc2 = this.zza.zzc() + iZzj2;
            do {
                list.add(Long.valueOf(this.zza.zzn()));
            } while (this.zza.zzc() < iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzl(List<Integer> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajd) {
            zzajd zzajdVar = (zzajd) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajdVar.zzc(this.zza.zzh());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajdVar.zzc(this.zza.zzh());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Integer.valueOf(this.zza.zzh()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Integer.valueOf(this.zza.zzh()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzm(List<Long> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajz) {
            zzajz zzajzVar = (zzajz) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajzVar.zza(this.zza.zzo());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajzVar.zza(this.zza.zzo());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Long.valueOf(this.zza.zzo()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Long.valueOf(this.zza.zzo()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzn(List<String> list) throws zzaji {
        zza(list, false);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzo(List<String> list) throws zzaji {
        zza(list, true);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzp(List<Integer> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajd) {
            zzajd zzajdVar = (zzajd) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajdVar.zzc(this.zza.zzj());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajdVar.zzc(this.zza.zzj());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Integer.valueOf(this.zza.zzj()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Integer.valueOf(this.zza.zzj()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzq(List<Long> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajz) {
            zzajz zzajzVar = (zzajz) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajzVar.zza(this.zza.zzp());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajzVar.zza(this.zza.zzp());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Long.valueOf(this.zza.zzp()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Long.valueOf(this.zza.zzp()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    private final Object zza(zzamo zzamoVar, Class<?> cls, zzaip zzaipVar) throws zzaji {
        switch (zzaij.zza[zzamoVar.ordinal()]) {
            case 1:
                return Boolean.valueOf(zzs());
            case 2:
                return zzp();
            case 3:
                return Double.valueOf(zza());
            case 4:
                return Integer.valueOf(zze());
            case 5:
                return Integer.valueOf(zzf());
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return Long.valueOf(zzk());
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return Float.valueOf(zzb());
            case k.BYTES_FIELD_NUMBER /* 8 */:
                return Integer.valueOf(zzg());
            case 9:
                return Long.valueOf(zzl());
            case 10:
                zzb(2);
                return zzb(zzaky.zza().zza((Class) cls), zzaipVar);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return Integer.valueOf(zzh());
            case 12:
                return Long.valueOf(zzm());
            case 13:
                return Integer.valueOf(zzi());
            case 14:
                return Long.valueOf(zzn());
            case 15:
                return zzr();
            case 16:
                return Integer.valueOf(zzj());
            case 17:
                return Long.valueOf(zzo());
            default:
                throw new IllegalArgumentException("unsupported field type.");
        }
    }

    private final <T> void zzc(T t4, zzalc<T> zzalcVar, zzaip zzaipVar) {
        int i4 = this.zzc;
        this.zzc = ((this.zzb >>> 3) << 3) | 4;
        try {
            zzalcVar.zza(t4, this, zzaipVar);
            if (this.zzb == this.zzc) {
            } else {
                throw zzajj.zzg();
            }
        } finally {
            this.zzc = i4;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final <T> void zzb(T t4, zzalc<T> zzalcVar, zzaip zzaipVar) throws zzajj {
        zzb(2);
        zzd(t4, zzalcVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzb(List<zzahm> list) throws zzaji {
        int iZzi;
        if ((this.zzb & 7) == 2) {
            do {
                list.add(zzp());
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzd(List<Integer> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzajd) {
            zzajd zzajdVar = (zzajd) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzajdVar.zzc(this.zza.zzd());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzajdVar.zzc(this.zza.zzd());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Integer.valueOf(this.zza.zzd()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Integer.valueOf(this.zza.zzd()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final <T> void zzb(List<T> list, zzalc<T> zzalcVar, zzaip zzaipVar) throws zzaji {
        int iZzi;
        int i4 = this.zzb;
        if ((i4 & 7) == 2) {
            do {
                list.add(zzb(zzalcVar, zzaipVar));
                if (this.zza.zzt() || this.zzd != 0) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == i4);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zzc(List<Double> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzain) {
            zzain zzainVar = (zzain) list;
            int i4 = this.zzb & 7;
            if (i4 == 1) {
                do {
                    zzainVar.zza(this.zza.zza());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzj = this.zza.zzj();
                zzd(iZzj);
                int iZzc = this.zza.zzc() + iZzj;
                do {
                    zzainVar.zza(this.zza.zza());
                } while (this.zza.zzc() < iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 1) {
            do {
                list.add(Double.valueOf(this.zza.zza()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzj2 = this.zza.zzj();
            zzd(iZzj2);
            int iZzc2 = this.zza.zzc() + iZzj2;
            do {
                list.add(Double.valueOf(this.zza.zza()));
            } while (this.zza.zzc() < iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    private final void zzb(int i4) throws zzaji {
        if ((this.zzb & 7) != i4) {
            throw zzajj.zza();
        }
    }

    private final <T> T zza(zzalc<T> zzalcVar, zzaip zzaipVar) {
        T tZza = zzalcVar.zza();
        zzc(tZza, zzalcVar, zzaipVar);
        zzalcVar.zzc(tZza);
        return tZza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final <T> void zza(T t4, zzalc<T> zzalcVar, zzaip zzaipVar) throws zzaji {
        zzb(3);
        zzc(t4, zzalcVar, zzaipVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    public final void zza(List<Boolean> list) throws zzajj {
        int iZzi;
        int iZzi2;
        if (list instanceof zzahk) {
            zzahk zzahkVar = (zzahk) list;
            int i4 = this.zzb & 7;
            if (i4 == 0) {
                do {
                    zzahkVar.zza(this.zza.zzu());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            if (i4 == 2) {
                int iZzc = this.zza.zzc() + this.zza.zzj();
                do {
                    zzahkVar.zza(this.zza.zzu());
                } while (this.zza.zzc() < iZzc);
                zza(iZzc);
                return;
            }
            throw zzajj.zza();
        }
        int i5 = this.zzb & 7;
        if (i5 == 0) {
            do {
                list.add(Boolean.valueOf(this.zza.zzu()));
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        if (i5 == 2) {
            int iZzc2 = this.zza.zzc() + this.zza.zzj();
            do {
                list.add(Boolean.valueOf(this.zza.zzu()));
            } while (this.zza.zzc() < iZzc2);
            zza(iZzc2);
            return;
        }
        throw zzajj.zza();
    }

    private static void zzd(int i4) throws zzajj {
        if ((i4 & 7) != 0) {
            throw zzajj.zzg();
        }
    }

    private static void zzc(int i4) throws zzajj {
        if ((i4 & 3) != 0) {
            throw zzajj.zzg();
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    @Deprecated
    public final <T> void zza(List<T> list, zzalc<T> zzalcVar, zzaip zzaipVar) throws zzaji {
        int iZzi;
        int i4 = this.zzb;
        if ((i4 & 7) == 3) {
            do {
                list.add(zza(zzalcVar, zzaipVar));
                if (this.zza.zzt() || this.zzd != 0) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == i4);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    /* JADX WARN: Code restructure failed: missing block: B:25:0x005d, code lost:
    
        r8.put(r2, r3);
     */
    /* JADX WARN: Code restructure failed: missing block: B:26:0x0060, code lost:
    
        r7.zza.zzc(r1);
     */
    /* JADX WARN: Code restructure failed: missing block: B:27:0x0065, code lost:
    
        return;
     */
    /* JADX WARN: Multi-variable type inference failed */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzald
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final <K, V> void zza(java.util.Map<K, V> r8, com.google.android.gms.internal.p002firebaseauthapi.zzakf<K, V> r9, com.google.android.gms.internal.p002firebaseauthapi.zzaip r10) throws com.google.android.gms.internal.p002firebaseauthapi.zzaji {
        /*
            r7 = this;
            r0 = 2
            r7.zzb(r0)
            com.google.android.gms.internal.firebase-auth-api.zzaib r1 = r7.zza
            int r1 = r1.zzj()
            com.google.android.gms.internal.firebase-auth-api.zzaib r2 = r7.zza
            int r1 = r2.zza(r1)
            K r2 = r9.zzb
            V r3 = r9.zzd
        L14:
            int r4 = r7.zzc()     // Catch: java.lang.Throwable -> L39
            r5 = 2147483647(0x7fffffff, float:NaN)
            if (r4 == r5) goto L5d
            com.google.android.gms.internal.firebase-auth-api.zzaib r5 = r7.zza     // Catch: java.lang.Throwable -> L39
            boolean r5 = r5.zzt()     // Catch: java.lang.Throwable -> L39
            if (r5 != 0) goto L5d
            r5 = 1
            java.lang.String r6 = "Unable to parse map entry."
            if (r4 == r5) goto L48
            if (r4 == r0) goto L3b
            boolean r4 = r7.zzt()     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            if (r4 == 0) goto L33
            goto L14
        L33:
            com.google.android.gms.internal.firebase-auth-api.zzajj r4 = new com.google.android.gms.internal.firebase-auth-api.zzajj     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            r4.<init>(r6)     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            throw r4     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
        L39:
            r8 = move-exception
            goto L66
        L3b:
            com.google.android.gms.internal.firebase-auth-api.zzamo r4 = r9.zzc     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            V r5 = r9.zzd     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            java.lang.Class r5 = r5.getClass()     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            java.lang.Object r3 = r7.zza(r4, r5, r10)     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            goto L14
        L48:
            com.google.android.gms.internal.firebase-auth-api.zzamo r4 = r9.zza     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            r5 = 0
            java.lang.Object r2 = r7.zza(r4, r5, r5)     // Catch: java.lang.Throwable -> L39 com.google.android.gms.internal.p002firebaseauthapi.zzaji -> L50
            goto L14
        L50:
            boolean r4 = r7.zzt()     // Catch: java.lang.Throwable -> L39
            if (r4 == 0) goto L57
            goto L14
        L57:
            com.google.android.gms.internal.firebase-auth-api.zzajj r8 = new com.google.android.gms.internal.firebase-auth-api.zzajj     // Catch: java.lang.Throwable -> L39
            r8.<init>(r6)     // Catch: java.lang.Throwable -> L39
            throw r8     // Catch: java.lang.Throwable -> L39
        L5d:
            r8.put(r2, r3)     // Catch: java.lang.Throwable -> L39
            com.google.android.gms.internal.firebase-auth-api.zzaib r8 = r7.zza
            r8.zzc(r1)
            return
        L66:
            com.google.android.gms.internal.firebase-auth-api.zzaib r9 = r7.zza
            r9.zzc(r1)
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzaig.zza(java.util.Map, com.google.android.gms.internal.firebase-auth-api.zzakf, com.google.android.gms.internal.firebase-auth-api.zzaip):void");
    }

    private final void zza(List<String> list, boolean z4) throws zzaji {
        int iZzi;
        int iZzi2;
        if ((this.zzb & 7) == 2) {
            if ((list instanceof zzajq) && !z4) {
                zzajq zzajqVar = (zzajq) list;
                do {
                    zzajqVar.zza(zzp());
                    if (this.zza.zzt()) {
                        return;
                    } else {
                        iZzi2 = this.zza.zzi();
                    }
                } while (iZzi2 == this.zzb);
                this.zzd = iZzi2;
                return;
            }
            do {
                list.add(z4 ? zzr() : zzq());
                if (this.zza.zzt()) {
                    return;
                } else {
                    iZzi = this.zza.zzi();
                }
            } while (iZzi == this.zzb);
            this.zzd = iZzi;
            return;
        }
        throw zzajj.zza();
    }

    private final void zza(int i4) throws zzajj {
        if (this.zza.zzc() != i4) {
            throw zzajj.zzi();
        }
    }
}
