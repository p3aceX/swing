package Q3;

import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class W implements Runnable, Comparable, Q {
    private volatile Object _heap;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f1603a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1604b = -1;

    public W(long j4) {
        this.f1603a = j4;
    }

    @Override // Q3.Q
    public final void a() {
        synchronized (this) {
            try {
                Object obj = this._heap;
                C0779j c0779j = F.f1577b;
                if (obj == c0779j) {
                    return;
                }
                X x4 = obj instanceof X ? (X) obj : null;
                if (x4 != null) {
                    synchronized (x4) {
                        Object obj2 = this._heap;
                        if ((obj2 instanceof V3.v ? (V3.v) obj2 : null) != null) {
                            x4.b(this.f1604b);
                        }
                    }
                }
                this._heap = c0779j;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final int b(long j4, X x4, Y y4) {
        synchronized (this) {
            if (this._heap == F.f1577b) {
                return 2;
            }
            synchronized (x4) {
                try {
                    W[] wArr = x4.f2252a;
                    W w4 = wArr != null ? wArr[0] : null;
                    AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = Y.f1606m;
                    y4.getClass();
                    if (Y.f1608o.get(y4) == 1) {
                        return 1;
                    }
                    if (w4 == null) {
                        x4.f1605c = j4;
                    } else {
                        long j5 = w4.f1603a;
                        if (j5 - j4 < 0) {
                            j4 = j5;
                        }
                        if (j4 - x4.f1605c > 0) {
                            x4.f1605c = j4;
                        }
                    }
                    long j6 = this.f1603a;
                    long j7 = x4.f1605c;
                    if (j6 - j7 < 0) {
                        this.f1603a = j7;
                    }
                    x4.a(this);
                    return 0;
                } catch (Throwable th) {
                    throw th;
                }
            }
        }
    }

    @Override // java.lang.Comparable
    public final int compareTo(Object obj) {
        long j4 = this.f1603a - ((W) obj).f1603a;
        if (j4 > 0) {
            return 1;
        }
        return j4 < 0 ? -1 : 0;
    }

    public final void d(X x4) {
        if (this._heap == F.f1577b) {
            throw new IllegalArgumentException("Failed requirement.");
        }
        this._heap = x4;
    }

    public String toString() {
        return "Delayed[nanos=" + this.f1603a + ']';
    }
}
