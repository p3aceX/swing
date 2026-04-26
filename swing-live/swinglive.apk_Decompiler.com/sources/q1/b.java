package Q1;

import F1.c;
import J3.i;
import K.j;
import a.AbstractC0184a;
import android.media.MediaCodec;
import android.media.MediaFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.Surface;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import p1.d;

/* JADX INFO: loaded from: classes.dex */
public final class b extends c {

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final a f1555r;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public ByteBuffer f1558u;
    public ByteBuffer v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public ByteBuffer f1559w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public Surface f1560x;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public volatile boolean f1556s = false;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f1557t = false;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f1561y = 640;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public int f1562z = 480;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public int f1546A = 30;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public int f1547B = 1228800;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public int f1548C = 90;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public int f1549D = 2;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public long f1550E = 0;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public final d f1551F = new d();

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public int f1552G = 14;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public int f1553H = -1;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public int f1554I = -1;

    public b(a aVar) {
        this.f1555r = aVar;
        this.f433p = 1;
        this.f432o = "video/avc";
        this.f419a = "VideoEncoder";
    }

    @Override // F1.c
    public final long a(F1.d dVar, long j4) {
        return Math.max(0L, dVar.f437c - j4);
    }

    /* JADX WARN: Removed duplicated region for block: B:53:0x0152  */
    /* JADX WARN: Removed duplicated region for block: B:54:0x015c  */
    @Override // F1.c
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void b(java.nio.ByteBuffer r9, android.media.MediaCodec.BufferInfo r10) {
        /*
            Method dump skipped, instruction units count: 397
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: Q1.b.b(java.nio.ByteBuffer, android.media.MediaCodec$BufferInfo):void");
    }

    @Override // F1.c
    public final void d(MediaFormat mediaFormat) {
        this.f1555r.r(mediaFormat);
        boolean zEquals = this.f432o.equals("video/av01");
        a aVar = this.f1555r;
        boolean z4 = false;
        if (zEquals) {
            ByteBuffer byteBuffer = mediaFormat.getByteBuffer("csd-0");
            if (byteBuffer != null && byteBuffer.remaining() > 4) {
                ByteBuffer byteBufferDuplicate = byteBuffer.duplicate();
                this.f1558u = byteBufferDuplicate;
                aVar.o(byteBufferDuplicate, null, null);
                z4 = true;
            }
        } else if (this.f432o.equals("video/hevc")) {
            ByteBuffer byteBuffer2 = mediaFormat.getByteBuffer("csd-0");
            if (byteBuffer2 != null) {
                ArrayList arrayListF = AbstractC0184a.F(byteBuffer2.duplicate());
                this.f1558u = (ByteBuffer) arrayListF.get(1);
                this.v = (ByteBuffer) arrayListF.get(2);
                ByteBuffer byteBuffer3 = (ByteBuffer) arrayListF.get(0);
                this.f1559w = byteBuffer3;
                aVar.o(this.f1558u, this.v, byteBuffer3);
                z4 = true;
            }
        } else {
            ByteBuffer byteBuffer4 = mediaFormat.getByteBuffer("csd-0");
            ByteBuffer byteBuffer5 = mediaFormat.getByteBuffer("csd-1");
            if (byteBuffer4 != null && byteBuffer5 != null) {
                this.f1558u = byteBuffer4.duplicate();
                ByteBuffer byteBufferDuplicate2 = byteBuffer5.duplicate();
                this.v = byteBufferDuplicate2;
                this.f1559w = null;
                aVar.o(this.f1558u, byteBufferDuplicate2, null);
                z4 = true;
            }
        }
        this.f1556s = z4;
    }

    @Override // F1.c
    public final F1.d f() {
        F1.d dVar = (F1.d) this.e.take();
        byte[] bArr = null;
        if (dVar == null) {
            return null;
        }
        this.f1551F.getClass();
        byte[] bArr2 = dVar.f435a;
        int i4 = this.f1561y;
        int i5 = this.f1562z;
        int iB = j.b(this.f1552G);
        int i6 = 0;
        if (iB == 1) {
            int i7 = i4 * i5;
            int i8 = i7 / 4;
            System.arraycopy(bArr2, 0, AbstractC0184a.f2628a, 0, i7);
            while (i6 < i8) {
                byte[] bArr3 = AbstractC0184a.f2628a;
                int i9 = i7 + i6;
                int i10 = (i6 * 2) + i7;
                bArr3[i9] = bArr2[i10 + 1];
                bArr3[i9 + i8] = bArr2[i10];
                i6++;
            }
            bArr = AbstractC0184a.f2628a;
        } else if (iB == 2) {
            int i11 = i4 * i5;
            int i12 = i11 / 4;
            System.arraycopy(bArr2, 0, AbstractC0184a.f2628a, 0, i11);
            while (i6 < i12) {
                byte[] bArr4 = AbstractC0184a.f2628a;
                int i13 = (i6 * 2) + i11;
                int i14 = i13 + 1;
                bArr4[i13] = bArr2[i14];
                bArr4[i14] = bArr2[i13];
                i6++;
            }
            bArr = AbstractC0184a.f2628a;
        }
        i.e(bArr, "<set-?>");
        dVar.f435a = bArr;
        return dVar;
    }

    @Override // F1.c
    public final boolean j() {
        o(false);
        if (!q(this.f1561y, this.f1562z, this.f1546A, this.f1547B, this.f1548C, this.f1549D, this.f1552G, this.f1553H, this.f1554I)) {
            return false;
        }
        n(false);
        g();
        return true;
    }

    @Override // F1.c
    public final void k(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo) {
        this.f1555r.l(byteBuffer, bufferInfo);
    }

    @Override // F1.c
    public final void n(boolean z4) {
        if (z4) {
            this.f1550E = 0L;
        }
        this.f1557t = false;
        this.f429l = z4;
        this.f1556s = false;
        if (this.f1552G != 13) {
            int i4 = ((this.f1561y * this.f1562z) * 3) / 2;
            byte[] bArr = new byte[i4];
            AbstractC0184a.f2628a = new byte[i4];
            byte[] bArr2 = new byte[i4];
            byte[] bArr3 = new byte[i4];
        }
        Log.i(this.f419a, "started");
    }

    @Override // F1.c
    public final void p() {
        this.f1556s = false;
        Surface surface = this.f1560x;
        if (surface != null) {
            surface.release();
        }
        this.f1560x = null;
        this.f1558u = null;
        this.v = null;
        this.f1559w = null;
        Log.i(this.f419a, "stopped");
    }

    /* JADX WARN: Code restructure failed: missing block: B:37:0x0101, code lost:
    
        if (r13 == null) goto L78;
     */
    /* JADX WARN: Code restructure failed: missing block: B:38:0x0103, code lost:
    
        android.util.Log.i(r20.f419a, "Encoder selected " + r13.getName());
        r20.f423f = android.media.MediaCodec.createByCodecName(r13.getName());
     */
    /* JADX WARN: Code restructure failed: missing block: B:39:0x012b, code lost:
    
        if (r20.f1552G != 14) goto L56;
     */
    /* JADX WARN: Code restructure failed: missing block: B:40:0x012d, code lost:
    
        r8 = r13.getCapabilitiesForType(r20.f432o).colorFormats;
        r9 = r8.length;
        r10 = r17;
     */
    /* JADX WARN: Code restructure failed: missing block: B:41:0x0138, code lost:
    
        if (r10 >= r9) goto L94;
     */
    /* JADX WARN: Code restructure failed: missing block: B:42:0x013a, code lost:
    
        r11 = r8[r10];
     */
    /* JADX WARN: Code restructure failed: missing block: B:43:0x0140, code lost:
    
        if (r11 != B1.a.e(r16)) goto L45;
     */
    /* JADX WARN: Code restructure failed: missing block: B:44:0x0142, code lost:
    
        r11 = r16;
     */
    /* JADX WARN: Code restructure failed: missing block: B:46:0x0149, code lost:
    
        if (r11 != B1.a.e(r28)) goto L48;
     */
    /* JADX WARN: Code restructure failed: missing block: B:47:0x014b, code lost:
    
        r11 = r28;
     */
    /* JADX WARN: Code restructure failed: missing block: B:48:0x014e, code lost:
    
        r10 = r10 + 1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:49:0x0151, code lost:
    
        r11 = r17;
     */
    /* JADX WARN: Code restructure failed: missing block: B:50:0x0153, code lost:
    
        r20.f1552G = r11;
     */
    /* JADX WARN: Code restructure failed: missing block: B:51:0x0155, code lost:
    
        if (r11 != 0) goto L56;
     */
    /* JADX WARN: Code restructure failed: missing block: B:52:0x0157, code lost:
    
        android.util.Log.e(r20.f419a, "YUV420 dynamical choose failed");
     */
    /* JADX WARN: Code restructure failed: missing block: B:53:0x015e, code lost:
    
        return r17;
     */
    /* JADX WARN: Code restructure failed: missing block: B:54:0x015f, code lost:
    
        r0 = move-exception;
     */
    /* JADX WARN: Code restructure failed: missing block: B:57:0x0166, code lost:
    
        if (r25 == 90) goto L62;
     */
    /* JADX WARN: Code restructure failed: missing block: B:59:0x016a, code lost:
    
        if (r25 != 270) goto L61;
     */
    /* JADX WARN: Code restructure failed: missing block: B:61:0x016d, code lost:
    
        r5 = r21 + "x" + r22;
        r0 = android.media.MediaFormat.createVideoFormat(r20.f432o, r21, r22);
     */
    /* JADX WARN: Code restructure failed: missing block: B:62:0x0186, code lost:
    
        r5 = r22 + "x" + r21;
        r0 = android.media.MediaFormat.createVideoFormat(r20.f432o, r22, r21);
     */
    /* JADX WARN: Code restructure failed: missing block: B:63:0x019e, code lost:
    
        android.util.Log.i(r20.f419a, "Prepare video info: " + B1.a.r(r20.f1552G) + ", " + r5);
        r0.setInteger("color-format", B1.a.e(r20.f1552G));
        r0.setInteger("max-input-size", r17 ? 1 : 0);
        r0.setInteger("bitrate", r24);
        r0.setInteger("frame-rate", r23);
        r0.setInteger("i-frame-interval", r26);
     */
    /* JADX WARN: Code restructure failed: missing block: B:64:0x01e9, code lost:
    
        if (H0.a.I(r13, r20.f432o) == false) goto L66;
     */
    /* JADX WARN: Code restructure failed: missing block: B:65:0x01eb, code lost:
    
        android.util.Log.i(r20.f419a, "set bitrate mode CBR");
        r0.setInteger("bitrate-mode", r16);
     */
    /* JADX WARN: Code restructure failed: missing block: B:66:0x01fa, code lost:
    
        android.util.Log.i(r20.f419a, "bitrate mode CBR not supported using default mode");
     */
    /* JADX WARN: Code restructure failed: missing block: B:67:0x0201, code lost:
    
        r2 = r20.f1553H;
     */
    /* JADX WARN: Code restructure failed: missing block: B:68:0x0203, code lost:
    
        if (r2 <= 0) goto L70;
     */
    /* JADX WARN: Code restructure failed: missing block: B:69:0x0205, code lost:
    
        r0.setInteger("profile", r2);
     */
    /* JADX WARN: Code restructure failed: missing block: B:70:0x020a, code lost:
    
        r2 = r20.f1554I;
     */
    /* JADX WARN: Code restructure failed: missing block: B:71:0x020c, code lost:
    
        if (r2 <= 0) goto L73;
     */
    /* JADX WARN: Code restructure failed: missing block: B:72:0x020e, code lost:
    
        r0.setInteger("level", r2);
     */
    /* JADX WARN: Code restructure failed: missing block: B:73:0x0213, code lost:
    
        l();
        r20.f423f.configure(r0, (android.view.Surface) null, (android.media.MediaCrypto) null, 1);
        r20.f425h = false;
     */
    /* JADX WARN: Code restructure failed: missing block: B:74:0x0222, code lost:
    
        if (r27 != 13) goto L76;
     */
    /* JADX WARN: Code restructure failed: missing block: B:75:0x0224, code lost:
    
        r20.f426i = false;
        r20.f1560x = r20.f423f.createInputSurface();
     */
    /* JADX WARN: Code restructure failed: missing block: B:76:0x022e, code lost:
    
        android.util.Log.i(r20.f419a, "prepared");
        r20.f430m = true;
     */
    /* JADX WARN: Code restructure failed: missing block: B:77:0x0238, code lost:
    
        return true;
     */
    /* JADX WARN: Code restructure failed: missing block: B:78:0x0239, code lost:
    
        android.util.Log.e(r20.f419a, "Valid encoder not found");
     */
    /* JADX WARN: Code restructure failed: missing block: B:79:0x0240, code lost:
    
        return false;
     */
    /* JADX WARN: Code restructure failed: missing block: B:81:0x0243, code lost:
    
        android.util.Log.e(r20.f419a, "Create VideoEncoder failed.", r0);
        o(true);
     */
    /* JADX WARN: Code restructure failed: missing block: B:82:0x0250, code lost:
    
        return false;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r10v10, types: [int] */
    /* JADX WARN: Type inference failed for: r10v13 */
    /* JADX WARN: Type inference failed for: r10v9 */
    /* JADX WARN: Type inference failed for: r11v2 */
    /* JADX WARN: Type inference failed for: r11v3, types: [int] */
    /* JADX WARN: Type inference failed for: r11v5 */
    /* JADX WARN: Type inference failed for: r11v6 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean q(int r21, int r22, int r23, int r24, int r25, int r26, int r27, int r28, int r29) {
        /*
            Method dump skipped, instruction units count: 631
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: Q1.b.q(int, int, int, int, int, int, int, int, int):boolean");
    }

    public final void r() {
        if (this.f425h) {
            if (!this.f1556s || this.f1558u == null) {
                this.f1556s = false;
                this.f1557t = true;
                return;
            }
            Bundle bundle = new Bundle();
            bundle.putInt("request-sync", 0);
            try {
                this.f423f.setParameters(bundle);
                this.f1555r.o(this.f1558u, this.v, this.f1559w);
            } catch (IllegalStateException e) {
                Log.e(this.f419a, "encoder need be running", e);
            }
        }
    }
}
