package D2;

import android.util.Log;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class z implements D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final O2.f f273a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f274b = new HashMap();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final HashMap f275c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final A f276d;

    public z(O2.f fVar) {
        HashMap map = new HashMap();
        this.f275c = map;
        this.f276d = new A();
        this.f273a = fVar;
        F f4 = J.f166a;
        I i4 = new I();
        i4.f165a = false;
        I i5 = new I[]{i4}[0];
        i5.getClass();
        map.put(4294967556L, i5);
    }

    /* JADX WARN: Removed duplicated region for block: B:138:0x02df  */
    /* JADX WARN: Removed duplicated region for block: B:139:0x02ee  */
    @Override // D2.D
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void a(final android.view.KeyEvent r32, D2.B r33) {
        /*
            Method dump skipped, instruction units count: 899
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.z.a(android.view.KeyEvent, D2.B):void");
    }

    public final void b(w wVar, final B b5) {
        long j4;
        long j5;
        byte[] bytes = null;
        O2.e eVar = b5 == null ? null : new O2.e() { // from class: D2.x
            @Override // O2.e
            public final void a(ByteBuffer byteBuffer) {
                Boolean boolValueOf = Boolean.FALSE;
                if (byteBuffer != null) {
                    byteBuffer.rewind();
                    if (byteBuffer.capacity() != 0) {
                        boolValueOf = Boolean.valueOf(byteBuffer.get() != 0);
                    }
                } else {
                    Log.w("KeyEmbedderResponder", "A null reply was received when sending a key event to the framework.");
                }
                b5.a(boolValueOf.booleanValue());
            }
        };
        try {
            String str = wVar.f267g;
            if (str != null) {
                bytes = str.getBytes("UTF-8");
            }
            int length = bytes == null ? 0 : bytes.length;
            ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(length + 56);
            byteBufferAllocateDirect.order(ByteOrder.LITTLE_ENDIAN);
            byteBufferAllocateDirect.putLong(length);
            byteBufferAllocateDirect.putLong(wVar.f262a);
            int i4 = wVar.f263b;
            if (i4 == 1) {
                j4 = 0;
            } else if (i4 == 2) {
                j4 = 1;
            } else {
                if (i4 != 3) {
                    throw null;
                }
                j4 = 2;
            }
            byteBufferAllocateDirect.putLong(j4);
            byteBufferAllocateDirect.putLong(wVar.f264c);
            byteBufferAllocateDirect.putLong(wVar.f265d);
            byteBufferAllocateDirect.putLong(wVar.e ? 1L : 0L);
            int i5 = wVar.f266f;
            if (i5 == 1) {
                j5 = 0;
            } else if (i5 == 2) {
                j5 = 1;
            } else if (i5 == 3) {
                j5 = 2;
            } else if (i5 == 4) {
                j5 = 3;
            } else {
                if (i5 != 5) {
                    throw null;
                }
                j5 = 4;
            }
            byteBufferAllocateDirect.putLong(j5);
            if (bytes != null) {
                byteBufferAllocateDirect.put(bytes);
            }
            this.f273a.s("flutter/keydata", byteBufferAllocateDirect, eVar);
        } catch (UnsupportedEncodingException unused) {
            throw new AssertionError("UTF-8 not supported");
        }
    }

    public final void c(boolean z4, Long l2, Long l4, long j4) {
        w wVar = new w();
        wVar.f262a = j4;
        wVar.f263b = z4 ? 1 : 2;
        wVar.f265d = l2.longValue();
        wVar.f264c = l4.longValue();
        wVar.f267g = null;
        wVar.e = true;
        wVar.f266f = 1;
        if (l4.longValue() != 0 && l2.longValue() != 0) {
            if (!z4) {
                l2 = null;
            }
            d(l4, l2);
        }
        b(wVar, null);
    }

    public final void d(Long l2, Long l4) {
        HashMap map = this.f274b;
        if (l4 != null) {
            if (((Long) map.put(l2, l4)) != null) {
                throw new AssertionError("The key was not empty");
            }
        } else if (((Long) map.remove(l2)) == null) {
            throw new AssertionError("The key was empty");
        }
    }
}
