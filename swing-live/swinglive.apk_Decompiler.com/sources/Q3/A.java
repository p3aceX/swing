package Q3;

import y3.AbstractC0760a;
import y3.C0763d;
import y3.InterfaceC0764e;
import y3.InterfaceC0765f;
import y3.InterfaceC0766g;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public abstract class A extends AbstractC0760a implements InterfaceC0764e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0153z f1563b = new C0153z(C0763d.f6944a, new C0152y(0));

    public A() {
        super(C0763d.f6944a);
    }

    public abstract void A(InterfaceC0767h interfaceC0767h, Runnable runnable);

    public void B(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        V3.b.i(this, interfaceC0767h, runnable);
    }

    public boolean C(InterfaceC0767h interfaceC0767h) {
        return !(this instanceof H0);
    }

    public A D(int i4) {
        V3.b.a(i4);
        return new V3.h(this, i4);
    }

    /* JADX WARN: Removed duplicated region for block: B:15:0x0026 A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0027 A[RETURN] */
    @Override // y3.AbstractC0760a, y3.InterfaceC0767h
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final y3.InterfaceC0767h c(y3.InterfaceC0766g r4) {
        /*
            r3 = this;
            java.lang.String r0 = "key"
            J3.i.e(r4, r0)
            boolean r0 = r4 instanceof Q3.C0153z
            y3.i r1 = y3.C0768i.f6945a
            if (r0 == 0) goto L22
            Q3.z r4 = (Q3.C0153z) r4
            y3.g r0 = r3.f6941a
            if (r0 == r4) goto L17
            y3.g r2 = r4.f1673b
            if (r2 != r0) goto L16
            goto L17
        L16:
            return r3
        L17:
            I3.l r4 = r4.f1672a
            java.lang.Object r4 = r4.invoke(r3)
            y3.f r4 = (y3.InterfaceC0765f) r4
            if (r4 == 0) goto L27
            goto L26
        L22:
            y3.d r0 = y3.C0763d.f6944a
            if (r0 != r4) goto L27
        L26:
            return r1
        L27:
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.A.c(y3.g):y3.h");
    }

    @Override // y3.AbstractC0760a, y3.InterfaceC0767h
    public final InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        InterfaceC0765f interfaceC0765f;
        J3.i.e(interfaceC0766g, "key");
        if (!(interfaceC0766g instanceof C0153z)) {
            if (C0763d.f6944a == interfaceC0766g) {
                return this;
            }
            return null;
        }
        C0153z c0153z = (C0153z) interfaceC0766g;
        InterfaceC0766g interfaceC0766g2 = this.f6941a;
        if ((interfaceC0766g2 == c0153z || c0153z.f1673b == interfaceC0766g2) && (interfaceC0765f = (InterfaceC0765f) c0153z.f1672a.invoke(this)) != null) {
            return interfaceC0765f;
        }
        return null;
    }

    public String toString() {
        return getClass().getSimpleName() + '@' + F.l(this);
    }
}
