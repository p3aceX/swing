package com.google.android.recaptcha.internal;

import java.util.List;
import java.util.concurrent.TimeUnit;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class zzeg implements zzee {
    private final zzef zza;
    private final zzed zzb;

    public zzeg(zzef zzefVar, zzed zzedVar) {
        this.zza = zzefVar;
        this.zzb = zzedVar;
    }

    private final zzpf zzb(String str, List list) throws zzae {
        if (str.length() == 0) {
            throw new zzae(3, 17, null);
        }
        try {
            zzec zzecVar = new zzec(this.zza.zza(AbstractC0728h.j0(list)), 255L, zzec.zzb);
            StringBuilder sb = new StringBuilder(str.length());
            for (int i4 = 0; i4 < str.length(); i4++) {
                sb.append((char) (str.charAt(i4) ^ ((int) zzecVar.zza())));
            }
            return zzpf.zzg(zzfy.zzh().zzj(sb.toString()));
        } catch (Exception e) {
            throw new zzae(3, 18, e);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzee
    public final zzpf zza(zzpn zzpnVar) throws zzae {
        zzfh zzfhVarZzb = zzfh.zzb();
        zzpf zzpfVarZzb = zzb(zzpnVar.zzi(), zzpnVar.zzj());
        zzfhVarZzb.zzf();
        long jZza = zzfhVarZzb.zza(TimeUnit.MICROSECONDS);
        zzv zzvVar = zzv.zza;
        zzv.zza(zzx.zzm.zza(), jZza);
        return zzpfVarZzb;
    }
}
