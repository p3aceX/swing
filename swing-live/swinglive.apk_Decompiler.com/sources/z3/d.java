package Z3;

import java.io.EOFException;

/* JADX INFO: loaded from: classes.dex */
public final class d implements h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final b f2609a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f2610b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final a f2611c = new a();

    public d(b bVar) {
        this.f2609a = bVar;
    }

    @Override // java.lang.AutoCloseable
    public final void close() throws EOFException {
        if (this.f2610b) {
            return;
        }
        this.f2610b = true;
        this.f2609a.e = true;
        a aVar = this.f2611c;
        aVar.f(aVar.f2603c);
    }

    @Override // Z3.h
    public final boolean k(long j4) {
        a aVar;
        if (this.f2610b) {
            throw new IllegalStateException("Source is closed.");
        }
        if (j4 < 0) {
            throw new IllegalArgumentException(("byteCount: " + j4).toString());
        }
        do {
            aVar = this.f2611c;
            if (aVar.f2603c >= j4) {
                return true;
            }
        } while (this.f2609a.m(aVar, 8192L) != -1);
        return false;
    }

    @Override // Z3.c
    public final long m(a aVar, long j4) {
        J3.i.e(aVar, "sink");
        if (this.f2610b) {
            throw new IllegalStateException("Source is closed.");
        }
        if (j4 < 0) {
            throw new IllegalArgumentException(("byteCount: " + j4).toString());
        }
        a aVar2 = this.f2611c;
        if (aVar2.f2603c == 0 && this.f2609a.m(aVar2, 8192L) == -1) {
            return -1L;
        }
        return aVar2.m(aVar, Math.min(j4, aVar2.f2603c));
    }

    @Override // Z3.h
    public final byte readByte() throws EOFException {
        t(1L);
        return this.f2611c.readByte();
    }

    @Override // Z3.h
    public final int readInt() throws EOFException {
        t(4L);
        return this.f2611c.readInt();
    }

    @Override // Z3.h
    public final long readLong() throws EOFException {
        t(8L);
        return this.f2611c.readLong();
    }

    @Override // Z3.h
    public final void t(long j4) throws EOFException {
        if (k(j4)) {
            return;
        }
        throw new EOFException("Source doesn't contain required number of bytes (" + j4 + ").");
    }

    public final String toString() {
        return "buffered(" + this.f2609a + ')';
    }

    @Override // Z3.h
    public final a v() {
        return this.f2611c;
    }

    @Override // Z3.h
    public final boolean w() {
        if (this.f2610b) {
            throw new IllegalStateException("Source is closed.");
        }
        a aVar = this.f2611c;
        return aVar.w() && this.f2609a.m(aVar, 8192L) == -1;
    }
}
