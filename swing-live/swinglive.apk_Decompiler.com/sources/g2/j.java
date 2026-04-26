package g2;

import X.N;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final N f4370f = new N(15);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public f f4371a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4372b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4373c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public g f4374d;
    public int e;

    public j(f fVar) {
        J3.i.e(fVar, "basicHeader");
        this.f4371a = fVar;
    }

    public final int a() {
        int i4;
        int i5 = this.f4373c;
        f fVar = this.f4371a;
        int i6 = this.f4372b;
        int iOrdinal = fVar.f4337a.ordinal();
        if (iOrdinal == 0) {
            i4 = 12;
        } else if (iOrdinal == 1) {
            i4 = 8;
        } else if (iOrdinal == 2) {
            i4 = 4;
        } else {
            if (iOrdinal != 3) {
                throw new A0.b();
            }
            i4 = 0;
        }
        if (i6 >= 16777215) {
            i4 += 4;
        }
        return i5 + i4;
    }

    /* JADX WARN: Removed duplicated region for block: B:34:0x00a4  */
    /* JADX WARN: Removed duplicated region for block: B:50:0x00df  */
    /* JADX WARN: Removed duplicated region for block: B:60:0x0117 A[PHI: r10
      0x0117: PHI (r10v31 e1.g) = (r10v29 e1.g), (r10v32 e1.g) binds: [B:58:0x0113, B:20:0x004c] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:62:0x011b  */
    /* JADX WARN: Removed duplicated region for block: B:67:0x0131  */
    /* JADX WARN: Removed duplicated region for block: B:70:0x0140  */
    /* JADX WARN: Removed duplicated region for block: B:77:0x0163 A[PHI: r10
      0x0163: PHI (r10v22 e1.g) = (r10v20 e1.g), (r10v23 e1.g) binds: [B:75:0x0160, B:26:0x006c] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:79:0x0167  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Removed duplicated region for block: B:85:0x0187 A[PHI: r10
      0x0187: PHI (r10v26 e1.g) = (r10v24 e1.g), (r10v28 e1.g) binds: [B:83:0x0184, B:24:0x005e] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:87:0x018b  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(g2.f r10, e1.AbstractC0367g r11, A3.c r12) {
        /*
            Method dump skipped, instruction units count: 442
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: g2.j.b(g2.f, e1.g, A3.c):java.lang.Object");
    }

    public final String toString() {
        return "RtmpHeader(timeStamp=" + this.f4372b + ", messageLength=" + this.f4373c + ", messageType=" + this.f4374d + ", messageStreamId=" + this.e + ", basicHeader=" + this.f4371a + ")";
    }
}
