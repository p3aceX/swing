package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
final class zzhe extends zzhh {
    private final byte[] zzc;
    private final int zzd;
    private int zze;

    public zzhe(byte[] bArr, int i4, int i5) {
        super(null);
        int length = bArr.length;
        if (((length - i5) | i5) < 0) {
            throw new IllegalArgumentException(String.format("Array range is invalid. Buffer.length=%d, offset=%d, length=%d", Integer.valueOf(length), 0, Integer.valueOf(i5)));
        }
        this.zzc = bArr;
        this.zze = 0;
        this.zzd = i5;
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final int zza() {
        return this.zzd - this.zze;
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzb(byte b5) throws zzhf {
        try {
            byte[] bArr = this.zzc;
            int i4 = this.zze;
            this.zze = i4 + 1;
            bArr[i4] = b5;
        } catch (IndexOutOfBoundsException e) {
            throw new zzhf(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
        }
    }

    public final void zzc(byte[] bArr, int i4, int i5) {
        try {
            System.arraycopy(bArr, 0, this.zzc, this.zze, i5);
            this.zze += i5;
        } catch (IndexOutOfBoundsException e) {
            throw new zzhf(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), Integer.valueOf(i5)), e);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzd(int i4, boolean z4) throws zzhf {
        zzq(i4 << 3);
        zzb(z4 ? (byte) 1 : (byte) 0);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zze(int i4, zzgw zzgwVar) {
        zzq((i4 << 3) | 2);
        zzq(zzgwVar.zzd());
        zzgwVar.zzi(this);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzf(int i4, int i5) throws zzhf {
        zzq((i4 << 3) | 5);
        zzg(i5);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzg(int i4) throws zzhf {
        try {
            byte[] bArr = this.zzc;
            int i5 = this.zze;
            int i6 = i5 + 1;
            this.zze = i6;
            bArr[i5] = (byte) (i4 & 255);
            int i7 = i5 + 2;
            this.zze = i7;
            bArr[i6] = (byte) ((i4 >> 8) & 255);
            int i8 = i5 + 3;
            this.zze = i8;
            bArr[i7] = (byte) ((i4 >> 16) & 255);
            this.zze = i5 + 4;
            bArr[i8] = (byte) ((i4 >> 24) & 255);
        } catch (IndexOutOfBoundsException e) {
            throw new zzhf(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzh(int i4, long j4) throws zzhf {
        zzq((i4 << 3) | 1);
        zzi(j4);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzi(long j4) throws zzhf {
        try {
            byte[] bArr = this.zzc;
            int i4 = this.zze;
            int i5 = i4 + 1;
            this.zze = i5;
            bArr[i4] = (byte) (((int) j4) & 255);
            int i6 = i4 + 2;
            this.zze = i6;
            bArr[i5] = (byte) (((int) (j4 >> 8)) & 255);
            int i7 = i4 + 3;
            this.zze = i7;
            bArr[i6] = (byte) (((int) (j4 >> 16)) & 255);
            int i8 = i4 + 4;
            this.zze = i8;
            bArr[i7] = (byte) (((int) (j4 >> 24)) & 255);
            int i9 = i4 + 5;
            this.zze = i9;
            bArr[i8] = (byte) (((int) (j4 >> 32)) & 255);
            int i10 = i4 + 6;
            this.zze = i10;
            bArr[i9] = (byte) (((int) (j4 >> 40)) & 255);
            int i11 = i4 + 7;
            this.zze = i11;
            bArr[i10] = (byte) (((int) (j4 >> 48)) & 255);
            this.zze = i4 + 8;
            bArr[i11] = (byte) (((int) (j4 >> 56)) & 255);
        } catch (IndexOutOfBoundsException e) {
            throw new zzhf(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzj(int i4, int i5) throws zzhf {
        zzq(i4 << 3);
        zzk(i5);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzk(int i4) throws zzhf {
        if (i4 >= 0) {
            zzq(i4);
        } else {
            zzs(i4);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzl(byte[] bArr, int i4, int i5) {
        zzc(bArr, 0, i5);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzm(int i4, String str) throws zzhf {
        zzq((i4 << 3) | 2);
        zzn(str);
    }

    public final void zzn(String str) throws zzhf {
        int i4 = this.zze;
        try {
            int iZzy = zzhh.zzy(str.length() * 3);
            int iZzy2 = zzhh.zzy(str.length());
            if (iZzy2 != iZzy) {
                zzq(zzma.zzc(str));
                byte[] bArr = this.zzc;
                int i5 = this.zze;
                this.zze = zzma.zzb(str, bArr, i5, this.zzd - i5);
                return;
            }
            int i6 = i4 + iZzy2;
            this.zze = i6;
            int iZzb = zzma.zzb(str, this.zzc, i6, this.zzd - i6);
            this.zze = i4;
            zzq((iZzb - i4) - iZzy2);
            this.zze = iZzb;
        } catch (zzlz e) {
            this.zze = i4;
            zzC(str, e);
        } catch (IndexOutOfBoundsException e4) {
            throw new zzhf(e4);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzo(int i4, int i5) {
        zzq((i4 << 3) | i5);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzp(int i4, int i5) {
        zzq(i4 << 3);
        zzq(i5);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzq(int i4) {
        while ((i4 & (-128)) != 0) {
            try {
                byte[] bArr = this.zzc;
                int i5 = this.zze;
                this.zze = i5 + 1;
                bArr[i5] = (byte) ((i4 & 127) | 128);
                i4 >>>= 7;
            } catch (IndexOutOfBoundsException e) {
                throw new zzhf(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
            }
        }
        byte[] bArr2 = this.zzc;
        int i6 = this.zze;
        this.zze = i6 + 1;
        bArr2[i6] = (byte) i4;
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzr(int i4, long j4) throws zzhf {
        zzq(i4 << 3);
        zzs(j4);
    }

    @Override // com.google.android.recaptcha.internal.zzhh
    public final void zzs(long j4) throws zzhf {
        if (!zzhh.zzd || this.zzd - this.zze < 10) {
            while ((j4 & (-128)) != 0) {
                try {
                    byte[] bArr = this.zzc;
                    int i4 = this.zze;
                    this.zze = i4 + 1;
                    bArr[i4] = (byte) ((((int) j4) & 127) | 128);
                    j4 >>>= 7;
                } catch (IndexOutOfBoundsException e) {
                    throw new zzhf(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
                }
            }
            byte[] bArr2 = this.zzc;
            int i5 = this.zze;
            this.zze = i5 + 1;
            bArr2[i5] = (byte) j4;
            return;
        }
        while (true) {
            int i6 = (int) j4;
            if ((j4 & (-128)) == 0) {
                byte[] bArr3 = this.zzc;
                int i7 = this.zze;
                this.zze = i7 + 1;
                zzlv.zzn(bArr3, i7, (byte) i6);
                return;
            }
            byte[] bArr4 = this.zzc;
            int i8 = this.zze;
            this.zze = i8 + 1;
            zzlv.zzn(bArr4, i8, (byte) ((i6 & 127) | 128));
            j4 >>>= 7;
        }
    }
}
