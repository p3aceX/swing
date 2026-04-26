package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.f;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzac {
    private final zzj zza;
    private final boolean zzb;
    private final zzai zzc;
    private final int zzd;

    private zzac(zzai zzaiVar) {
        this(zzaiVar, false, zzn.zza, f.API_PRIORITY_OTHER);
    }

    public static zzac zza(char c5) {
        zzl zzlVar = new zzl(c5);
        zzz.zza(zzlVar);
        return new zzac(new zzab(zzlVar));
    }

    private zzac(zzai zzaiVar, boolean z4, zzj zzjVar, int i4) {
        this.zzc = zzaiVar;
        this.zzb = false;
        this.zza = zzjVar;
        this.zzd = f.API_PRIORITY_OTHER;
    }

    public static zzac zza(String str) {
        zzs zzsVarZza = zzy.zza(str);
        if (!zzsVarZza.zza("").zzc()) {
            return new zzac(new zzad(zzsVarZza));
        }
        throw new IllegalArgumentException(zzah.zza("The pattern may not match the empty string: %s", zzsVarZza));
    }

    public final List<String> zza(CharSequence charSequence) {
        zzz.zza(charSequence);
        Iterator<String> itZza = this.zzc.zza(this, charSequence);
        ArrayList arrayList = new ArrayList();
        while (itZza.hasNext()) {
            arrayList.add(itZza.next());
        }
        return Collections.unmodifiableList(arrayList);
    }
}
