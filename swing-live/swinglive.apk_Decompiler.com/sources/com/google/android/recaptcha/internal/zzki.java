package com.google.android.recaptcha.internal;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzki implements zzkr {
    private final zzke zza;
    private final zzll zzb;
    private final boolean zzc;
    private final zzif zzd;

    private zzki(zzll zzllVar, zzif zzifVar, zzke zzkeVar) {
        this.zzb = zzllVar;
        this.zzc = zzifVar.zzj(zzkeVar);
        this.zzd = zzifVar;
        this.zza = zzkeVar;
    }

    public static zzki zzc(zzll zzllVar, zzif zzifVar, zzke zzkeVar) {
        return new zzki(zzllVar, zzifVar, zzkeVar);
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final int zza(Object obj) {
        zzll zzllVar = this.zzb;
        int iZzb = zzllVar.zzb(zzllVar.zzd(obj));
        return this.zzc ? iZzb + this.zzd.zzb(obj).zzb() : iZzb;
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final int zzb(Object obj) {
        int iHashCode = this.zzb.zzd(obj).hashCode();
        return this.zzc ? (iHashCode * 53) + this.zzd.zzb(obj).zza.hashCode() : iHashCode;
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final Object zze() {
        zzke zzkeVar = this.zza;
        return zzkeVar instanceof zzit ? ((zzit) zzkeVar).zzs() : zzkeVar.zzW().zzk();
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final void zzf(Object obj) {
        this.zzb.zzm(obj);
        this.zzd.zzf(obj);
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final void zzg(Object obj, Object obj2) {
        zzkt.zzr(this.zzb, obj, obj2);
        if (this.zzc) {
            zzkt.zzq(this.zzd, obj, obj2);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final void zzh(Object obj, zzkq zzkqVar, zzie zzieVar) {
        boolean zZzO;
        zzll zzllVar = this.zzb;
        Object objZzc = zzllVar.zzc(obj);
        zzif zzifVar = this.zzd;
        zzij zzijVarZzc = zzifVar.zzc(obj);
        while (zzkqVar.zzc() != Integer.MAX_VALUE) {
            try {
                int iZzd = zzkqVar.zzd();
                if (iZzd != 11) {
                    if ((iZzd & 7) == 2) {
                        Object objZzd = zzifVar.zzd(zzieVar, this.zza, iZzd >>> 3);
                        if (objZzd != null) {
                            zzifVar.zzg(zzkqVar, objZzd, zzieVar, zzijVarZzc);
                        } else {
                            zZzO = zzllVar.zzr(objZzc, zzkqVar);
                        }
                    } else {
                        zZzO = zzkqVar.zzO();
                    }
                    if (!zZzO) {
                        break;
                    }
                } else {
                    Object objZzd2 = null;
                    int iZzj = 0;
                    zzgw zzgwVarZzp = null;
                    while (zzkqVar.zzc() != Integer.MAX_VALUE) {
                        int iZzd2 = zzkqVar.zzd();
                        if (iZzd2 == 16) {
                            iZzj = zzkqVar.zzj();
                            objZzd2 = zzifVar.zzd(zzieVar, this.zza, iZzj);
                        } else if (iZzd2 == 26) {
                            if (objZzd2 != null) {
                                zzifVar.zzg(zzkqVar, objZzd2, zzieVar, zzijVarZzc);
                            } else {
                                zzgwVarZzp = zzkqVar.zzp();
                            }
                        } else if (!zzkqVar.zzO()) {
                            break;
                        }
                    }
                    if (zzkqVar.zzd() != 12) {
                        throw zzje.zzb();
                    }
                    if (zzgwVarZzp != null) {
                        if (objZzd2 != null) {
                            zzifVar.zzh(zzgwVarZzp, objZzd2, zzieVar, zzijVarZzc);
                        } else {
                            zzllVar.zzk(objZzc, iZzj, zzgwVarZzp);
                        }
                    }
                }
            } finally {
                zzllVar.zzn(obj, objZzc);
            }
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:32:0x0089  */
    /* JADX WARN: Removed duplicated region for block: B:59:0x008f A[EDGE_INSN: B:59:0x008f->B:34:0x008f BREAK  A[LOOP:1: B:18:0x0051->B:62:0x0051], SYNTHETIC] */
    @Override // com.google.android.recaptcha.internal.zzkr
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void zzi(java.lang.Object r10, byte[] r11, int r12, int r13, com.google.android.recaptcha.internal.zzgj r14) throws com.google.android.recaptcha.internal.zzje {
        /*
            r9 = this;
            r0 = 3
            r1 = r10
            com.google.android.recaptcha.internal.zzit r1 = (com.google.android.recaptcha.internal.zzit) r1
            com.google.android.recaptcha.internal.zzlm r2 = r1.zzc
            com.google.android.recaptcha.internal.zzlm r3 = com.google.android.recaptcha.internal.zzlm.zzc()
            if (r2 != r3) goto L12
            com.google.android.recaptcha.internal.zzlm r2 = com.google.android.recaptcha.internal.zzlm.zzf()
            r1.zzc = r2
        L12:
            r7 = r2
            com.google.android.recaptcha.internal.zzip r10 = (com.google.android.recaptcha.internal.zzip) r10
            r10.zzi()
            r10 = 0
            r1 = r10
        L1a:
            if (r12 >= r13) goto L9c
            int r5 = com.google.android.recaptcha.internal.zzgk.zzi(r11, r12, r14)
            int r3 = r14.zza
            r12 = 11
            r2 = 2
            if (r3 == r12) goto L4c
            r12 = r3 & 7
            if (r12 != r2) goto L44
            com.google.android.recaptcha.internal.zzif r12 = r9.zzd
            com.google.android.recaptcha.internal.zzie r1 = r14.zzd
            com.google.android.recaptcha.internal.zzke r2 = r9.zza
            int r4 = r3 >>> 3
            java.lang.Object r1 = r12.zzd(r1, r2, r4)
            if (r1 != 0) goto L41
            r4 = r11
            r6 = r13
            r8 = r14
            int r12 = com.google.android.recaptcha.internal.zzgk.zzh(r3, r4, r5, r6, r7, r8)
            goto L1a
        L41:
            int r11 = com.google.android.recaptcha.internal.zzkn.zza
            throw r10
        L44:
            r4 = r11
            r6 = r13
            r8 = r14
            int r12 = com.google.android.recaptcha.internal.zzgk.zzo(r3, r4, r5, r6, r8)
            goto L1a
        L4c:
            r4 = r11
            r6 = r13
            r8 = r14
            r11 = 0
            r12 = r10
        L51:
            if (r5 >= r6) goto L8e
            int r13 = com.google.android.recaptcha.internal.zzgk.zzi(r4, r5, r8)
            int r14 = r8.zza
            int r3 = r14 >>> 3
            r5 = r14 & 7
            if (r3 == r2) goto L72
            if (r3 == r0) goto L62
            goto L85
        L62:
            if (r1 != 0) goto L6f
            if (r5 != r2) goto L85
            int r5 = com.google.android.recaptcha.internal.zzgk.zza(r4, r13, r8)
            java.lang.Object r12 = r8.zzc
            com.google.android.recaptcha.internal.zzgw r12 = (com.google.android.recaptcha.internal.zzgw) r12
            goto L51
        L6f:
            int r11 = com.google.android.recaptcha.internal.zzkn.zza
            throw r10
        L72:
            if (r5 != 0) goto L85
            int r5 = com.google.android.recaptcha.internal.zzgk.zzi(r4, r13, r8)
            int r11 = r8.zza
            com.google.android.recaptcha.internal.zzif r13 = r9.zzd
            com.google.android.recaptcha.internal.zzie r14 = r8.zzd
            com.google.android.recaptcha.internal.zzke r1 = r9.zza
            java.lang.Object r1 = r13.zzd(r14, r1, r11)
            goto L51
        L85:
            r3 = 12
            if (r14 == r3) goto L8f
            int r5 = com.google.android.recaptcha.internal.zzgk.zzo(r14, r4, r13, r6, r8)
            goto L51
        L8e:
            r13 = r5
        L8f:
            if (r12 == 0) goto L96
            int r11 = r11 << r0
            r11 = r11 | r2
            r7.zzj(r11, r12)
        L96:
            r12 = r13
            r11 = r4
            r13 = r6
            r14 = r8
            goto L1a
        L9c:
            r6 = r13
            if (r12 != r6) goto La0
            return
        La0:
            com.google.android.recaptcha.internal.zzje r10 = com.google.android.recaptcha.internal.zzje.zzg()
            throw r10
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzki.zzi(java.lang.Object, byte[], int, int, com.google.android.recaptcha.internal.zzgj):void");
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final void zzj(Object obj, zzmd zzmdVar) {
        Iterator itZzf = this.zzd.zzb(obj).zzf();
        while (itZzf.hasNext()) {
            Map.Entry entry = (Map.Entry) itZzf.next();
            zzii zziiVar = (zzii) entry.getKey();
            if (zziiVar.zze() != zzmc.MESSAGE) {
                throw new IllegalStateException("Found invalid MessageSet item.");
            }
            zziiVar.zzg();
            zziiVar.zzf();
            if (entry instanceof zzjh) {
                zzmdVar.zzw(zziiVar.zza(), ((zzjh) entry).zza().zzb());
            } else {
                zzmdVar.zzw(zziiVar.zza(), entry.getValue());
            }
        }
        zzll zzllVar = this.zzb;
        zzllVar.zzp(zzllVar.zzd(obj), zzmdVar);
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final boolean zzk(Object obj, Object obj2) {
        zzll zzllVar = this.zzb;
        if (!zzllVar.zzd(obj).equals(zzllVar.zzd(obj2))) {
            return false;
        }
        if (this.zzc) {
            return this.zzd.zzb(obj).equals(this.zzd.zzb(obj2));
        }
        return true;
    }

    @Override // com.google.android.recaptcha.internal.zzkr
    public final boolean zzl(Object obj) {
        return this.zzd.zzb(obj).zzk();
    }
}
