package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
abstract class zzaf extends zzi<String> {
    final CharSequence zza;
    private final zzj zzb;
    private int zze;
    private int zzd = 0;
    private final boolean zzc = false;

    public zzaf(zzac zzacVar, CharSequence charSequence) {
        this.zzb = zzacVar.zza;
        this.zze = zzacVar.zzd;
        this.zza = charSequence;
    }

    public abstract int zza(int i4);

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzi
    public final /* synthetic */ String zza() {
        int i4 = this.zzd;
        while (true) {
            int i5 = this.zzd;
            if (i5 == -1) {
                zzb();
                return null;
            }
            int iZzb = zzb(i5);
            if (iZzb == -1) {
                iZzb = this.zza.length();
                this.zzd = -1;
            } else {
                this.zzd = zza(iZzb);
            }
            int i6 = this.zzd;
            if (i6 != i4) {
                while (i4 < iZzb && this.zzb.zza(this.zza.charAt(i4))) {
                    i4++;
                }
                while (iZzb > i4 && this.zzb.zza(this.zza.charAt(iZzb - 1))) {
                    iZzb--;
                }
                int i7 = this.zze;
                if (i7 == 1) {
                    iZzb = this.zza.length();
                    this.zzd = -1;
                    while (iZzb > i4 && this.zzb.zza(this.zza.charAt(iZzb - 1))) {
                        iZzb--;
                    }
                } else {
                    this.zze = i7 - 1;
                }
                return this.zza.subSequence(i4, iZzb).toString();
            }
            int i8 = i6 + 1;
            this.zzd = i8;
            if (i8 > this.zza.length()) {
                this.zzd = -1;
            }
        }
    }

    public abstract int zzb(int i4);
}
