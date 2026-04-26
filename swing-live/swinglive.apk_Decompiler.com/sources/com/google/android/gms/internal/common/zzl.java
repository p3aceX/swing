package com.google.android.gms.internal.common;

/* JADX INFO: loaded from: classes.dex */
final class zzl extends zzk {
    private final char zza;

    public zzl(char c5) {
        this.zza = c5;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("CharMatcher.is('");
        int i4 = this.zza;
        char[] cArr = new char[6];
        cArr[0] = '\\';
        cArr[1] = 'u';
        cArr[2] = 0;
        cArr[3] = 0;
        cArr[4] = 0;
        cArr[5] = 0;
        for (int i5 = 0; i5 < 4; i5++) {
            cArr[5 - i5] = "0123456789ABCDEF".charAt(i4 & 15);
            i4 >>= 4;
        }
        sb.append(String.copyValueOf(cArr));
        sb.append("')");
        return sb.toString();
    }

    @Override // com.google.android.gms.internal.common.zzo
    public final boolean zza(char c5) {
        return c5 == this.zza;
    }
}
