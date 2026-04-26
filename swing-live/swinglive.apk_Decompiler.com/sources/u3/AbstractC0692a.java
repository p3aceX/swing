package u3;

import I3.l;
import J3.i;
import Z3.f;
import Z3.h;
import java.io.EOFException;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: u3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0692a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Z3.a f6665a = new Z3.a();

    public static final long a(h hVar) {
        i.e(hVar, "<this>");
        return hVar.v().f2603c;
    }

    public static final void b(Z3.a aVar, l lVar) throws EOFException {
        i.e(aVar, "<this>");
        i.e(lVar, "block");
        if (aVar.w()) {
            throw new IllegalArgumentException("Buffer is empty");
        }
        f fVar = aVar.f2601a;
        i.b(fVar);
        int i4 = fVar.f2615b;
        ByteBuffer byteBufferWrap = ByteBuffer.wrap(fVar.f2614a, i4, fVar.f2616c - i4);
        i.b(byteBufferWrap);
        lVar.invoke(byteBufferWrap);
        int iPosition = byteBufferWrap.position() - i4;
        if (iPosition != 0) {
            if (iPosition < 0) {
                throw new IllegalStateException("Returned negative read bytes count");
            }
            if (iPosition > fVar.b()) {
                throw new IllegalStateException("Returned too many bytes");
            }
            aVar.f(iPosition);
        }
    }

    public static final void c(Z3.a aVar, byte[] bArr, int i4, int i5) {
        i.e(aVar, "<this>");
        i.e(bArr, "buffer");
        aVar.l(bArr, i4, i5 + i4);
    }

    public static final void d(Z3.a aVar, h hVar) {
        i.e(aVar, "<this>");
        i.e(hVar, "packet");
        while (hVar.m(aVar, 8192L) != -1) {
        }
    }
}
