package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class b0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0296a f3773a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3774b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object[] f3775c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f3776d;

    public b0(AbstractC0296a abstractC0296a, String str, Object[] objArr) {
        this.f3773a = abstractC0296a;
        this.f3774b = str;
        this.f3775c = objArr;
        char cCharAt = str.charAt(0);
        if (cCharAt < 55296) {
            this.f3776d = cCharAt;
            return;
        }
        int i4 = cCharAt & 8191;
        int i5 = 1;
        int i6 = 13;
        while (true) {
            int i7 = i5 + 1;
            char cCharAt2 = str.charAt(i5);
            if (cCharAt2 < 55296) {
                this.f3776d = i4 | (cCharAt2 << i6);
                return;
            } else {
                i4 |= (cCharAt2 & 8191) << i6;
                i6 += 13;
                i5 = i7;
            }
        }
    }
}
