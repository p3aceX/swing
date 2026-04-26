package com.google.android.gms.internal.common;

/* JADX INFO: loaded from: classes.dex */
final class zzt extends zzw {
    final /* synthetic */ zzu zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzt(zzu zzuVar, zzx zzxVar, CharSequence charSequence) {
        super(zzxVar, charSequence);
        this.zza = zzuVar;
    }

    @Override // com.google.android.gms.internal.common.zzw
    public final int zzc(int i4) {
        return i4 + 1;
    }

    @Override // com.google.android.gms.internal.common.zzw
    public final int zzd(int i4) {
        zzo zzoVar = this.zza.zza;
        CharSequence charSequence = ((zzw) this).zzb;
        int length = charSequence.length();
        zzs.zzb(i4, length, "index");
        while (i4 < length) {
            if (zzoVar.zza(charSequence.charAt(i4))) {
                return i4;
            }
            i4++;
        }
        return -1;
    }
}
