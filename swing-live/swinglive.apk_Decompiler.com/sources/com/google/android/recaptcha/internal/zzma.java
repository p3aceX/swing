package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
final class zzma {
    private static final zzlx zza;

    static {
        if (zzlv.zzx() && zzlv.zzy()) {
            int i4 = zzgi.zza;
        }
        zza = new zzly();
    }

    public static /* bridge */ /* synthetic */ int zza(byte[] bArr, int i4, int i5) {
        int i6 = i5 - i4;
        byte b5 = bArr[i4 - 1];
        if (i6 == 0) {
            if (b5 <= -12) {
                return b5;
            }
            return -1;
        }
        if (i6 == 1) {
            byte b6 = bArr[i4];
            if (b5 > -12 || b6 > -65) {
                return -1;
            }
            return (b6 << 8) ^ b5;
        }
        if (i6 != 2) {
            throw new AssertionError();
        }
        byte b7 = bArr[i4];
        byte b8 = bArr[i4 + 1];
        if (b5 > -12 || b7 > -65 || b8 > -65) {
            return -1;
        }
        return (b8 << 16) ^ ((b7 << 8) ^ b5);
    }

    public static int zzb(CharSequence charSequence, byte[] bArr, int i4, int i5) {
        int i6;
        int i7;
        int i8;
        char cCharAt;
        int length = charSequence.length();
        int i9 = 0;
        while (true) {
            i6 = i4 + i5;
            if (i9 >= length || (i8 = i9 + i4) >= i6 || (cCharAt = charSequence.charAt(i9)) >= 128) {
                break;
            }
            bArr[i8] = (byte) cCharAt;
            i9++;
        }
        if (i9 == length) {
            return i4 + length;
        }
        int i10 = i4 + i9;
        while (i9 < length) {
            char cCharAt2 = charSequence.charAt(i9);
            if (cCharAt2 < 128 && i10 < i6) {
                bArr[i10] = (byte) cCharAt2;
                i10++;
            } else if (cCharAt2 < 2048 && i10 <= i6 - 2) {
                bArr[i10] = (byte) ((cCharAt2 >>> 6) | 960);
                bArr[i10 + 1] = (byte) ((cCharAt2 & '?') | 128);
                i10 += 2;
            } else {
                if ((cCharAt2 >= 55296 && cCharAt2 <= 57343) || i10 > i6 - 3) {
                    if (i10 > i6 - 4) {
                        if (cCharAt2 >= 55296 && cCharAt2 <= 57343 && ((i7 = i9 + 1) == charSequence.length() || !Character.isSurrogatePair(cCharAt2, charSequence.charAt(i7)))) {
                            throw new zzlz(i9, length);
                        }
                        throw new ArrayIndexOutOfBoundsException("Failed writing " + cCharAt2 + " at index " + i10);
                    }
                    int i11 = i9 + 1;
                    if (i11 != charSequence.length()) {
                        char cCharAt3 = charSequence.charAt(i11);
                        if (Character.isSurrogatePair(cCharAt2, cCharAt3)) {
                            int i12 = i10 + 3;
                            int codePoint = Character.toCodePoint(cCharAt2, cCharAt3);
                            bArr[i10] = (byte) ((codePoint >>> 18) | 240);
                            bArr[i10 + 1] = (byte) (((codePoint >>> 12) & 63) | 128);
                            bArr[i10 + 2] = (byte) (((codePoint >>> 6) & 63) | 128);
                            i10 += 4;
                            bArr[i12] = (byte) ((codePoint & 63) | 128);
                            i9 = i11;
                        } else {
                            i9 = i11;
                        }
                    }
                    throw new zzlz(i9 - 1, length);
                }
                bArr[i10] = (byte) ((cCharAt2 >>> '\f') | 480);
                bArr[i10 + 1] = (byte) (((cCharAt2 >>> 6) & 63) | 128);
                bArr[i10 + 2] = (byte) ((cCharAt2 & '?') | 128);
                i10 += 3;
            }
            i9++;
        }
        return i10;
    }

    public static int zzc(CharSequence charSequence) {
        int length = charSequence.length();
        int i4 = 0;
        int i5 = 0;
        while (i5 < length && charSequence.charAt(i5) < 128) {
            i5++;
        }
        int i6 = length;
        while (true) {
            if (i5 >= length) {
                break;
            }
            char cCharAt = charSequence.charAt(i5);
            if (cCharAt < 2048) {
                i6 += (127 - cCharAt) >>> 31;
                i5++;
            } else {
                int length2 = charSequence.length();
                while (i5 < length2) {
                    char cCharAt2 = charSequence.charAt(i5);
                    if (cCharAt2 < 2048) {
                        i4 += (127 - cCharAt2) >>> 31;
                    } else {
                        i4 += 2;
                        if (cCharAt2 >= 55296 && cCharAt2 <= 57343) {
                            if (Character.codePointAt(charSequence, i5) < 65536) {
                                throw new zzlz(i5, length2);
                            }
                            i5++;
                        }
                    }
                    i5++;
                }
                i6 += i4;
            }
        }
        if (i6 >= length) {
            return i6;
        }
        throw new IllegalArgumentException("UTF-8 length does not fit in int: " + (((long) i6) + 4294967296L));
    }

    public static String zzd(byte[] bArr, int i4, int i5) throws zzje {
        int i6;
        int length = bArr.length;
        if ((((length - i4) - i5) | i4 | i5) < 0) {
            throw new ArrayIndexOutOfBoundsException(String.format("buffer length=%d, index=%d, size=%d", Integer.valueOf(length), Integer.valueOf(i4), Integer.valueOf(i5)));
        }
        int i7 = i4 + i5;
        char[] cArr = new char[i5];
        int i8 = 0;
        while (i4 < i7) {
            byte b5 = bArr[i4];
            if (!zzlw.zzd(b5)) {
                break;
            }
            i4++;
            cArr[i8] = (char) b5;
            i8++;
        }
        int i9 = i8;
        while (i4 < i7) {
            int i10 = i4 + 1;
            byte b6 = bArr[i4];
            if (zzlw.zzd(b6)) {
                cArr[i9] = (char) b6;
                i9++;
                i4 = i10;
                while (i4 < i7) {
                    byte b7 = bArr[i4];
                    if (zzlw.zzd(b7)) {
                        i4++;
                        cArr[i9] = (char) b7;
                        i9++;
                    }
                }
            } else {
                if (b6 < -32) {
                    if (i10 >= i7) {
                        throw zzje.zzd();
                    }
                    i6 = i9 + 1;
                    i4 += 2;
                    zzlw.zzc(b6, bArr[i10], cArr, i9);
                } else if (b6 < -16) {
                    if (i10 >= i7 - 1) {
                        throw zzje.zzd();
                    }
                    i6 = i9 + 1;
                    int i11 = i4 + 2;
                    i4 += 3;
                    zzlw.zzb(b6, bArr[i10], bArr[i11], cArr, i9);
                } else {
                    if (i10 >= i7 - 2) {
                        throw zzje.zzd();
                    }
                    byte b8 = bArr[i10];
                    int i12 = i4 + 3;
                    byte b9 = bArr[i4 + 2];
                    i4 += 4;
                    zzlw.zza(b6, b8, b9, bArr[i12], cArr, i9);
                    i9 += 2;
                }
                i9 = i6;
            }
        }
        return new String(cArr, 0, i9);
    }

    public static boolean zze(byte[] bArr) {
        return zza.zzb(bArr, 0, bArr.length);
    }

    public static boolean zzf(byte[] bArr, int i4, int i5) {
        return zza.zzb(bArr, i4, i5);
    }
}
