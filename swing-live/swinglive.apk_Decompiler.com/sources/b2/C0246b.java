package b2;

import J3.i;
import java.io.Serializable;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: b2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0246b extends H0.a {

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final /* synthetic */ int f3276i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final byte[] f3277j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public boolean f3278k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public Serializable f3279l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Serializable f3280m;

    public C0246b(int i4) {
        this.f3276i = i4;
        switch (i4) {
            case 1:
                this.f3277j = new byte[5];
                break;
            default:
                this.f3277j = new byte[2];
                this.f3279l = a2.d.f2638b;
                this.f3280m = a2.c.f2635b;
                break;
        }
    }

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
        switch (this.f3276i) {
            case 0:
                this.f3278k = false;
                break;
            default:
                if (z4) {
                    this.f3279l = null;
                    this.f3280m = null;
                }
                this.f3278k = false;
                break;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:13:0x0040  */
    /* JADX WARN: Removed duplicated region for block: B:19:0x0064  */
    /* JADX WARN: Removed duplicated region for block: B:33:0x011d  */
    /* JADX WARN: Removed duplicated region for block: B:34:0x011f  */
    /* JADX WARN: Removed duplicated region for block: B:51:0x016d  */
    /* JADX WARN: Removed duplicated region for block: B:93:? A[RETURN, SYNTHETIC] */
    @Override // H0.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object l(B1.d r28, I3.p r29, y3.InterfaceC0762c r30) {
        /*
            Method dump skipped, instruction units count: 692
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: b2.C0246b.l(B1.d, I3.p, y3.c):java.lang.Object");
    }
}
