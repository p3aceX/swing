package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Comparator;

/* JADX INFO: loaded from: classes.dex */
final class zzaho implements Comparator<zzahm> {
    @Override // java.util.Comparator
    public final /* synthetic */ int compare(zzahm zzahmVar, zzahm zzahmVar2) {
        zzahm zzahmVar3 = zzahmVar;
        zzahm zzahmVar4 = zzahmVar2;
        zzahs zzahsVar = (zzahs) zzahmVar3.iterator();
        zzahs zzahsVar2 = (zzahs) zzahmVar4.iterator();
        while (zzahsVar.hasNext() && zzahsVar2.hasNext()) {
            int iCompareTo = Integer.valueOf(zzahm.zza(zzahsVar.zza())).compareTo(Integer.valueOf(zzahm.zza(zzahsVar2.zza())));
            if (iCompareTo != 0) {
                return iCompareTo;
            }
        }
        return Integer.valueOf(zzahmVar3.zzb()).compareTo(Integer.valueOf(zzahmVar4.zzb()));
    }
}
