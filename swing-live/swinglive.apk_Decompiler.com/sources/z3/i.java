package Z3;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.EOFException;
import java.nio.ByteBuffer;
import x3.AbstractC0726f;

/* JADX INFO: loaded from: classes.dex */
public abstract class i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final char[] f2626a = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    public static final void a(long j4, long j5, long j6) {
        if (j5 < 0 || j6 > j4) {
            throw new IndexOutOfBoundsException("startIndex (" + j5 + ") and endIndex (" + j6 + ") are not within the range [0..size(" + j4 + "))");
        }
        if (j5 <= j6) {
            return;
        }
        throw new IllegalArgumentException("startIndex (" + j5 + ") > endIndex (" + j6 + ')');
    }

    public static final boolean b(f fVar) {
        J3.i.e(fVar, "<this>");
        return fVar.b() == 0;
    }

    public static final int c(h hVar, ByteBuffer byteBuffer) throws EOFException {
        J3.i.e(hVar, "<this>");
        J3.i.e(byteBuffer, "sink");
        if (hVar.v().f2603c == 0) {
            hVar.k(8192L);
            if (hVar.v().f2603c == 0) {
                return -1;
            }
        }
        a aVarV = hVar.v();
        J3.i.e(aVarV, "<this>");
        if (aVarV.w()) {
            return -1;
        }
        if (aVarV.w()) {
            throw new IllegalArgumentException("Buffer is empty");
        }
        f fVar = aVarV.f2601a;
        J3.i.b(fVar);
        int i4 = fVar.f2615b;
        int iMin = Math.min(byteBuffer.remaining(), fVar.f2616c - i4);
        byteBuffer.put(fVar.f2614a, i4, iMin);
        if (iMin == 0) {
            return iMin;
        }
        if (iMin < 0) {
            throw new IllegalStateException("Returned negative read bytes count");
        }
        if (iMin > fVar.b()) {
            throw new IllegalStateException("Returned too many bytes");
        }
        aVarV.f(iMin);
        return iMin;
    }

    public static final byte[] d(h hVar, int i4) {
        J3.i.e(hVar, "<this>");
        long j4 = i4;
        if (j4 >= 0) {
            return e(hVar, i4);
        }
        throw new IllegalArgumentException(("byteCount (" + j4 + ") < 0").toString());
    }

    public static final byte[] e(h hVar, int i4) throws EOFException {
        if (i4 == -1) {
            for (long j4 = 2147483647L; hVar.v().f2603c < 2147483647L && hVar.k(j4); j4 *= (long) 2) {
            }
            if (hVar.v().f2603c >= 2147483647L) {
                throw new IllegalStateException(("Can't create an array of size " + hVar.v().f2603c).toString());
            }
            i4 = (int) hVar.v().f2603c;
        } else {
            hVar.t(i4);
        }
        byte[] bArr = new byte[i4];
        f(hVar.v(), bArr, 0, i4);
        return bArr;
    }

    public static final void f(a aVar, byte[] bArr, int i4, int i5) throws EOFException {
        int i6;
        J3.i.e(aVar, "<this>");
        J3.i.e(bArr, "sink");
        a(bArr.length, i4, i5);
        for (int i7 = i4; i7 < i5; i7 += i6) {
            aVar.getClass();
            J3.i.e(bArr, "sink");
            a(bArr.length, i7, i5);
            f fVar = aVar.f2601a;
            if (fVar == null) {
                i6 = -1;
            } else {
                int iMin = Math.min(i5 - i7, fVar.b());
                int i8 = (i7 + iMin) - i7;
                int i9 = fVar.f2615b;
                AbstractC0726f.d0(fVar.f2614a, i7, bArr, i9, i9 + i8);
                fVar.f2615b += i8;
                aVar.f2603c -= (long) iMin;
                if (b(fVar)) {
                    aVar.c();
                }
                i6 = iMin;
            }
            if (i6 == -1) {
                throw new EOFException("Source exhausted before reading " + (i5 - i4) + " bytes. Only " + i6 + " bytes were read.");
            }
        }
    }

    public static final void g(a aVar, ByteBuffer byteBuffer) {
        J3.i.e(byteBuffer, "source");
        int iRemaining = byteBuffer.remaining();
        while (iRemaining > 0) {
            f fVarH = aVar.h(1);
            int i4 = fVarH.f2616c;
            byte[] bArr = fVarH.f2614a;
            int iMin = Math.min(iRemaining, bArr.length - i4);
            byteBuffer.get(bArr, i4, iMin);
            iRemaining -= iMin;
            if (iMin == 1) {
                fVarH.f2616c += iMin;
                aVar.f2603c += (long) iMin;
            } else {
                if (iMin < 0 || iMin > fVarH.a()) {
                    StringBuilder sbI = S.i("Invalid number of bytes written: ", iMin, ". Should be in 0..");
                    sbI.append(fVarH.a());
                    throw new IllegalStateException(sbI.toString().toString());
                }
                if (iMin != 0) {
                    fVarH.f2616c += iMin;
                    aVar.f2603c += (long) iMin;
                } else if (b(fVarH)) {
                    aVar.d();
                }
            }
        }
    }
}
