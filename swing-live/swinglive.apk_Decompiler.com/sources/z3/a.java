package Z3;

import java.io.EOFException;
import java.io.Flushable;
import x3.AbstractC0726f;

/* JADX INFO: loaded from: classes.dex */
public final class a implements h, AutoCloseable, Flushable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public f f2601a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public f f2602b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public long f2603c;

    public final d a() {
        return new d(new b(this));
    }

    public final short b() throws EOFException {
        f fVar = this.f2601a;
        if (fVar == null) {
            g(2L);
            throw null;
        }
        int iB = fVar.b();
        if (iB < 2) {
            t(2L);
            if (iB != 0) {
                return (short) (((readByte() & 255) << 8) | (readByte() & 255));
            }
            c();
            return b();
        }
        int i4 = fVar.f2615b;
        byte[] bArr = fVar.f2614a;
        short s4 = (short) ((bArr[i4 + 1] & 255) | ((bArr[i4] & 255) << 8));
        fVar.f2615b = i4 + 2;
        this.f2603c -= 2;
        if (iB == 2) {
            c();
        }
        return s4;
    }

    public final void c() {
        f fVar = this.f2601a;
        J3.i.b(fVar);
        f fVar2 = fVar.f2618f;
        this.f2601a = fVar2;
        if (fVar2 == null) {
            this.f2602b = null;
        } else {
            fVar2.f2619g = null;
        }
        fVar.f2618f = null;
        g.a(fVar);
    }

    public final /* synthetic */ void d() {
        f fVar = this.f2602b;
        J3.i.b(fVar);
        f fVar2 = fVar.f2619g;
        this.f2602b = fVar2;
        if (fVar2 == null) {
            this.f2601a = null;
        } else {
            fVar2.f2618f = null;
        }
        fVar.f2619g = null;
        g.a(fVar);
    }

    public final void f(long j4) throws EOFException {
        if (j4 < 0) {
            throw new IllegalArgumentException(("byteCount (" + j4 + ") < 0").toString());
        }
        long j5 = j4;
        while (j5 > 0) {
            f fVar = this.f2601a;
            if (fVar == null) {
                throw new EOFException("Buffer exhausted before skipping " + j4 + " bytes.");
            }
            int iMin = (int) Math.min(j5, fVar.f2616c - fVar.f2615b);
            long j6 = iMin;
            this.f2603c -= j6;
            j5 -= j6;
            int i4 = fVar.f2615b + iMin;
            fVar.f2615b = i4;
            if (i4 == fVar.f2616c) {
                c();
            }
        }
    }

    public final void g(long j4) throws EOFException {
        throw new EOFException("Buffer doesn't contain required number of bytes (size: " + this.f2603c + ", required: " + j4 + ')');
    }

    public final /* synthetic */ f h(int i4) {
        if (i4 < 1 || i4 > 8192) {
            throw new IllegalArgumentException(B1.a.l("unexpected capacity (", i4, "), should be in range [1, 8192]").toString());
        }
        f fVar = this.f2602b;
        if (fVar == null) {
            f fVarB = g.b();
            this.f2601a = fVarB;
            this.f2602b = fVarB;
            return fVarB;
        }
        if (fVar.f2616c + i4 <= 8192 && fVar.e) {
            return fVar;
        }
        f fVarB2 = g.b();
        fVar.d(fVarB2);
        this.f2602b = fVarB2;
        return fVarB2;
    }

    public final void i(a aVar, long j4) {
        f fVarB;
        J3.i.e(aVar, "source");
        if (aVar == this) {
            throw new IllegalArgumentException("source == this");
        }
        long j5 = aVar.f2603c;
        if (0 > j5 || j5 < j4 || j4 < 0) {
            throw new IllegalArgumentException("offset (0) and byteCount (" + j4 + ") are not within the range [0..size(" + j5 + "))");
        }
        while (j4 > 0) {
            J3.i.b(aVar.f2601a);
            int i4 = 0;
            if (j4 < r0.b()) {
                f fVar = this.f2602b;
                if (fVar != null && fVar.e) {
                    long j6 = ((long) fVar.f2616c) + j4;
                    i iVar = fVar.f2617d;
                    if (j6 - ((long) ((iVar == null || ((e) iVar).f2613b <= 0) ? fVar.f2615b : 0)) <= 8192) {
                        f fVar2 = aVar.f2601a;
                        J3.i.b(fVar2);
                        fVar2.f(fVar, (int) j4);
                        aVar.f2603c -= j4;
                        this.f2603c += j4;
                        return;
                    }
                }
                f fVar3 = aVar.f2601a;
                J3.i.b(fVar3);
                int i5 = (int) j4;
                if (i5 <= 0 || i5 > fVar3.f2616c - fVar3.f2615b) {
                    throw new IllegalArgumentException("byteCount out of range");
                }
                if (i5 >= 1024) {
                    fVarB = fVar3.e();
                } else {
                    fVarB = g.b();
                    int i6 = fVar3.f2615b;
                    AbstractC0726f.d0(fVar3.f2614a, 0, fVarB.f2614a, i6, i6 + i5);
                }
                fVarB.f2616c = fVarB.f2615b + i5;
                fVar3.f2615b += i5;
                f fVar4 = fVar3.f2619g;
                if (fVar4 != null) {
                    fVar4.d(fVarB);
                } else {
                    fVarB.f2618f = fVar3;
                    fVar3.f2619g = fVarB;
                }
                aVar.f2601a = fVarB;
            }
            f fVar5 = aVar.f2601a;
            J3.i.b(fVar5);
            long jB = fVar5.b();
            f fVarC = fVar5.c();
            aVar.f2601a = fVarC;
            if (fVarC == null) {
                aVar.f2602b = null;
            }
            if (this.f2601a == null) {
                this.f2601a = fVar5;
                this.f2602b = fVar5;
            } else {
                f fVar6 = this.f2602b;
                J3.i.b(fVar6);
                fVar6.d(fVar5);
                f fVar7 = fVar5.f2619g;
                if (fVar7 == null) {
                    throw new IllegalStateException("cannot compact");
                }
                if (fVar7.e) {
                    int i7 = fVar5.f2616c - fVar5.f2615b;
                    J3.i.b(fVar7);
                    int i8 = 8192 - fVar7.f2616c;
                    f fVar8 = fVar5.f2619g;
                    J3.i.b(fVar8);
                    i iVar2 = fVar8.f2617d;
                    if (iVar2 == null || ((e) iVar2).f2613b <= 0) {
                        f fVar9 = fVar5.f2619g;
                        J3.i.b(fVar9);
                        i4 = fVar9.f2615b;
                    }
                    if (i7 <= i8 + i4) {
                        f fVar10 = fVar5.f2619g;
                        J3.i.b(fVar10);
                        fVar5.f(fVar10, i7);
                        if (fVar5.c() != null) {
                            throw new IllegalStateException("Check failed.");
                        }
                        g.a(fVar5);
                        fVar5 = fVar10;
                    }
                }
                this.f2602b = fVar5;
                if (fVar5.f2619g == null) {
                    this.f2601a = fVar5;
                }
            }
            aVar.f2603c -= jB;
            this.f2603c += jB;
            j4 -= jB;
        }
    }

    @Override // Z3.h
    public final boolean k(long j4) {
        if (j4 >= 0) {
            return this.f2603c >= j4;
        }
        throw new IllegalArgumentException(("byteCount: " + j4 + " < 0").toString());
    }

    public final void l(byte[] bArr, int i4, int i5) {
        J3.i.e(bArr, "source");
        i.a(bArr.length, i4, i5);
        int i6 = i4;
        while (i6 < i5) {
            f fVarH = h(1);
            int iMin = Math.min(i5 - i6, fVarH.a()) + i6;
            AbstractC0726f.d0(bArr, fVarH.f2616c, fVarH.f2614a, i6, iMin);
            fVarH.f2616c = (iMin - i6) + fVarH.f2616c;
            i6 = iMin;
        }
        this.f2603c += (long) (i5 - i4);
    }

    @Override // Z3.c
    public final long m(a aVar, long j4) {
        J3.i.e(aVar, "sink");
        if (j4 < 0) {
            throw new IllegalArgumentException(("byteCount (" + j4 + ") < 0").toString());
        }
        long j5 = this.f2603c;
        if (j5 == 0) {
            return -1L;
        }
        if (j4 > j5) {
            j4 = j5;
        }
        aVar.i(this, j4);
        return j4;
    }

    public final void n(byte b5) {
        f fVarH = h(1);
        int i4 = fVarH.f2616c;
        fVarH.f2616c = i4 + 1;
        fVarH.f2614a[i4] = b5;
        this.f2603c++;
    }

    public final void o(short s4) {
        f fVarH = h(2);
        int i4 = fVarH.f2616c;
        byte[] bArr = fVarH.f2614a;
        bArr[i4] = (byte) ((s4 >>> 8) & 255);
        bArr[i4 + 1] = (byte) (s4 & 255);
        fVarH.f2616c = i4 + 2;
        this.f2603c += 2;
    }

    @Override // Z3.h
    public final byte readByte() throws EOFException {
        f fVar = this.f2601a;
        if (fVar == null) {
            g(1L);
            throw null;
        }
        int iB = fVar.b();
        if (iB == 0) {
            c();
            return readByte();
        }
        int i4 = fVar.f2615b;
        fVar.f2615b = i4 + 1;
        byte b5 = fVar.f2614a[i4];
        this.f2603c--;
        if (iB == 1) {
            c();
        }
        return b5;
    }

    @Override // Z3.h
    public final int readInt() throws EOFException {
        f fVar = this.f2601a;
        if (fVar == null) {
            g(4L);
            throw null;
        }
        int iB = fVar.b();
        if (iB < 4) {
            t(4L);
            if (iB != 0) {
                return (b() << 16) | (b() & 65535);
            }
            c();
            return readInt();
        }
        int i4 = fVar.f2615b;
        byte[] bArr = fVar.f2614a;
        int i5 = ((bArr[i4 + 1] & 255) << 16) | ((bArr[i4] & 255) << 24) | ((bArr[i4 + 2] & 255) << 8) | (bArr[i4 + 3] & 255);
        fVar.f2615b = i4 + 4;
        this.f2603c -= 4;
        if (iB == 4) {
            c();
        }
        return i5;
    }

    @Override // Z3.h
    public final long readLong() throws EOFException {
        f fVar = this.f2601a;
        if (fVar == null) {
            g(8L);
            throw null;
        }
        int iB = fVar.b();
        if (iB < 8) {
            t(8L);
            if (iB != 0) {
                return (((long) readInt()) << 32) | (((long) readInt()) & 4294967295L);
            }
            c();
            return readLong();
        }
        int i4 = fVar.f2615b;
        byte[] bArr = fVar.f2614a;
        long j4 = (((long) bArr[i4 + 7]) & 255) | ((((long) bArr[i4]) & 255) << 56) | ((((long) bArr[i4 + 1]) & 255) << 48) | ((((long) bArr[i4 + 2]) & 255) << 40) | ((((long) bArr[i4 + 3]) & 255) << 32) | ((((long) bArr[i4 + 4]) & 255) << 24) | ((((long) bArr[i4 + 5]) & 255) << 16) | ((((long) bArr[i4 + 6]) & 255) << 8);
        fVar.f2615b = i4 + 8;
        this.f2603c -= 8;
        if (iB == 8) {
            c();
        }
        return j4;
    }

    @Override // Z3.h
    public final void t(long j4) throws EOFException {
        if (j4 < 0) {
            throw new IllegalArgumentException(("byteCount: " + j4).toString());
        }
        if (this.f2603c >= j4) {
            return;
        }
        throw new EOFException("Buffer doesn't contain required number of bytes (size: " + this.f2603c + ", required: " + j4 + ')');
    }

    public final String toString() {
        long j4 = this.f2603c;
        if (j4 == 0) {
            return "Buffer(size=0)";
        }
        long j5 = 64;
        int iMin = (int) Math.min(j5, j4);
        StringBuilder sb = new StringBuilder((iMin * 2) + (this.f2603c > j5 ? 1 : 0));
        int i4 = 0;
        for (f fVar = this.f2601a; fVar != null; fVar = fVar.f2618f) {
            int i5 = 0;
            while (i4 < iMin && i5 < fVar.b()) {
                int i6 = i5 + 1;
                byte b5 = fVar.f2614a[fVar.f2615b + i5];
                i4++;
                char[] cArr = i.f2626a;
                sb.append(cArr[(b5 >> 4) & 15]);
                sb.append(cArr[b5 & 15]);
                i5 = i6;
            }
        }
        if (this.f2603c > j5) {
            sb.append((char) 8230);
        }
        return "Buffer(size=" + this.f2603c + " hex=" + ((Object) sb) + ')';
    }

    @Override // Z3.h
    public final boolean w() {
        return this.f2603c == 0;
    }

    @Override // java.lang.AutoCloseable
    public final void close() {
    }

    @Override // java.io.Flushable
    public final void flush() {
    }

    @Override // Z3.h
    public final a v() {
        return this;
    }
}
