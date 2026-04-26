package com.google.android.recaptcha.internal;

import Q3.D;
import Q3.F;
import android.content.Context;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class zzbm implements zzbh {
    public static final zzbi zza = new zzbi(null);
    private static Timer zzb;
    private final zzbn zzc;
    private final D zzd;
    private final zzaz zze;

    /* JADX WARN: Multi-variable type inference failed */
    public zzbm(Context context, zzbn zzbnVar, D d5) {
        this.zzc = zzbnVar;
        this.zzd = d5;
        zzaz zzazVar = null;
        Object[] objArr = 0;
        try {
            zzaz zzazVar2 = zzaz.zzc;
            zzazVar2 = zzazVar2 == null ? new zzaz(context, objArr == true ? 1 : 0) : zzazVar2;
            zzaz.zzc = zzazVar2;
            zzazVar = zzazVar2;
        } catch (Exception unused) {
        }
        this.zze = zzazVar;
        zzh();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzg() {
        zzaz zzazVar;
        zzpd zzpdVarZzk;
        int iZzJ;
        int i4;
        zzaz zzazVar2 = this.zze;
        if (zzazVar2 != null) {
            for (List<zzba> list : AbstractC0728h.n0(zzazVar2.zzd(), 20, 20)) {
                zznh zznhVarZzi = zzni.zzi();
                ArrayList arrayList = new ArrayList();
                for (zzba zzbaVar : list) {
                    try {
                        zzpdVarZzk = zzpd.zzk(zzfy.zzg().zzj(zzbaVar.zzc()));
                        iZzJ = zzpdVarZzk.zzJ();
                        i4 = iZzJ - 1;
                    } catch (Exception unused) {
                        zzaz zzazVar3 = this.zze;
                        if (zzazVar3 != null) {
                            zzazVar3.zzf(zzbaVar);
                        }
                    }
                    if (iZzJ == 0) {
                        throw null;
                    }
                    if (i4 == 0) {
                        zznhVarZzi.zzp(zzpdVarZzk.zzf());
                    } else if (i4 == 1) {
                        zznhVarZzi.zzq(zzpdVarZzk.zzg());
                    }
                    arrayList.add(zzbaVar);
                }
                if (zznhVarZzi.zze() + zznhVarZzi.zzd() != 0) {
                    if (this.zzc.zza(((zzni) zznhVarZzi.zzj()).zzd()) && (zzazVar = this.zze) != null) {
                        zzazVar.zza(arrayList);
                    }
                }
            }
        }
    }

    private final void zzh() {
        if (zzb == null) {
            Timer timer = new Timer();
            zzb = timer;
            timer.schedule(new zzbj(this), 120000L, 120000L);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzbh
    public final void zza(zzpd zzpdVar) {
        F.s(this.zzd, null, new zzbl(this, zzpdVar, null), 3);
        zzh();
    }
}
