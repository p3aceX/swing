package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzaik implements zzanb {
    private final zzaii zza;

    private zzaik(zzaii zzaiiVar) {
        zzaii zzaiiVar2 = (zzaii) zzajc.zza(zzaiiVar, "output");
        this.zza = zzaiiVar2;
        zzaiiVar2.zza = this;
    }

    public static zzaik zza(zzaii zzaiiVar) {
        zzaik zzaikVar = zzaiiVar.zza;
        return zzaikVar != null ? zzaikVar : new zzaik(zzaiiVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzb(int i4, List<Double> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzb(i4, list.get(i5).doubleValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZza = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZza += zzaii.zza(list.get(i6).doubleValue());
        }
        this.zza.zzl(iZza);
        while (i5 < list.size()) {
            this.zza.zzb(list.get(i5).doubleValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzc(int i4, List<Integer> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, list.get(i5).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZza = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZza += zzaii.zza(list.get(i6).intValue());
        }
        this.zza.zzl(iZza);
        while (i5 < list.size()) {
            this.zza.zzj(list.get(i5).intValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzd(int i4, List<Integer> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzg(i4, list.get(i5).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzb = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzb += zzaii.zzb(list.get(i6).intValue());
        }
        this.zza.zzl(iZzb);
        while (i5 < list.size()) {
            this.zza.zzi(list.get(i5).intValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zze(int i4, List<Long> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzf(i4, list.get(i5).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZza = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZza += zzaii.zza(list.get(i6).longValue());
        }
        this.zza.zzl(iZza);
        while (i5 < list.size()) {
            this.zza.zzf(list.get(i5).longValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzf(int i4, List<Float> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzb(i4, list.get(i5).floatValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZza = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZza += zzaii.zza(list.get(i6).floatValue());
        }
        this.zza.zzl(iZza);
        while (i5 < list.size()) {
            this.zza.zzb(list.get(i5).floatValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzg(int i4, List<Integer> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, list.get(i5).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzc = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzc += zzaii.zzc(list.get(i6).intValue());
        }
        this.zza.zzl(iZzc);
        while (i5 < list.size()) {
            this.zza.zzj(list.get(i5).intValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzh(int i4, List<Long> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, list.get(i5).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzb = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzb += zzaii.zzb(list.get(i6).longValue());
        }
        this.zza.zzl(iZzb);
        while (i5 < list.size()) {
            this.zza.zzh(list.get(i5).longValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzi(int i4, List<Integer> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzg(i4, list.get(i5).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZze = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZze += zzaii.zze(list.get(i6).intValue());
        }
        this.zza.zzl(iZze);
        while (i5 < list.size()) {
            this.zza.zzi(list.get(i5).intValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzj(int i4, List<Long> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzf(i4, list.get(i5).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzc = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzc += zzaii.zzc(list.get(i6).longValue());
        }
        this.zza.zzl(iZzc);
        while (i5 < list.size()) {
            this.zza.zzf(list.get(i5).longValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzk(int i4, List<Integer> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzi(i4, list.get(i5).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzf = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzf += zzaii.zzf(list.get(i6).intValue());
        }
        this.zza.zzl(iZzf);
        while (i5 < list.size()) {
            this.zza.zzk(list.get(i5).intValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzl(int i4, List<Long> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzg(i4, list.get(i5).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzd = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzd += zzaii.zzd(list.get(i6).longValue());
        }
        this.zza.zzl(iZzd);
        while (i5 < list.size()) {
            this.zza.zzg(list.get(i5).longValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzm(int i4, List<Integer> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzk(i4, list.get(i5).intValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZzh = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZzh += zzaii.zzh(list.get(i6).intValue());
        }
        this.zza.zzl(iZzh);
        while (i5 < list.size()) {
            this.zza.zzl(list.get(i5).intValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzn(int i4, List<Long> list, boolean z4) {
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                this.zza.zzh(i4, list.get(i5).longValue());
                i5++;
            }
            return;
        }
        this.zza.zzj(i4, 2);
        int iZze = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iZze += zzaii.zze(list.get(i6).longValue());
        }
        this.zza.zzl(iZze);
        while (i5 < list.size()) {
            this.zza.zzh(list.get(i5).longValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final int zza() {
        return zzana.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, boolean z4) {
        this.zza.zzb(i4, z4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, List<Boolean> list, boolean z4) {
        int i5 = 0;
        if (z4) {
            this.zza.zzj(i4, 2);
            int iZza = 0;
            for (int i6 = 0; i6 < list.size(); i6++) {
                iZza += zzaii.zza(list.get(i6).booleanValue());
            }
            this.zza.zzl(iZza);
            while (i5 < list.size()) {
                this.zza.zzb(list.get(i5).booleanValue());
                i5++;
            }
            return;
        }
        while (i5 < list.size()) {
            this.zza.zzb(i4, list.get(i5).booleanValue());
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzb(int i4, int i5) {
        this.zza.zzg(i4, i5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzd(int i4, int i5) {
        this.zza.zzg(i4, i5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zze(int i4, int i5) {
        this.zza.zzi(i4, i5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzf(int i4, int i5) {
        this.zza.zzk(i4, i5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzb(int i4, long j4) {
        this.zza.zzh(i4, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zze(int i4, long j4) {
        this.zza.zzh(i4, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzc(int i4, int i5) {
        this.zza.zzh(i4, i5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzd(int i4, long j4) {
        this.zza.zzg(i4, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzb(int i4, Object obj, zzalc zzalcVar) {
        this.zza.zzc(i4, (zzakk) obj, zzalcVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzc(int i4, long j4) {
        this.zza.zzf(i4, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, zzahm zzahmVar) {
        this.zza.zzc(i4, zzahmVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzb(int i4, List<?> list, zzalc zzalcVar) {
        for (int i5 = 0; i5 < list.size(); i5++) {
            zzb(i4, list.get(i5), zzalcVar);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, List<zzahm> list) {
        for (int i5 = 0; i5 < list.size(); i5++) {
            this.zza.zzc(i4, list.get(i5));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    @Deprecated
    public final void zzb(int i4) {
        this.zza.zzj(i4, 3);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, double d5) {
        this.zza.zzb(i4, d5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zzb(int i4, List<String> list) {
        int i5 = 0;
        if (list instanceof zzajq) {
            zzajq zzajqVar = (zzajq) list;
            while (i5 < list.size()) {
                Object objZzb = zzajqVar.zzb(i5);
                if (objZzb instanceof String) {
                    this.zza.zzb(i4, (String) objZzb);
                } else {
                    this.zza.zzc(i4, (zzahm) objZzb);
                }
                i5++;
            }
            return;
        }
        while (i5 < list.size()) {
            this.zza.zzb(i4, list.get(i5));
            i5++;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    @Deprecated
    public final void zza(int i4) {
        this.zza.zzj(i4, 4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, int i5) {
        this.zza.zzh(i4, i5);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, long j4) {
        this.zza.zzf(i4, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, float f4) {
        this.zza.zzb(i4, f4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, Object obj, zzalc zzalcVar) {
        zzaii zzaiiVar = this.zza;
        zzaiiVar.zzj(i4, 3);
        zzalcVar.zza((zzakk) obj, zzaiiVar.zza);
        zzaiiVar.zzj(i4, 4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, List<?> list, zzalc zzalcVar) {
        for (int i5 = 0; i5 < list.size(); i5++) {
            zza(i4, list.get(i5), zzalcVar);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final <K, V> void zza(int i4, zzakf<K, V> zzakfVar, Map<K, V> map) {
        for (Map.Entry<K, V> entry : map.entrySet()) {
            this.zza.zzj(i4, 2);
            this.zza.zzl(zzakc.zza(zzakfVar, entry.getKey(), entry.getValue()));
            zzakc.zza(this.zza, zzakfVar, entry.getKey(), entry.getValue());
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, Object obj) {
        if (obj instanceof zzahm) {
            this.zza.zzd(i4, (zzahm) obj);
        } else {
            this.zza.zzb(i4, (zzakk) obj);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzanb
    public final void zza(int i4, String str) {
        this.zza.zzb(i4, str);
    }
}
