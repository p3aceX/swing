package com.google.android.recaptcha.internal;

import com.google.android.gms.common.api.f;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzhd implements zzkq {
    private final zzhc zza;
    private int zzb;
    private int zzc;
    private int zzd = 0;

    private zzhd(zzhc zzhcVar) {
        byte[] bArr = zzjc.zzd;
        this.zza = zzhcVar;
        zzhcVar.zzc = this;
    }

    private final void zzP(Object obj, zzkr zzkrVar, zzie zzieVar) {
        int i4 = this.zzc;
        this.zzc = ((this.zzb >>> 3) << 3) | 4;
        try {
            zzkrVar.zzh(obj, this, zzieVar);
            if (this.zzb == this.zzc) {
            } else {
                throw zzje.zzg();
            }
        } finally {
            this.zzc = i4;
        }
    }

    private final void zzQ(Object obj, zzkr zzkrVar, zzie zzieVar) throws zzje {
        zzhc zzhcVar = this.zza;
        int iZzn = zzhcVar.zzn();
        if (zzhcVar.zza >= zzhcVar.zzb) {
            throw new zzje("Protocol message had too many levels of nesting.  May be malicious.  Use CodedInputStream.setRecursionLimit() to increase the depth limit.");
        }
        int iZze = this.zza.zze(iZzn);
        this.zza.zza++;
        zzkrVar.zzh(obj, this, zzieVar);
        this.zza.zzz(0);
        r4.zza--;
        this.zza.zzA(iZze);
    }

    private final void zzR(int i4) throws zzje {
        if (this.zza.zzd() != i4) {
            throw zzje.zzj();
        }
    }

    private final void zzS(int i4) throws zzjd {
        if ((this.zzb & 7) != i4) {
            throw zzje.zza();
        }
    }

    private static final void zzT(int i4) throws zzje {
        if ((i4 & 3) != 0) {
            throw zzje.zzg();
        }
    }

    private static final void zzU(int i4) throws zzje {
        if ((i4 & 7) != 0) {
            throw zzje.zzg();
        }
    }

    public static zzhd zzq(zzhc zzhcVar) {
        zzhd zzhdVar = zzhcVar.zzc;
        return zzhdVar != null ? zzhdVar : new zzhd(zzhcVar);
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzA(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzjt) {
            zzjt zzjtVar = (zzjt) list;
            int i4 = this.zzb & 7;
            if (i4 != 1) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                int iZzn = this.zza.zzn();
                zzU(iZzn);
                int iZzd = this.zza.zzd() + iZzn;
                do {
                    zzjtVar.zzg(this.zza.zzo());
                } while (this.zza.zzd() < iZzd);
                return;
            }
            do {
                zzjtVar.zzg(this.zza.zzo());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 1) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                int iZzn2 = this.zza.zzn();
                zzU(iZzn2);
                int iZzd2 = this.zza.zzd() + iZzn2;
                do {
                    list.add(Long.valueOf(this.zza.zzo()));
                } while (this.zza.zzd() < iZzd2);
                return;
            }
            do {
                list.add(Long.valueOf(this.zza.zzo()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzB(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzil) {
            zzil zzilVar = (zzil) list;
            int i4 = this.zzb & 7;
            if (i4 == 2) {
                int iZzn = this.zza.zzn();
                zzT(iZzn);
                int iZzd = this.zza.zzd() + iZzn;
                do {
                    zzilVar.zze(this.zza.zzc());
                } while (this.zza.zzd() < iZzd);
                return;
            }
            if (i4 != 5) {
                throw zzje.zza();
            }
            do {
                zzilVar.zze(this.zza.zzc());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 == 2) {
                int iZzn2 = this.zza.zzn();
                zzT(iZzn2);
                int iZzd2 = this.zza.zzd() + iZzn2;
                do {
                    list.add(Float.valueOf(this.zza.zzc()));
                } while (this.zza.zzd() < iZzd2);
                return;
            }
            if (i5 != 5) {
                throw zzje.zza();
            }
            do {
                list.add(Float.valueOf(this.zza.zzc()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    @Deprecated
    public final void zzC(List list, zzkr zzkrVar, zzie zzieVar) throws zzjd {
        int iZzm;
        int i4 = this.zzb;
        if ((i4 & 7) != 3) {
            throw zzje.zza();
        }
        do {
            Object objZze = zzkrVar.zze();
            zzP(objZze, zzkrVar, zzieVar);
            zzkrVar.zzf(objZze);
            list.add(objZze);
            if (this.zza.zzC() || this.zzd != 0) {
                return;
            } else {
                iZzm = this.zza.zzm();
            }
        } while (iZzm == i4);
        this.zzd = iZzm;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzD(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zziu) {
            zziu zziuVar = (zziu) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zziuVar.zzg(this.zza.zzh());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zziuVar.zzg(this.zza.zzh());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Integer.valueOf(this.zza.zzh()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Integer.valueOf(this.zza.zzh()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzE(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzjt) {
            zzjt zzjtVar = (zzjt) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zzjtVar.zzg(this.zza.zzp());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zzjtVar.zzg(this.zza.zzp());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Long.valueOf(this.zza.zzp()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Long.valueOf(this.zza.zzp()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzF(List list, zzkr zzkrVar, zzie zzieVar) throws zzje {
        int iZzm;
        int i4 = this.zzb;
        if ((i4 & 7) != 2) {
            throw zzje.zza();
        }
        do {
            Object objZze = zzkrVar.zze();
            zzQ(objZze, zzkrVar, zzieVar);
            zzkrVar.zzf(objZze);
            list.add(objZze);
            if (this.zza.zzC() || this.zzd != 0) {
                return;
            } else {
                iZzm = this.zza.zzm();
            }
        } while (iZzm == i4);
        this.zzd = iZzm;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzG(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zziu) {
            zziu zziuVar = (zziu) list;
            int i4 = this.zzb & 7;
            if (i4 == 2) {
                int iZzn = this.zza.zzn();
                zzT(iZzn);
                int iZzd = this.zza.zzd() + iZzn;
                do {
                    zziuVar.zzg(this.zza.zzk());
                } while (this.zza.zzd() < iZzd);
                return;
            }
            if (i4 != 5) {
                throw zzje.zza();
            }
            do {
                zziuVar.zzg(this.zza.zzk());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 == 2) {
                int iZzn2 = this.zza.zzn();
                zzT(iZzn2);
                int iZzd2 = this.zza.zzd() + iZzn2;
                do {
                    list.add(Integer.valueOf(this.zza.zzk()));
                } while (this.zza.zzd() < iZzd2);
                return;
            }
            if (i5 != 5) {
                throw zzje.zza();
            }
            do {
                list.add(Integer.valueOf(this.zza.zzk()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzH(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzjt) {
            zzjt zzjtVar = (zzjt) list;
            int i4 = this.zzb & 7;
            if (i4 != 1) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                int iZzn = this.zza.zzn();
                zzU(iZzn);
                int iZzd = this.zza.zzd() + iZzn;
                do {
                    zzjtVar.zzg(this.zza.zzt());
                } while (this.zza.zzd() < iZzd);
                return;
            }
            do {
                zzjtVar.zzg(this.zza.zzt());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 1) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                int iZzn2 = this.zza.zzn();
                zzU(iZzn2);
                int iZzd2 = this.zza.zzd() + iZzn2;
                do {
                    list.add(Long.valueOf(this.zza.zzt()));
                } while (this.zza.zzd() < iZzd2);
                return;
            }
            do {
                list.add(Long.valueOf(this.zza.zzt()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzI(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zziu) {
            zziu zziuVar = (zziu) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zziuVar.zzg(this.zza.zzl());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zziuVar.zzg(this.zza.zzl());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Integer.valueOf(this.zza.zzl()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Integer.valueOf(this.zza.zzl()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzJ(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzjt) {
            zzjt zzjtVar = (zzjt) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zzjtVar.zzg(this.zza.zzu());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zzjtVar.zzg(this.zza.zzu());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Long.valueOf(this.zza.zzu()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Long.valueOf(this.zza.zzu()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    public final void zzK(List list, boolean z4) throws zzjd {
        int iZzm;
        int iZzm2;
        if ((this.zzb & 7) != 2) {
            throw zzje.zza();
        }
        if ((list instanceof zzjm) && !z4) {
            zzjm zzjmVar = (zzjm) list;
            do {
                zzjmVar.zzi(zzp());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            do {
                list.add(z4 ? zzs() : zzr());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzL(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zziu) {
            zziu zziuVar = (zziu) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zziuVar.zzg(this.zza.zzn());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zziuVar.zzg(this.zza.zzn());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Integer.valueOf(this.zza.zzn()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Integer.valueOf(this.zza.zzn()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzM(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzjt) {
            zzjt zzjtVar = (zzjt) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zzjtVar.zzg(this.zza.zzv());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zzjtVar.zzg(this.zza.zzv());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Long.valueOf(this.zza.zzv()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Long.valueOf(this.zza.zzv()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final boolean zzN() throws zzjd {
        zzS(0);
        return this.zza.zzD();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final boolean zzO() {
        int i4;
        if (this.zza.zzC() || (i4 = this.zzb) == this.zzc) {
            return false;
        }
        return this.zza.zzE(i4);
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final double zza() throws zzjd {
        zzS(1);
        return this.zza.zzb();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final float zzb() throws zzjd {
        zzS(5);
        return this.zza.zzc();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzc() {
        int iZzm = this.zzd;
        if (iZzm != 0) {
            this.zzb = iZzm;
            this.zzd = 0;
        } else {
            iZzm = this.zza.zzm();
            this.zzb = iZzm;
        }
        return (iZzm == 0 || iZzm == this.zzc) ? f.API_PRIORITY_OTHER : iZzm >>> 3;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzd() {
        return this.zzb;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zze() throws zzjd {
        zzS(0);
        return this.zza.zzf();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzf() throws zzjd {
        zzS(5);
        return this.zza.zzg();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzg() throws zzjd {
        zzS(0);
        return this.zza.zzh();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzh() throws zzjd {
        zzS(5);
        return this.zza.zzk();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzi() throws zzjd {
        zzS(0);
        return this.zza.zzl();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final int zzj() throws zzjd {
        zzS(0);
        return this.zza.zzn();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final long zzk() throws zzjd {
        zzS(1);
        return this.zza.zzo();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final long zzl() throws zzjd {
        zzS(0);
        return this.zza.zzp();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final long zzm() throws zzjd {
        zzS(1);
        return this.zza.zzt();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final long zzn() throws zzjd {
        zzS(0);
        return this.zza.zzu();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final long zzo() throws zzjd {
        zzS(0);
        return this.zza.zzv();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final zzgw zzp() throws zzjd {
        zzS(2);
        return this.zza.zzw();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final String zzr() throws zzjd {
        zzS(2);
        return this.zza.zzx();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final String zzs() throws zzjd {
        zzS(2);
        return this.zza.zzy();
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzt(Object obj, zzkr zzkrVar, zzie zzieVar) throws zzjd {
        zzS(3);
        zzP(obj, zzkrVar, zzieVar);
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzu(Object obj, zzkr zzkrVar, zzie zzieVar) throws zzje {
        zzS(2);
        zzQ(obj, zzkrVar, zzieVar);
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzv(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzgl) {
            zzgl zzglVar = (zzgl) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zzglVar.zze(this.zza.zzD());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zzglVar.zze(this.zza.zzD());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Boolean.valueOf(this.zza.zzD()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Boolean.valueOf(this.zza.zzD()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzw(List list) throws zzjd {
        int iZzm;
        if ((this.zzb & 7) != 2) {
            throw zzje.zza();
        }
        do {
            list.add(zzp());
            if (this.zza.zzC()) {
                return;
            } else {
                iZzm = this.zza.zzm();
            }
        } while (iZzm == this.zzb);
        this.zzd = iZzm;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzx(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zzhy) {
            zzhy zzhyVar = (zzhy) list;
            int i4 = this.zzb & 7;
            if (i4 != 1) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                int iZzn = this.zza.zzn();
                zzU(iZzn);
                int iZzd = this.zza.zzd() + iZzn;
                do {
                    zzhyVar.zze(this.zza.zzb());
                } while (this.zza.zzd() < iZzd);
                return;
            }
            do {
                zzhyVar.zze(this.zza.zzb());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 1) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                int iZzn2 = this.zza.zzn();
                zzU(iZzn2);
                int iZzd2 = this.zza.zzd() + iZzn2;
                do {
                    list.add(Double.valueOf(this.zza.zzb()));
                } while (this.zza.zzd() < iZzd2);
                return;
            }
            do {
                list.add(Double.valueOf(this.zza.zzb()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzy(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zziu) {
            zziu zziuVar = (zziu) list;
            int i4 = this.zzb & 7;
            if (i4 != 0) {
                if (i4 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar = this.zza;
                int iZzd = zzhcVar.zzd() + zzhcVar.zzn();
                do {
                    zziuVar.zzg(this.zza.zzf());
                } while (this.zza.zzd() < iZzd);
                zzR(iZzd);
                return;
            }
            do {
                zziuVar.zzg(this.zza.zzf());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw zzje.zza();
                }
                zzhc zzhcVar2 = this.zza;
                int iZzd2 = zzhcVar2.zzd() + zzhcVar2.zzn();
                do {
                    list.add(Integer.valueOf(this.zza.zzf()));
                } while (this.zza.zzd() < iZzd2);
                zzR(iZzd2);
                return;
            }
            do {
                list.add(Integer.valueOf(this.zza.zzf()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }

    @Override // com.google.android.recaptcha.internal.zzkq
    public final void zzz(List list) throws zzje {
        int iZzm;
        int iZzm2;
        if (list instanceof zziu) {
            zziu zziuVar = (zziu) list;
            int i4 = this.zzb & 7;
            if (i4 == 2) {
                int iZzn = this.zza.zzn();
                zzT(iZzn);
                int iZzd = this.zza.zzd() + iZzn;
                do {
                    zziuVar.zzg(this.zza.zzg());
                } while (this.zza.zzd() < iZzd);
                return;
            }
            if (i4 != 5) {
                throw zzje.zza();
            }
            do {
                zziuVar.zzg(this.zza.zzg());
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm2 = this.zza.zzm();
                }
            } while (iZzm2 == this.zzb);
        } else {
            int i5 = this.zzb & 7;
            if (i5 == 2) {
                int iZzn2 = this.zza.zzn();
                zzT(iZzn2);
                int iZzd2 = this.zza.zzd() + iZzn2;
                do {
                    list.add(Integer.valueOf(this.zza.zzg()));
                } while (this.zza.zzd() < iZzd2);
                return;
            }
            if (i5 != 5) {
                throw zzje.zza();
            }
            do {
                list.add(Integer.valueOf(this.zza.zzg()));
                if (this.zza.zzC()) {
                    return;
                } else {
                    iZzm = this.zza.zzm();
                }
            } while (iZzm == this.zzb);
            iZzm2 = iZzm;
        }
        this.zzd = iZzm2;
    }
}
