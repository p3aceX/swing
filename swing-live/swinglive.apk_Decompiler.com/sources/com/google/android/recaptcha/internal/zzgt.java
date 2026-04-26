package com.google.android.recaptcha.internal;

import B1.a;
import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
class zzgt extends zzgs {
    protected final byte[] zza;

    public zzgt(byte[] bArr) {
        bArr.getClass();
        this.zza = bArr;
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof zzgw) || zzd() != ((zzgw) obj).zzd()) {
            return false;
        }
        if (zzd() == 0) {
            return true;
        }
        if (!(obj instanceof zzgt)) {
            return obj.equals(this);
        }
        zzgt zzgtVar = (zzgt) obj;
        int iZzl = zzl();
        int iZzl2 = zzgtVar.zzl();
        if (iZzl != 0 && iZzl2 != 0 && iZzl != iZzl2) {
            return false;
        }
        int iZzd = zzd();
        if (iZzd > zzgtVar.zzd()) {
            throw new IllegalArgumentException("Length too large: " + iZzd + zzd());
        }
        if (iZzd > zzgtVar.zzd()) {
            throw new IllegalArgumentException(a.k("Ran off end of other: 0, ", iZzd, zzgtVar.zzd(), ", "));
        }
        byte[] bArr = this.zza;
        byte[] bArr2 = zzgtVar.zza;
        zzgtVar.zzc();
        int i4 = 0;
        int i5 = 0;
        while (i4 < iZzd) {
            if (bArr[i4] != bArr2[i5]) {
                return false;
            }
            i4++;
            i5++;
        }
        return true;
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public byte zza(int i4) {
        return this.zza[i4];
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public byte zzb(int i4) {
        return this.zza[i4];
    }

    public int zzc() {
        return 0;
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public int zzd() {
        return this.zza.length;
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public void zze(byte[] bArr, int i4, int i5, int i6) {
        System.arraycopy(this.zza, 0, bArr, 0, i6);
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public final int zzf(int i4, int i5, int i6) {
        return zzjc.zzb(i4, this.zza, 0, i6);
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public final zzgw zzg(int i4, int i5) {
        int iZzk = zzgw.zzk(0, i5, zzd());
        return iZzk == 0 ? zzgw.zzb : new zzgq(this.zza, 0, iZzk);
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public final String zzh(Charset charset) {
        return new String(this.zza, 0, zzd(), charset);
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public final void zzi(zzgm zzgmVar) {
        ((zzhe) zzgmVar).zzc(this.zza, 0, zzd());
    }

    @Override // com.google.android.recaptcha.internal.zzgw
    public final boolean zzj() {
        return zzma.zzf(this.zza, 0, zzd());
    }
}
