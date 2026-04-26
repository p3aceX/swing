package k;

import Q3.x0;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import java.lang.ref.WeakReference;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import n2.AbstractC0561d;
import n2.C0563f;
import n2.EnumC0558a;
import n2.EnumC0559b;
import p2.C0617a;
import q2.C0635a;
import x2.AbstractC0720a;
import y1.AbstractC0752b;

/* JADX INFO: renamed from: k.t, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0502t {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5457a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5458b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f5459c;

    public C0502t(ByteBuffer byteBuffer) {
        this.f5459c = byteBuffer;
        this.f5457a = byteBuffer.position() * 8;
        this.f5458b = byteBuffer.limit() * 8;
    }

    public static void g(ByteBuffer byteBuffer, boolean z4, int i4, EnumC0558a enumC0558a, int i5) {
        byteBuffer.put((byte) 71);
        byteBuffer.putShort((short) (((z4 ? 1 : 0) << 14) | i4));
        byteBuffer.put((byte) (((enumC0558a.f5864a & 3) << 4) | (i5 & 15)));
    }

    public static void h(ByteBuffer byteBuffer, int i4, boolean z4) {
        int i5 = z4 ? i4 - 2 : i4;
        if (i5 == -1) {
            byteBuffer.put((byte) (i4 - 1));
            return;
        }
        byte[] bArr = new byte[i5];
        for (int i6 = 0; i6 < i5; i6++) {
            bArr[i6] = -1;
        }
        if (z4) {
            byteBuffer.put((byte) (i4 - 1));
            byteBuffer.put((byte) 0);
        }
        byteBuffer.put(bArr);
    }

    public void a() {
        new Handler(Looper.getMainLooper()).post(new F1.a(this, 18));
    }

    public boolean b() {
        return ((int) c(1)) == 1;
    }

    public long c(int i4) {
        long jC;
        int i5 = this.f5457a;
        if ((this.f5458b - i5) + 1 <= 0) {
            throw new IllegalStateException("No more bits to read");
        }
        ByteBuffer byteBuffer = (ByteBuffer) this.f5459c;
        int i6 = byteBuffer.get(i5 / 8);
        if (i6 < 0) {
            i6 += 256;
        }
        int i7 = this.f5457a;
        int i8 = 8 - (i7 % 8);
        if (i4 <= i8) {
            jC = ((i6 << (i7 % 8)) & 255) >> ((i8 - i4) + (i7 % 8));
            this.f5457a = i7 + i4;
        } else {
            int i9 = i4 - i8;
            jC = c(i9) + (c(i8) << i9);
        }
        byteBuffer.position((int) Math.ceil(((double) this.f5457a) / ((double) 8)));
        return jC;
    }

    public void d(Typeface typeface) {
        int i4;
        WeakReference weakReference = (WeakReference) this.f5459c;
        C0503u c0503u = (C0503u) weakReference.get();
        if (c0503u == null) {
            return;
        }
        if (Build.VERSION.SDK_INT >= 28 && (i4 = this.f5457a) != -1) {
            typeface = Typeface.create(typeface, i4, (this.f5458b & 2) != 0);
        }
        c0503u.f5461a.post(new x0(5, weakReference, typeface));
    }

    public int e() {
        int i4 = 0;
        while (!b()) {
            i4++;
        }
        if (i4 > 0) {
            return ((1 << i4) - 1) + ((int) c(i4));
        }
        return 0;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r15v10 */
    /* JADX WARN: Type inference failed for: r15v6 */
    /* JADX WARN: Type inference failed for: r15v7, types: [int] */
    /* JADX WARN: Type inference failed for: r19v1 */
    /* JADX WARN: Type inference failed for: r19v2 */
    /* JADX WARN: Type inference failed for: r19v3 */
    /* JADX WARN: Type inference failed for: r2v0 */
    /* JADX WARN: Type inference failed for: r2v1, types: [boolean, int] */
    /* JADX WARN: Type inference failed for: r2v57 */
    public ArrayList f(List list, boolean z4) {
        Iterator it;
        String str;
        boolean z5;
        ?? r19;
        int length;
        byte[] bArr;
        byte[] bArr2;
        ArrayList arrayList = new ArrayList();
        ?? r22 = 1;
        if (z4) {
            this.f5458b = (this.f5458b + 1) & 15;
        }
        Iterator it2 = list.iterator();
        while (it2.hasNext()) {
            AbstractC0561d abstractC0561d = (AbstractC0561d) it2.next();
            ByteBuffer byteBufferAllocate = ByteBuffer.allocate(188);
            if (abstractC0561d instanceof C0617a) {
                J3.i.b(byteBufferAllocate);
                g(byteBufferAllocate, r22, abstractC0561d.f5873a, EnumC0558a.f5861b, this.f5458b);
                C0617a c0617a = (C0617a) abstractC0561d;
                byteBufferAllocate.put((byte) 0);
                byteBufferAllocate.put(c0617a.f6189c);
                switch (c0617a.f6192g) {
                    case 0:
                        length = 4;
                        break;
                    case 1:
                        Iterator it3 = c0617a.f6193h.f6263f.iterator();
                        length = 4;
                        while (it3.hasNext()) {
                            int i4 = length + 5;
                            EnumC0559b enumC0559b = ((q2.b) it3.next()).f6265a;
                            length = enumC0559b == EnumC0559b.f5867d ? length + 11 : enumC0559b == EnumC0559b.e ? length + 15 : i4;
                        }
                        break;
                    default:
                        length = c0617a.f6193h.f6261c.length() + c0617a.f6193h.f6262d.length() + 13;
                        break;
                }
                byteBufferAllocate.putShort((short) (((c0617a.f6191f ? 1 : 0) << 14) | 45056 | ((length + 9) & 1023)));
                byteBufferAllocate.putShort(c0617a.f6190d);
                byteBufferAllocate.put((byte) ((c0617a.e << r22) | 193));
                byteBufferAllocate.put((byte) 0);
                byteBufferAllocate.put((byte) 0);
                switch (c0617a.f6192g) {
                    case 0:
                        C0635a c0635a = c0617a.f6193h;
                        short s4 = c0635a.f6260b;
                        C0617a c0617a2 = c0635a.e;
                        int i5 = c0617a2 != null ? c0617a2.f5873a : 0;
                        byteBufferAllocate.putShort(s4);
                        byteBufferAllocate.putShort((short) (((short) i5) | 57344));
                        break;
                    case 1:
                        C0635a c0635a2 = c0617a.f6193h;
                        Number numberValueOf = c0635a2.f6264g;
                        if (numberValueOf == null) {
                            numberValueOf = Integer.valueOf(c0617a.f5873a);
                        }
                        int iIntValue = numberValueOf.intValue();
                        short s5 = 57344;
                        byteBufferAllocate.putShort((short) (iIntValue | 57344));
                        int i6 = 61440;
                        byteBufferAllocate.putShort((short) 61440);
                        for (q2.b bVar : c0635a2.f6263f) {
                            byteBufferAllocate.put(bVar.f6265a.f5869a);
                            int iOrdinal = bVar.f6265a.ordinal();
                            int i7 = i6;
                            short s6 = s5;
                            if (iOrdinal == 2) {
                                bArr = new byte[]{5, 4, 72, 69, 86, 67};
                            } else if (iOrdinal != 3) {
                                bArr2 = new byte[0];
                                byteBufferAllocate.putShort((short) (s6 | bVar.f6266b));
                                byteBufferAllocate.putShort((short) (i7 | bArr2.length));
                                byteBufferAllocate.put(bArr2);
                                i6 = i7;
                                s5 = s6;
                            } else {
                                bArr = new byte[]{5, 4, 79, 112, 117, 115, 127, 2, -128, 2};
                            }
                            bArr2 = bArr;
                            byteBufferAllocate.putShort((short) (s6 | bVar.f6266b));
                            byteBufferAllocate.putShort((short) (i7 | bArr2.length));
                            byteBufferAllocate.put(bArr2);
                            i6 = i7;
                            s5 = s6;
                        }
                        break;
                    default:
                        byteBufferAllocate.putShort((short) -255);
                        byteBufferAllocate.put((byte) -1);
                        byteBufferAllocate.putShort(c0617a.f6193h.f6260b);
                        byteBufferAllocate.put((byte) -4);
                        int length2 = c0617a.f6193h.f6261c.length() + c0617a.f6193h.f6262d.length() + 3;
                        byteBufferAllocate.putShort((short) ((length2 + 2) | 32768));
                        byteBufferAllocate.put((byte) 72);
                        byteBufferAllocate.put((byte) length2);
                        byteBufferAllocate.put(c0617a.f6193h.f6259a);
                        byteBufferAllocate.put((byte) c0617a.f6193h.f6262d.length());
                        String str2 = c0617a.f6193h.f6262d;
                        Charset charset = P3.a.f1492a;
                        byte[] bytes = str2.getBytes(charset);
                        J3.i.d(bytes, "getBytes(...)");
                        byteBufferAllocate.put(bytes);
                        byteBufferAllocate.put((byte) c0617a.f6193h.f6261c.length());
                        byte[] bytes2 = c0617a.f6193h.f6261c.getBytes(charset);
                        J3.i.d(bytes2, "getBytes(...)");
                        byteBufferAllocate.put(bytes2);
                        break;
                }
                int iPosition = byteBufferAllocate.position();
                byte[] bArrArray = byteBufferAllocate.array();
                J3.i.d(bArrArray, "array(...)");
                int i8 = -1;
                for (int iPosition2 = byteBufferAllocate.position(); iPosition2 < iPosition; iPosition2++) {
                    i8 = AbstractC0720a.f6771a[((i8 >> 24) ^ bArrArray[iPosition2]) & 255] ^ (i8 << 8);
                }
                byteBufferAllocate.putInt(i8);
                h(byteBufferAllocate, byteBufferAllocate.remaining(), false);
                arrayList.add(AbstractC0752b.l(byteBufferAllocate));
            } else {
                if (abstractC0561d instanceof C0563f) {
                    C0563f c0563f = (C0563f) abstractC0561d;
                    ByteBuffer byteBuffer = c0563f.e;
                    Long lValueOf = (((p2.b) this.f5459c).a() != abstractC0561d.f5873a || abstractC0561d.f5874b) ? Long.valueOf(AbstractC0752b.c()) : null;
                    boolean z6 = abstractC0561d.f5874b;
                    int i9 = (lValueOf != null ? 6 : 0) + 2 + 0;
                    ByteBuffer byteBufferAllocate2 = ByteBuffer.allocate(i9);
                    byteBufferAllocate2.put((byte) (i9 - r22));
                    byteBufferAllocate2.put((byte) (((z6 ? 1 : 0) << 6) | ((lValueOf != null ? r22 : 0) << 4)));
                    if (lValueOf != null) {
                        it = it2;
                        str = "array(...)";
                        byteBufferAllocate2.putInt((int) (((((((long) 27000000) * lValueOf.longValue()) / ((long) 1000000)) / 300) % ((long) Math.pow(2.0d, 33))) >> 1));
                        byteBufferAllocate2.putShort((short) (((r17 & 1) << 15) | 32256 | (511 & (r14 % r12))));
                    } else {
                        it = it2;
                        str = "array(...)";
                    }
                    byte[] bArrArray2 = byteBufferAllocate2.array();
                    J3.i.d(bArrArray2, str);
                    boolean z7 = byteBuffer.remaining() < ((byteBufferAllocate.remaining() + (-4)) - bArrArray2.length) + (-14);
                    g(byteBufferAllocate, true, abstractC0561d.f5873a, z7 ? EnumC0558a.f5861b : EnumC0558a.f5862c, this.f5457a);
                    byteBufferAllocate.put(bArrArray2);
                    byteBufferAllocate.putShort((short) 0);
                    byteBufferAllocate.put((byte) 1);
                    byteBufferAllocate.put(c0563f.f5879c.f5889a);
                    int i10 = c0563f.f5881f;
                    byteBufferAllocate.putShort((short) (i10 > 65535 ? 0 : i10 - 6));
                    byteBufferAllocate.put((byte) ((c0563f.f5882g << 6) | (c0563f.f5883h ? 1 : 0)));
                    byteBufferAllocate.put((byte) (c0563f.f5884i << 6));
                    byteBufferAllocate.put((byte) c0563f.f5885j);
                    byteBufferAllocate.put((byte) ((((byte) 2) << 4) | ((int) ((((((((long) 27000000) * c0563f.f5880d) / ((long) 1000000)) / ((long) 300)) % ((long) Math.pow(2.0d, 33))) >> 29) & 14)) | 1));
                    byteBufferAllocate.putShort((short) (((r8 >> 14) & 65534) | 1));
                    byteBufferAllocate.putShort((short) (((r8 << 1) & 65534) | 1));
                    if (z7) {
                        byteBufferAllocate.put(byteBuffer);
                        h(byteBufferAllocate, byteBufferAllocate.remaining(), true);
                        arrayList.add(AbstractC0752b.l(byteBufferAllocate));
                        this.f5457a = (this.f5457a + 1) & 15;
                    } else {
                        EnumC0558a enumC0558a = EnumC0558a.f5861b;
                        boolean z8 = true;
                        while (byteBuffer.hasRemaining()) {
                            boolean z9 = byteBuffer.remaining() < byteBufferAllocate.remaining() + (-4);
                            if (z8) {
                                z5 = false;
                            } else {
                                if (z9) {
                                    enumC0558a = EnumC0558a.f5862c;
                                }
                                z5 = false;
                                g(byteBufferAllocate, false, abstractC0561d.f5873a, enumC0558a, this.f5457a);
                            }
                            if (z9) {
                                h(byteBufferAllocate, byteBufferAllocate.remaining() - byteBuffer.remaining(), true);
                            }
                            int iMin = Math.min(byteBuffer.remaining(), byteBufferAllocate.remaining());
                            byteBufferAllocate.put(byteBuffer.array(), byteBuffer.position(), iMin);
                            byteBuffer.position(byteBuffer.position() + iMin);
                            arrayList.add(AbstractC0752b.l(byteBufferAllocate));
                            this.f5457a = (this.f5457a + 1) & 15;
                            byteBufferAllocate = ByteBuffer.allocate(188);
                            z8 = z5;
                        }
                    }
                    r19 = 1;
                }
                r22 = r19;
                it2 = it;
            }
            r19 = r22;
            it = it2;
            r22 = r19;
            it2 = it;
        }
        return arrayList;
    }

    public C0502t(p2.b bVar) {
        J3.i.e(bVar, "psiManager");
        this.f5459c = bVar;
    }

    public C0502t(C0503u c0503u, int i4, int i5) {
        this.f5459c = new WeakReference(c0503u);
        this.f5457a = i4;
        this.f5458b = i5;
    }
}
