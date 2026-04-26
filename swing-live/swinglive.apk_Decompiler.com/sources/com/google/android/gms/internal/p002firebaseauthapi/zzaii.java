package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.io.IOException;
import java.io.OutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzaii extends zzahn {
    private static final Logger zzb = Logger.getLogger(zzaii.class.getName());
    private static final boolean zzc = zzamh.zzc();
    zzaik zza;

    public static class zza extends zzaii {
        private final byte[] zzb;
        private final int zzc;
        private final int zzd;
        private int zze;

        public zza(byte[] bArr, int i4, int i5) {
            super();
            if (bArr == null) {
                throw new NullPointerException("buffer");
            }
            if (((bArr.length - i5) | i5) < 0) {
                throw new IllegalArgumentException(String.format("Array range is invalid. Buffer.length=%d, offset=%d, length=%d", Integer.valueOf(bArr.length), 0, Integer.valueOf(i5)));
            }
            this.zzb = bArr;
            this.zzc = 0;
            this.zze = 0;
            this.zzd = i5;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final int zza() {
            return this.zzd - this.zze;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(int i4, boolean z4) throws zzd {
            zzj(i4, 0);
            zza(z4 ? (byte) 1 : (byte) 0);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc() {
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzd(int i4, zzahm zzahmVar) throws zzd {
            zzj(1, 3);
            zzk(2, i4);
            zzc(3, zzahmVar);
            zzj(1, 4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzf(int i4, long j4) throws zzd {
            zzj(i4, 1);
            zzf(j4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzg(int i4, int i5) throws zzd {
            zzj(i4, 5);
            zzi(i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzh(int i4, int i5) throws zzd {
            zzj(i4, 0);
            zzj(i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzi(int i4) throws zzd {
            try {
                byte[] bArr = this.zzb;
                int i5 = this.zze;
                int i6 = i5 + 1;
                this.zze = i6;
                bArr[i5] = (byte) i4;
                int i7 = i5 + 2;
                this.zze = i7;
                bArr[i6] = (byte) (i4 >> 8);
                int i8 = i5 + 3;
                this.zze = i8;
                bArr[i7] = (byte) (i4 >> 16);
                this.zze = i5 + 4;
                bArr[i8] = (byte) (i4 >>> 24);
            } catch (IndexOutOfBoundsException e) {
                throw new zzd(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzj(int i4) throws zzd {
            if (i4 >= 0) {
                zzl(i4);
            } else {
                zzh(i4);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzk(int i4, int i5) throws zzd {
            zzj(i4, 0);
            zzl(i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzl(int i4) throws zzd {
            while ((i4 & (-128)) != 0) {
                try {
                    byte[] bArr = this.zzb;
                    int i5 = this.zze;
                    this.zze = i5 + 1;
                    bArr[i5] = (byte) (i4 | 128);
                    i4 >>>= 7;
                } catch (IndexOutOfBoundsException e) {
                    throw new zzd(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
                }
            }
            byte[] bArr2 = this.zzb;
            int i6 = this.zze;
            this.zze = i6 + 1;
            bArr2[i6] = (byte) i4;
        }

        private final void zzc(byte[] bArr, int i4, int i5) throws zzd {
            try {
                System.arraycopy(bArr, i4, this.zzb, this.zze, i5);
                this.zze += i5;
            } catch (IndexOutOfBoundsException e) {
                throw new zzd(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), Integer.valueOf(i5)), e);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zza(byte b5) throws zzd {
            try {
                byte[] bArr = this.zzb;
                int i4 = this.zze;
                this.zze = i4 + 1;
                bArr[i4] = b5;
            } catch (IndexOutOfBoundsException e) {
                throw new zzd(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(byte[] bArr, int i4, int i5) throws zzd {
            zzl(i5);
            zzc(bArr, 0, i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzf(long j4) throws zzd {
            try {
                byte[] bArr = this.zzb;
                int i4 = this.zze;
                int i5 = i4 + 1;
                this.zze = i5;
                bArr[i4] = (byte) j4;
                int i6 = i4 + 2;
                this.zze = i6;
                bArr[i5] = (byte) (j4 >> 8);
                int i7 = i4 + 3;
                this.zze = i7;
                bArr[i6] = (byte) (j4 >> 16);
                int i8 = i4 + 4;
                this.zze = i8;
                bArr[i7] = (byte) (j4 >> 24);
                int i9 = i4 + 5;
                this.zze = i9;
                bArr[i8] = (byte) (j4 >> 32);
                int i10 = i4 + 6;
                this.zze = i10;
                bArr[i9] = (byte) (j4 >> 40);
                int i11 = i4 + 7;
                this.zze = i11;
                bArr[i10] = (byte) (j4 >> 48);
                this.zze = i4 + 8;
                bArr[i11] = (byte) (j4 >> 56);
            } catch (IndexOutOfBoundsException e) {
                throw new zzd(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzh(int i4, long j4) throws zzd {
            zzj(i4, 0);
            zzh(j4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzj(int i4, int i5) throws zzd {
            zzl((i4 << 3) | i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahn
        public final void zza(byte[] bArr, int i4, int i5) throws zzd {
            zzc(bArr, i4, i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(zzahm zzahmVar) throws zzd {
            zzl(zzahmVar.zzb());
            zzahmVar.zza(this);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzh(long j4) throws zzd {
            if (zzaii.zzc && zza() >= 10) {
                while ((j4 & (-128)) != 0) {
                    byte[] bArr = this.zzb;
                    int i4 = this.zze;
                    this.zze = i4 + 1;
                    zzamh.zza(bArr, i4, (byte) (((int) j4) | 128));
                    j4 >>>= 7;
                }
                byte[] bArr2 = this.zzb;
                int i5 = this.zze;
                this.zze = i5 + 1;
                zzamh.zza(bArr2, i5, (byte) j4);
                return;
            }
            while ((j4 & (-128)) != 0) {
                try {
                    byte[] bArr3 = this.zzb;
                    int i6 = this.zze;
                    this.zze = i6 + 1;
                    bArr3[i6] = (byte) (((int) j4) | 128);
                    j4 >>>= 7;
                } catch (IndexOutOfBoundsException e) {
                    throw new zzd(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.zze), Integer.valueOf(this.zzd), 1), e);
                }
            }
            byte[] bArr4 = this.zzb;
            int i7 = this.zze;
            this.zze = i7 + 1;
            bArr4[i7] = (byte) j4;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc(int i4, zzahm zzahmVar) throws zzd {
            zzj(i4, 2);
            zzb(zzahmVar);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(zzakk zzakkVar, zzalc zzalcVar) throws zzd {
            zzl(((zzahd) zzakkVar).zza(zzalcVar));
            zzalcVar.zza(zzakkVar, this.zza);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc(int i4, zzakk zzakkVar, zzalc zzalcVar) throws zzd {
            zzj(i4, 2);
            zzl(((zzahd) zzakkVar).zza(zzalcVar));
            zzalcVar.zza(zzakkVar, this.zza);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(int i4, zzakk zzakkVar) throws zzd {
            zzj(1, 3);
            zzk(2, i4);
            zzj(3, 2);
            zzc(zzakkVar);
            zzj(1, 4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc(zzakk zzakkVar) throws zzd {
            zzl(zzakkVar.zzk());
            zzakkVar.zza(this);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(int i4, String str) throws zzd {
            zzj(i4, 2);
            zzb(str);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(String str) throws zzd {
            int i4 = this.zze;
            try {
                int iZzh = zzaii.zzh(str.length() * 3);
                int iZzh2 = zzaii.zzh(str.length());
                if (iZzh2 == iZzh) {
                    int i5 = i4 + iZzh2;
                    this.zze = i5;
                    int iZza = zzaml.zza(str, this.zzb, i5, zza());
                    this.zze = i4;
                    zzl((iZza - i4) - iZzh2);
                    this.zze = iZza;
                    return;
                }
                zzl(zzaml.zza(str));
                this.zze = zzaml.zza(str, this.zzb, this.zze, zza());
            } catch (zzamp e) {
                this.zze = i4;
                zza(str, e);
            } catch (IndexOutOfBoundsException e4) {
                throw new zzd(e4);
            }
        }
    }

    public static abstract class zzb extends zzaii {
        final byte[] zzb;
        final int zzc;
        int zzd;
        int zze;

        public zzb(int i4) {
            super();
            if (i4 < 0) {
                throw new IllegalArgumentException("bufferSize must be >= 0");
            }
            byte[] bArr = new byte[Math.max(i4, 20)];
            this.zzb = bArr;
            this.zzc = bArr.length;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final int zza() {
            throw new UnsupportedOperationException("spaceLeft() can only be called on CodedOutputStreams that are writing to a flat array or ByteBuffer.");
        }

        public final void zzb(byte b5) {
            byte[] bArr = this.zzb;
            int i4 = this.zzd;
            this.zzd = i4 + 1;
            bArr[i4] = b5;
            this.zze++;
        }

        public final void zzi(long j4) {
            byte[] bArr = this.zzb;
            int i4 = this.zzd;
            int i5 = i4 + 1;
            this.zzd = i5;
            bArr[i4] = (byte) (j4 & 255);
            int i6 = i4 + 2;
            this.zzd = i6;
            bArr[i5] = (byte) ((j4 >> 8) & 255);
            int i7 = i4 + 3;
            this.zzd = i7;
            bArr[i6] = (byte) ((j4 >> 16) & 255);
            int i8 = i4 + 4;
            this.zzd = i8;
            bArr[i7] = (byte) (255 & (j4 >> 24));
            int i9 = i4 + 5;
            this.zzd = i9;
            bArr[i8] = (byte) (j4 >> 32);
            int i10 = i4 + 6;
            this.zzd = i10;
            bArr[i9] = (byte) (j4 >> 40);
            int i11 = i4 + 7;
            this.zzd = i11;
            bArr[i10] = (byte) (j4 >> 48);
            this.zzd = i4 + 8;
            bArr[i11] = (byte) (j4 >> 56);
            this.zze += 8;
        }

        public final void zzj(long j4) {
            if (!zzaii.zzc) {
                while ((j4 & (-128)) != 0) {
                    byte[] bArr = this.zzb;
                    int i4 = this.zzd;
                    this.zzd = i4 + 1;
                    bArr[i4] = (byte) (((int) j4) | 128);
                    this.zze++;
                    j4 >>>= 7;
                }
                byte[] bArr2 = this.zzb;
                int i5 = this.zzd;
                this.zzd = i5 + 1;
                bArr2[i5] = (byte) j4;
                this.zze++;
                return;
            }
            long j5 = this.zzd;
            while ((j4 & (-128)) != 0) {
                byte[] bArr3 = this.zzb;
                int i6 = this.zzd;
                this.zzd = i6 + 1;
                zzamh.zza(bArr3, i6, (byte) (((int) j4) | 128));
                j4 >>>= 7;
            }
            byte[] bArr4 = this.zzb;
            int i7 = this.zzd;
            this.zzd = i7 + 1;
            zzamh.zza(bArr4, i7, (byte) j4);
            this.zze += (int) (((long) this.zzd) - j5);
        }

        public final void zzl(int i4, int i5) {
            zzn((i4 << 3) | i5);
        }

        public final void zzm(int i4) {
            byte[] bArr = this.zzb;
            int i5 = this.zzd;
            int i6 = i5 + 1;
            this.zzd = i6;
            bArr[i5] = (byte) i4;
            int i7 = i5 + 2;
            this.zzd = i7;
            bArr[i6] = (byte) (i4 >> 8);
            int i8 = i5 + 3;
            this.zzd = i8;
            bArr[i7] = (byte) (i4 >> 16);
            this.zzd = i5 + 4;
            bArr[i8] = (byte) (i4 >>> 24);
            this.zze += 4;
        }

        public final void zzn(int i4) {
            if (!zzaii.zzc) {
                while ((i4 & (-128)) != 0) {
                    byte[] bArr = this.zzb;
                    int i5 = this.zzd;
                    this.zzd = i5 + 1;
                    bArr[i5] = (byte) (i4 | 128);
                    this.zze++;
                    i4 >>>= 7;
                }
                byte[] bArr2 = this.zzb;
                int i6 = this.zzd;
                this.zzd = i6 + 1;
                bArr2[i6] = (byte) i4;
                this.zze++;
                return;
            }
            long j4 = this.zzd;
            while ((i4 & (-128)) != 0) {
                byte[] bArr3 = this.zzb;
                int i7 = this.zzd;
                this.zzd = i7 + 1;
                zzamh.zza(bArr3, i7, (byte) (i4 | 128));
                i4 >>>= 7;
            }
            byte[] bArr4 = this.zzb;
            int i8 = this.zzd;
            this.zzd = i8 + 1;
            zzamh.zza(bArr4, i8, (byte) i4);
            this.zze += (int) (((long) this.zzd) - j4);
        }
    }

    public static class zzd extends IOException {
        public zzd() {
            super("CodedOutputStream was writing to a flat byte array and ran out of space.");
        }

        public zzd(Throwable th) {
            super("CodedOutputStream was writing to a flat byte array and ran out of space.", th);
        }

        public zzd(String str, Throwable th) {
            super(a.m("CodedOutputStream was writing to a flat byte array and ran out of space.: ", str), th);
        }
    }

    public static int zza(double d5) {
        return 8;
    }

    public static int zzb(int i4) {
        return 4;
    }

    public static int zzc(long j4) {
        return 8;
    }

    public static int zzd(int i4) {
        if (i4 > 4096) {
            return 4096;
        }
        return i4;
    }

    public static int zze(int i4) {
        return 4;
    }

    public static int zzf(int i4) {
        return zzh(zzm(i4));
    }

    public static int zzg(int i4) {
        return zzh(i4 << 3);
    }

    public static int zzh(int i4) {
        return (352 - (Integer.numberOfLeadingZeros(i4) * 9)) >>> 6;
    }

    private static long zzi(long j4) {
        return (j4 >> 63) ^ (j4 << 1);
    }

    private static int zzm(int i4) {
        return (i4 >> 31) ^ (i4 << 1);
    }

    public abstract int zza();

    public abstract void zza(byte b5);

    public abstract void zzb(int i4, zzakk zzakkVar);

    public abstract void zzb(int i4, String str);

    public abstract void zzb(int i4, boolean z4);

    public abstract void zzb(zzahm zzahmVar);

    public abstract void zzb(zzakk zzakkVar, zzalc zzalcVar);

    public abstract void zzb(String str);

    public abstract void zzb(byte[] bArr, int i4, int i5);

    public abstract void zzc();

    public abstract void zzc(int i4, zzahm zzahmVar);

    public abstract void zzc(int i4, zzakk zzakkVar, zzalc zzalcVar);

    public abstract void zzc(zzakk zzakkVar);

    public abstract void zzd(int i4, zzahm zzahmVar);

    public abstract void zzf(int i4, long j4);

    public abstract void zzf(long j4);

    public abstract void zzg(int i4, int i5);

    public abstract void zzh(int i4, int i5);

    public abstract void zzh(int i4, long j4);

    public abstract void zzh(long j4);

    public abstract void zzi(int i4);

    public abstract void zzj(int i4);

    public abstract void zzj(int i4, int i5);

    public final void zzk(int i4) {
        zzl(zzm(i4));
    }

    public abstract void zzk(int i4, int i5);

    public abstract void zzl(int i4);

    public static final class zzc extends zzb {
        private final OutputStream zzf;

        public zzc(OutputStream outputStream, int i4) {
            super(i4);
            if (outputStream == null) {
                throw new NullPointerException("out");
            }
            this.zzf = outputStream;
        }

        private final void zze() throws IOException {
            this.zzf.write(this.zzb, 0, this.zzd);
            this.zzd = 0;
        }

        private final void zzo(int i4) throws IOException {
            if (this.zzc - this.zzd < i4) {
                zze();
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zza(byte b5) throws IOException {
            if (this.zzd == this.zzc) {
                zze();
            }
            zzb(b5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(int i4, boolean z4) throws IOException {
            zzo(11);
            zzl(i4, 0);
            zzb(z4 ? (byte) 1 : (byte) 0);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc() throws IOException {
            if (this.zzd > 0) {
                zze();
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzd(int i4, zzahm zzahmVar) throws IOException {
            zzj(1, 3);
            zzk(2, i4);
            zzc(3, zzahmVar);
            zzj(1, 4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzf(int i4, long j4) throws IOException {
            zzo(18);
            zzl(i4, 1);
            zzi(j4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzg(int i4, int i5) throws IOException {
            zzo(14);
            zzl(i4, 5);
            zzm(i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzh(int i4, int i5) throws IOException {
            zzo(20);
            zzl(i4, 0);
            if (i5 >= 0) {
                zzn(i5);
            } else {
                zzj(i5);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzi(int i4) throws IOException {
            zzo(4);
            zzm(i4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzj(int i4) throws IOException {
            if (i4 >= 0) {
                zzl(i4);
            } else {
                zzh(i4);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzk(int i4, int i5) throws IOException {
            zzo(20);
            zzl(i4, 0);
            zzn(i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzl(int i4) throws IOException {
            zzo(5);
            zzn(i4);
        }

        private final void zzc(byte[] bArr, int i4, int i5) throws IOException {
            int i6 = this.zzc;
            int i7 = this.zzd;
            if (i6 - i7 >= i5) {
                System.arraycopy(bArr, i4, this.zzb, i7, i5);
                this.zzd += i5;
            } else {
                int i8 = i6 - i7;
                System.arraycopy(bArr, i4, this.zzb, i7, i8);
                int i9 = i4 + i8;
                i5 -= i8;
                this.zzd = this.zzc;
                this.zze += i8;
                zze();
                if (i5 <= this.zzc) {
                    System.arraycopy(bArr, i9, this.zzb, 0, i5);
                    this.zzd = i5;
                } else {
                    this.zzf.write(bArr, i9, i5);
                }
            }
            this.zze += i5;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzj(int i4, int i5) throws IOException {
            zzl((i4 << 3) | i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahn
        public final void zza(byte[] bArr, int i4, int i5) throws IOException {
            zzc(bArr, i4, i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(byte[] bArr, int i4, int i5) throws IOException {
            zzl(i5);
            zzc(bArr, 0, i5);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzf(long j4) throws IOException {
            zzo(8);
            zzi(j4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzh(int i4, long j4) throws IOException {
            zzo(20);
            zzl(i4, 0);
            zzj(j4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(zzahm zzahmVar) throws IOException {
            zzl(zzahmVar.zzb());
            zzahmVar.zza(this);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(zzakk zzakkVar, zzalc zzalcVar) throws IOException {
            zzl(((zzahd) zzakkVar).zza(zzalcVar));
            zzalcVar.zza(zzakkVar, this.zza);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzh(long j4) throws IOException {
            zzo(10);
            zzj(j4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(int i4, zzakk zzakkVar) throws IOException {
            zzj(1, 3);
            zzk(2, i4);
            zzj(3, 2);
            zzc(zzakkVar);
            zzj(1, 4);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(int i4, String str) throws IOException {
            zzj(i4, 2);
            zzb(str);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc(int i4, zzahm zzahmVar) throws IOException {
            zzj(i4, 2);
            zzb(zzahmVar);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzb(String str) throws IOException {
            int iZza;
            try {
                int length = str.length() * 3;
                int iZzh = zzaii.zzh(length);
                int i4 = iZzh + length;
                int i5 = this.zzc;
                if (i4 > i5) {
                    byte[] bArr = new byte[length];
                    int iZza2 = zzaml.zza(str, bArr, 0, length);
                    zzl(iZza2);
                    zza(bArr, 0, iZza2);
                    return;
                }
                if (i4 > i5 - this.zzd) {
                    zze();
                }
                int iZzh2 = zzaii.zzh(str.length());
                int i6 = this.zzd;
                try {
                    if (iZzh2 == iZzh) {
                        int i7 = i6 + iZzh2;
                        this.zzd = i7;
                        int iZza3 = zzaml.zza(str, this.zzb, i7, this.zzc - i7);
                        this.zzd = i6;
                        iZza = (iZza3 - i6) - iZzh2;
                        zzn(iZza);
                        this.zzd = iZza3;
                    } else {
                        iZza = zzaml.zza(str);
                        zzn(iZza);
                        this.zzd = zzaml.zza(str, this.zzb, this.zzd, iZza);
                    }
                    this.zze += iZza;
                } catch (zzamp e) {
                    this.zze -= this.zzd - i6;
                    this.zzd = i6;
                    throw e;
                } catch (ArrayIndexOutOfBoundsException e4) {
                    throw new zzd(e4);
                }
            } catch (zzamp e5) {
                zza(str, e5);
            }
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc(int i4, zzakk zzakkVar, zzalc zzalcVar) throws IOException {
            zzj(i4, 2);
            zzb(zzakkVar, zzalcVar);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaii
        public final void zzc(zzakk zzakkVar) throws IOException {
            zzl(zzakkVar.zzk());
            zzakkVar.zza(this);
        }
    }

    private zzaii() {
    }

    public static int zza(float f4) {
        return 4;
    }

    public static int zzb(int i4, int i5) {
        return zzh(i4 << 3) + 4;
    }

    public static int zzc(int i4, int i5) {
        return zze(i5) + zzh(i4 << 3);
    }

    public static int zze(int i4, int i5) {
        return zzh(zzm(i5)) + zzh(i4 << 3);
    }

    public static int zzf(int i4, int i5) {
        return zzh(i5) + zzh(i4 << 3);
    }

    public final void zzg(int i4, long j4) {
        zzh(i4, zzi(j4));
    }

    public final void zzi(int i4, int i5) {
        zzk(i4, zzm(i5));
    }

    public static int zza(long j4) {
        return 8;
    }

    public static int zzb(int i4, long j4) {
        return zze(j4) + zzh(i4 << 3);
    }

    public static int zzd(int i4, int i5) {
        return zzh(i4 << 3) + 4;
    }

    public final void zzg(long j4) {
        zzh(zzi(j4));
    }

    public static int zza(boolean z4) {
        return 1;
    }

    public static int zzc(int i4) {
        return zze(i4);
    }

    public static int zzd(int i4, long j4) {
        return zze(zzi(j4)) + zzh(i4 << 3);
    }

    public static int zze(int i4, long j4) {
        return zze(j4) + zzh(i4 << 3);
    }

    public static int zza(int i4, boolean z4) {
        return zzh(i4 << 3) + 1;
    }

    public static int zzb(long j4) {
        return zze(j4);
    }

    public static int zzc(int i4, long j4) {
        return zzh(i4 << 3) + 8;
    }

    public static int zza(byte[] bArr) {
        int length = bArr.length;
        return zzh(length) + length;
    }

    public static int zzb(int i4, zzajo zzajoVar) {
        int iZzh = zzh(i4 << 3);
        int iZzb = zzajoVar.zzb();
        return zzh(iZzb) + iZzb + iZzh;
    }

    public static int zzd(long j4) {
        return zze(zzi(j4));
    }

    public static int zze(long j4) {
        return (640 - (Long.numberOfLeadingZeros(j4) * 9)) >>> 6;
    }

    public static int zza(int i4, zzahm zzahmVar) {
        int iZzh = zzh(i4 << 3);
        int iZzb = zzahmVar.zzb();
        return zzh(iZzb) + iZzb + iZzh;
    }

    public static int zzb(int i4, zzakk zzakkVar, zzalc zzalcVar) {
        return zza(zzakkVar, zzalcVar) + zzh(i4 << 3);
    }

    public static int zza(zzahm zzahmVar) {
        int iZzb = zzahmVar.zzb();
        return zzh(iZzb) + iZzb;
    }

    public static int zzb(zzakk zzakkVar) {
        int iZzk = zzakkVar.zzk();
        return zzh(iZzk) + iZzk;
    }

    public static int zza(int i4, double d5) {
        return zzh(i4 << 3) + 8;
    }

    public static int zzb(int i4, zzahm zzahmVar) {
        return zza(3, zzahmVar) + zzf(2, i4) + (zzh(8) << 1);
    }

    public static int zza(int i4, int i5) {
        return zze(i5) + zzh(i4 << 3);
    }

    public static int zza(int i4) {
        return zze(i4);
    }

    public static zzaii zzb(byte[] bArr) {
        return new zza(bArr, 0, bArr.length);
    }

    public static int zza(int i4, long j4) {
        return zzh(i4 << 3) + 8;
    }

    public static int zza(int i4, float f4) {
        return zzh(i4 << 3) + 4;
    }

    public final void zzb() {
        if (zza() != 0) {
            throw new IllegalStateException("Did not write as much data as expected.");
        }
    }

    @Deprecated
    public static int zza(int i4, zzakk zzakkVar, zzalc zzalcVar) {
        return ((zzahd) zzakkVar).zza(zzalcVar) + (zzh(i4 << 3) << 1);
    }

    public final void zzb(boolean z4) {
        zza(z4 ? (byte) 1 : (byte) 0);
    }

    @Deprecated
    public static int zza(zzakk zzakkVar) {
        return zzakkVar.zzk();
    }

    public final void zzb(int i4, double d5) {
        zzf(i4, Double.doubleToRawLongBits(d5));
    }

    public static int zza(int i4, zzajo zzajoVar) {
        return zzb(3, zzajoVar) + zzf(2, i4) + (zzh(8) << 1);
    }

    public final void zzb(double d5) {
        zzf(Double.doubleToRawLongBits(d5));
    }

    public final void zzb(int i4, float f4) {
        zzg(i4, Float.floatToRawIntBits(f4));
    }

    public final void zzb(float f4) {
        zzi(Float.floatToRawIntBits(f4));
    }

    public static int zza(zzajo zzajoVar) {
        int iZzb = zzajoVar.zzb();
        return zzh(iZzb) + iZzb;
    }

    public static int zza(int i4, zzakk zzakkVar) {
        return zzb(zzakkVar) + zzh(24) + zzf(2, i4) + (zzh(8) << 1);
    }

    public static int zza(zzakk zzakkVar, zzalc zzalcVar) {
        int iZza = ((zzahd) zzakkVar).zza(zzalcVar);
        return zzh(iZza) + iZza;
    }

    public static int zza(int i4, String str) {
        return zza(str) + zzh(i4 << 3);
    }

    public static int zza(String str) {
        int length;
        try {
            length = zzaml.zza(str);
        } catch (zzamp unused) {
            length = str.getBytes(zzajc.zza).length;
        }
        return zzh(length) + length;
    }

    public static zzaii zza(OutputStream outputStream, int i4) {
        return new zzc(outputStream, i4);
    }

    public final void zza(String str, zzamp zzampVar) throws zzd {
        zzb.logp(Level.WARNING, "com.google.protobuf.CodedOutputStream", "inefficientWriteStringNoTag", "Converting ill-formed UTF-16. Your Protocol Buffer will not round trip correctly!", (Throwable) zzampVar);
        byte[] bytes = str.getBytes(zzajc.zza);
        try {
            zzl(bytes.length);
            zza(bytes, 0, bytes.length);
        } catch (IndexOutOfBoundsException e) {
            throw new zzd(e);
        }
    }
}
