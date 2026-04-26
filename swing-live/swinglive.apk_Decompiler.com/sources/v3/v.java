package V3;

import Q3.W;
import Q3.X;
import java.util.Arrays;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public class v {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2251b = AtomicIntegerFieldUpdater.newUpdater(v.class, "_size$volatile");
    private volatile /* synthetic */ int _size$volatile;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public W[] f2252a;

    public final void a(W w4) {
        w4.d((X) this);
        W[] wArr = this.f2252a;
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2251b;
        if (wArr == null) {
            wArr = new W[4];
            this.f2252a = wArr;
        } else if (atomicIntegerFieldUpdater.get(this) >= wArr.length) {
            Object[] objArrCopyOf = Arrays.copyOf(wArr, atomicIntegerFieldUpdater.get(this) * 2);
            J3.i.d(objArrCopyOf, "copyOf(...)");
            wArr = (W[]) objArrCopyOf;
            this.f2252a = wArr;
        }
        int i4 = atomicIntegerFieldUpdater.get(this);
        atomicIntegerFieldUpdater.set(this, i4 + 1);
        wArr[i4] = w4;
        w4.f1604b = i4;
        c(i4);
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x0063  */
    /* JADX WARN: Removed duplicated region for block: B:26:? A[SYNTHETIC] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final Q3.W b(int r9) {
        /*
            r8 = this;
            Q3.W[] r0 = r8.f2252a
            J3.i.b(r0)
            java.util.concurrent.atomic.AtomicIntegerFieldUpdater r1 = V3.v.f2251b
            int r2 = r1.get(r8)
            r3 = -1
            int r2 = r2 + r3
            r1.set(r8, r2)
            int r2 = r1.get(r8)
            if (r9 >= r2) goto L7a
            int r2 = r1.get(r8)
            r8.d(r9, r2)
            int r2 = r9 + (-1)
            int r2 = r2 / 2
            if (r9 <= 0) goto L3a
            r4 = r0[r9]
            J3.i.b(r4)
            r5 = r0[r2]
            J3.i.b(r5)
            int r4 = r4.compareTo(r5)
            if (r4 >= 0) goto L3a
            r8.d(r9, r2)
            r8.c(r2)
            goto L7a
        L3a:
            int r2 = r9 * 2
            int r4 = r2 + 1
            int r5 = r1.get(r8)
            if (r4 < r5) goto L45
            goto L7a
        L45:
            Q3.W[] r5 = r8.f2252a
            J3.i.b(r5)
            int r2 = r2 + 2
            int r6 = r1.get(r8)
            if (r2 >= r6) goto L63
            r6 = r5[r2]
            J3.i.b(r6)
            r7 = r5[r4]
            J3.i.b(r7)
            int r6 = r6.compareTo(r7)
            if (r6 >= 0) goto L63
            goto L64
        L63:
            r2 = r4
        L64:
            r4 = r5[r9]
            J3.i.b(r4)
            r5 = r5[r2]
            J3.i.b(r5)
            int r4 = r4.compareTo(r5)
            if (r4 > 0) goto L75
            goto L7a
        L75:
            r8.d(r9, r2)
            r9 = r2
            goto L3a
        L7a:
            int r9 = r1.get(r8)
            r9 = r0[r9]
            J3.i.b(r9)
            r2 = 0
            r9.d(r2)
            r9.f1604b = r3
            int r1 = r1.get(r8)
            r0[r1] = r2
            return r9
        */
        throw new UnsupportedOperationException("Method not decompiled: V3.v.b(int):Q3.W");
    }

    public final void c(int i4) {
        while (i4 > 0) {
            W[] wArr = this.f2252a;
            J3.i.b(wArr);
            int i5 = (i4 - 1) / 2;
            W w4 = wArr[i5];
            J3.i.b(w4);
            W w5 = wArr[i4];
            J3.i.b(w5);
            if (w4.compareTo(w5) <= 0) {
                return;
            }
            d(i4, i5);
            i4 = i5;
        }
    }

    public final void d(int i4, int i5) {
        W[] wArr = this.f2252a;
        J3.i.b(wArr);
        W w4 = wArr[i5];
        J3.i.b(w4);
        W w5 = wArr[i4];
        J3.i.b(w5);
        wArr[i4] = w4;
        wArr[i5] = w5;
        w4.f1604b = i4;
        w5.f1604b = i5;
    }
}
