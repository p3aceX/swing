package U3;

import Q3.F;
import S3.u;
import java.util.ArrayList;
import x3.AbstractC0728h;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class e implements i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0767h f2112a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f2113b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final S3.c f2114c;

    public e(InterfaceC0767h interfaceC0767h, int i4, S3.c cVar) {
        this.f2112a = interfaceC0767h;
        this.f2113b = i4;
        this.f2114c = cVar;
    }

    public abstract Object a(u uVar, InterfaceC0762c interfaceC0762c);

    @Override // T3.d
    public Object b(T3.e eVar, InterfaceC0762c interfaceC0762c) throws Throwable {
        Object objG = F.g(new c(eVar, this, null), interfaceC0762c);
        return objG == EnumC0789a.f6999a ? objG : w3.i.f6729a;
    }

    public abstract e c(InterfaceC0767h interfaceC0767h, int i4, S3.c cVar);

    /* JADX WARN: Removed duplicated region for block: B:9:0x0015  */
    @Override // U3.i
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final T3.d d(y3.InterfaceC0767h r5, int r6, S3.c r7) {
        /*
            r4 = this;
            y3.h r0 = r4.f2112a
            y3.h r5 = r5.s(r0)
            S3.c r1 = S3.c.f1813a
            S3.c r2 = r4.f2114c
            int r3 = r4.f2113b
            if (r7 == r1) goto Lf
            goto L26
        Lf:
            r7 = -3
            if (r3 != r7) goto L13
            goto L25
        L13:
            if (r6 != r7) goto L17
        L15:
            r6 = r3
            goto L25
        L17:
            r7 = -2
            if (r3 != r7) goto L1b
            goto L25
        L1b:
            if (r6 != r7) goto L1e
            goto L15
        L1e:
            int r6 = r6 + r3
            if (r6 < 0) goto L22
            goto L25
        L22:
            r6 = 2147483647(0x7fffffff, float:NaN)
        L25:
            r7 = r2
        L26:
            boolean r0 = J3.i.a(r5, r0)
            if (r0 == 0) goto L31
            if (r6 != r3) goto L31
            if (r7 != r2) goto L31
            return r4
        L31:
            U3.e r5 = r4.c(r5, r6, r7)
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: U3.e.d(y3.h, int, S3.c):T3.d");
    }

    public String toString() {
        ArrayList arrayList = new ArrayList(4);
        C0768i c0768i = C0768i.f6945a;
        InterfaceC0767h interfaceC0767h = this.f2112a;
        if (interfaceC0767h != c0768i) {
            arrayList.add("context=" + interfaceC0767h);
        }
        int i4 = this.f2113b;
        if (i4 != -3) {
            arrayList.add("capacity=" + i4);
        }
        S3.c cVar = S3.c.f1813a;
        S3.c cVar2 = this.f2114c;
        if (cVar2 != cVar) {
            arrayList.add("onBufferOverflow=" + cVar2);
        }
        return getClass().getSimpleName() + '[' + AbstractC0728h.a0(arrayList, ", ", null, null, null, 62) + ']';
    }
}
