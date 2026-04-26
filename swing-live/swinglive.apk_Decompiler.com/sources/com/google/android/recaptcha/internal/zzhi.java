package com.google.android.recaptcha.internal;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzhi implements zzmd {
    private final zzhh zza;

    private zzhi(zzhh zzhhVar) {
        byte[] bArr = zzjc.zzd;
        this.zza = zzhhVar;
        zzhhVar.zza = this;
    }

    public static zzhi zza(zzhh zzhhVar) {
        zzhi zzhiVar = zzhhVar.zza;
        return zzhiVar != null ? zzhiVar : new zzhi(zzhhVar);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzA(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Long) list.get(i7)).getClass();
            i6 += 8;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzi(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzB(int i4, int i5) {
        this.zza.zzp(i4, (i5 >> 31) ^ (i5 + i5));
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzC(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                zzhh zzhhVar = this.zza;
                int iIntValue = ((Integer) list.get(i5)).intValue();
                zzhhVar.zzp(i4, (iIntValue >> 31) ^ (iIntValue + iIntValue));
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzy = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            int iIntValue2 = ((Integer) list.get(i6)).intValue();
            iZzy += zzhh.zzy((iIntValue2 >> 31) ^ (iIntValue2 + iIntValue2));
        }
        this.zza.zzq(iZzy);
        while (i5 < list.size()) {
            zzhh zzhhVar2 = this.zza;
            int iIntValue3 = ((Integer) list.get(i5)).intValue();
            zzhhVar2.zzq((iIntValue3 >> 31) ^ (iIntValue3 + iIntValue3));
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzD(int i4, long j4) {
        this.zza.zzr(i4, (j4 >> 63) ^ (j4 + j4));
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzE(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                zzhh zzhhVar = this.zza;
                long jLongValue = ((Long) list.get(i5)).longValue();
                zzhhVar.zzr(i4, (jLongValue >> 63) ^ (jLongValue + jLongValue));
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzz = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            long jLongValue2 = ((Long) list.get(i6)).longValue();
            iZzz += zzhh.zzz((jLongValue2 >> 63) ^ (jLongValue2 + jLongValue2));
        }
        this.zza.zzq(iZzz);
        while (i5 < list.size()) {
            zzhh zzhhVar2 = this.zza;
            long jLongValue3 = ((Long) list.get(i5)).longValue();
            zzhhVar2.zzs((jLongValue3 >> 63) ^ (jLongValue3 + jLongValue3));
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    @Deprecated
    public final void zzF(int i4) {
        this.zza.zzo(i4, 3);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzG(int i4, String str) {
        this.zza.zzm(i4, str);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzH(int i4, List list) {
        int i5 = 0;
        if (!(list instanceof zzjm)) {
            while (i5 < list.size()) {
                this.zza.zzm(i4, (String) list.get(i5));
                i5++;
            }
            return;
        }
        zzjm zzjmVar = (zzjm) list;
        while (i5 < list.size()) {
            Object objZzf = zzjmVar.zzf(i5);
            if (objZzf instanceof String) {
                this.zza.zzm(i4, (String) objZzf);
            } else {
                this.zza.zze(i4, (zzgw) objZzf);
            }
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzI(int i4, int i5) {
        this.zza.zzp(i4, i5);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzJ(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzp(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzy = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzy += zzhh.zzy(((Integer) list.get(i6)).intValue());
        }
        this.zza.zzq(iZzy);
        while (i5 < list.size()) {
            this.zza.zzq(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzK(int i4, long j4) {
        this.zza.zzr(i4, j4);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzL(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzr(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzz = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzz += zzhh.zzz(((Long) list.get(i6)).longValue());
        }
        this.zza.zzq(iZzz);
        while (i5 < list.size()) {
            this.zza.zzs(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzb(int i4, boolean z4) {
        this.zza.zzd(i4, z4);
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzc(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzd(i4, ((Boolean) list.get(i5)).booleanValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Boolean) list.get(i7)).getClass();
            i6++;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzb(((Boolean) list.get(i5)).booleanValue() ? (byte) 1 : (byte) 0);
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzd(int i4, zzgw zzgwVar) {
        this.zza.zze(i4, zzgwVar);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zze(int i4, List list) {
        for (int i5 = 0; i5 < list.size(); i5++) {
            this.zza.zze(i4, (zzgw) list.get(i5));
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzf(int i4, double d5) {
        this.zza.zzh(i4, Double.doubleToRawLongBits(d5));
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzg(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, Double.doubleToRawLongBits(((Double) list.get(i5)).doubleValue()));
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Double) list.get(i7)).getClass();
            i6 += 8;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzi(Double.doubleToRawLongBits(((Double) list.get(i5)).doubleValue()));
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    @Deprecated
    public final void zzh(int i4) {
        this.zza.zzo(i4, 4);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzi(int i4, int i5) {
        this.zza.zzj(i4, i5);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzj(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzj(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzu = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzu += zzhh.zzu(((Integer) list.get(i6)).intValue());
        }
        this.zza.zzq(iZzu);
        while (i5 < list.size()) {
            this.zza.zzk(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzk(int i4, int i5) {
        this.zza.zzf(i4, i5);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzl(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzf(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Integer) list.get(i7)).getClass();
            i6 += 4;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzg(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzm(int i4, long j4) {
        this.zza.zzh(i4, j4);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzn(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Long) list.get(i7)).getClass();
            i6 += 8;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzi(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzo(int i4, float f4) {
        this.zza.zzf(i4, Float.floatToRawIntBits(f4));
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzp(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzf(i4, Float.floatToRawIntBits(((Float) list.get(i5)).floatValue()));
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Float) list.get(i7)).getClass();
            i6 += 4;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzg(Float.floatToRawIntBits(((Float) list.get(i5)).floatValue()));
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzq(int i4, Object obj, zzkr zzkrVar) {
        zzhh zzhhVar = this.zza;
        zzhhVar.zzo(i4, 3);
        zzkrVar.zzj((zzke) obj, zzhhVar.zza);
        zzhhVar.zzo(i4, 4);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzr(int i4, int i5) {
        this.zza.zzj(i4, i5);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzs(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzj(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzu = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzu += zzhh.zzu(((Integer) list.get(i6)).intValue());
        }
        this.zza.zzq(iZzu);
        while (i5 < list.size()) {
            this.zza.zzk(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzt(int i4, long j4) {
        this.zza.zzr(i4, j4);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzu(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzr(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int iZzz = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzz += zzhh.zzz(((Long) list.get(i6)).longValue());
        }
        this.zza.zzq(iZzz);
        while (i5 < list.size()) {
            this.zza.zzs(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzv(int i4, Object obj, zzkr zzkrVar) {
        zzke zzkeVar = (zzke) obj;
        zzhe zzheVar = (zzhe) this.zza;
        zzheVar.zzq((i4 << 3) | 2);
        zzheVar.zzq(((zzgf) zzkeVar).zza(zzkrVar));
        zzkrVar.zzj(zzkeVar, zzheVar.zza);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzw(int i4, Object obj) {
        if (obj instanceof zzgw) {
            zzhe zzheVar = (zzhe) this.zza;
            zzheVar.zzq(11);
            zzheVar.zzp(2, i4);
            zzheVar.zze(3, (zzgw) obj);
            zzheVar.zzq(12);
            return;
        }
        zzhh zzhhVar = this.zza;
        zzke zzkeVar = (zzke) obj;
        zzhe zzheVar2 = (zzhe) zzhhVar;
        zzheVar2.zzq(11);
        zzheVar2.zzp(2, i4);
        zzheVar2.zzq(26);
        zzheVar2.zzq(zzkeVar.zzn());
        zzkeVar.zze(zzhhVar);
        zzheVar2.zzq(12);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzx(int i4, int i5) {
        this.zza.zzf(i4, i5);
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzy(int i4, List list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzf(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzo(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Integer) list.get(i7)).getClass();
            i6 += 4;
        }
        this.zza.zzq(i6);
        while (i5 < list.size()) {
            this.zza.zzg(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzmd
    public final void zzz(int i4, long j4) {
        this.zza.zzh(i4, j4);
    }
}
