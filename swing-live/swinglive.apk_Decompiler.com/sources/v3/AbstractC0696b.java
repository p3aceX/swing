package v3;

import J3.i;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicLongFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceArray;

/* JADX INFO: renamed from: v3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0696b implements InterfaceC0697c {
    public static final /* synthetic */ AtomicLongFieldUpdater e = AtomicLongFieldUpdater.newUpdater(AbstractC0696b.class, "top");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6674a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6675b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AtomicReferenceArray f6676c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int[] f6677d;
    private volatile /* synthetic */ long top;

    public AbstractC0696b(int i4) {
        if (i4 <= 0) {
            throw new IllegalArgumentException(S.d(i4, "capacity should be positive but it is ").toString());
        }
        if (i4 > 536870911) {
            throw new IllegalArgumentException(S.d(i4, "capacity should be less or equal to 536870911 but it is ").toString());
        }
        this.top = 0L;
        int iHighestOneBit = Integer.highestOneBit((i4 * 4) - 1) * 2;
        this.f6674a = iHighestOneBit;
        this.f6675b = Integer.numberOfLeadingZeros(iHighestOneBit) + 1;
        int i5 = iHighestOneBit + 1;
        this.f6676c = new AtomicReferenceArray(i5);
        this.f6677d = new int[i5];
    }

    public final Object a() {
        Object objF = f();
        return objF != null ? b(objF) : c();
    }

    public abstract ByteBuffer c();

    public final void d(Object obj) {
        long j4;
        long j5;
        i.e(obj, "instance");
        g(obj);
        int iIdentityHashCode = ((System.identityHashCode(obj) * (-1640531527)) >>> this.f6675b) + 1;
        for (int i4 = 0; i4 < 8; i4++) {
            AtomicReferenceArray atomicReferenceArray = this.f6676c;
            while (!atomicReferenceArray.compareAndSet(iIdentityHashCode, null, obj)) {
                if (atomicReferenceArray.get(iIdentityHashCode) != null) {
                    iIdentityHashCode--;
                    if (iIdentityHashCode == 0) {
                        iIdentityHashCode = this.f6674a;
                    }
                }
            }
            if (iIdentityHashCode <= 0) {
                throw new IllegalArgumentException("index should be positive");
            }
            do {
                j4 = this.top;
                j5 = ((((j4 >> 32) & 4294967295L) + 1) << 32) | ((long) iIdentityHashCode);
                this.f6677d[iIdentityHashCode] = (int) (4294967295L & j4);
            } while (!e.compareAndSet(this, j4, j5));
            return;
        }
    }

    public final Object f() {
        long j4;
        int i4;
        AbstractC0696b abstractC0696b;
        long j5;
        do {
            j4 = this.top;
            if (j4 != 0) {
                j5 = ((j4 >> 32) & 4294967295L) + 1;
                i4 = (int) (4294967295L & j4);
                if (i4 != 0) {
                    abstractC0696b = this;
                }
            }
            i4 = 0;
            abstractC0696b = this;
            break;
        } while (!e.compareAndSet(abstractC0696b, j4, (j5 << 32) | ((long) this.f6677d[i4])));
        if (i4 == 0) {
            return null;
        }
        return abstractC0696b.f6676c.getAndSet(i4, null);
    }

    public void g(Object obj) {
        i.e(obj, "instance");
    }

    public Object b(Object obj) {
        return obj;
    }
}
