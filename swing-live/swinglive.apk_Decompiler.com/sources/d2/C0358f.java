package d2;

import J3.i;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: d2.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0358f extends H0.a {

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final byte[] f3949i = new byte[8];

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public boolean f3950j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public byte[] f3951k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public byte[] f3952l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public byte[] f3953m;

    public static int o0(ByteBuffer byteBuffer) {
        if (byteBuffer.get(0) == 0 && byteBuffer.get(1) == 0 && byteBuffer.get(2) == 0 && byteBuffer.get(3) == 1) {
            return 4;
        }
        return (byteBuffer.get(0) == 0 && byteBuffer.get(1) == 0 && byteBuffer.get(2) == 1) ? 3 : 0;
    }

    public static ByteBuffer p0(ByteBuffer byteBuffer, int i4) {
        if (i4 == -1) {
            i4 = o0(byteBuffer);
        }
        byteBuffer.position(i4);
        ByteBuffer byteBufferSlice = byteBuffer.slice();
        i.d(byteBufferSlice, "slice(...)");
        return byteBufferSlice;
    }

    @Override // H0.a
    public final void a0(boolean z4) {
        if (z4) {
            this.f3951k = null;
            this.f3952l = null;
            this.f3953m = null;
        }
        this.f3950j = false;
    }

    /* JADX WARN: Removed duplicated region for block: B:72:0x0360  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x0362  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x001b  */
    /* JADX WARN: Removed duplicated region for block: B:89:0x03b8  */
    /* JADX WARN: Removed duplicated region for block: B:92:0x03bd  */
    @Override // H0.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object l(B1.d r39, I3.p r40, y3.InterfaceC0762c r41) {
        /*
            Method dump skipped, instruction units count: 1128
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: d2.C0358f.l(B1.d, I3.p, y3.c):java.lang.Object");
    }
}
