package A1;

import J3.i;
import Q3.F;
import Q3.O;
import Q3.y0;
import X3.e;
import android.util.Log;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import l3.q;
import m1.C0553h;
import y1.C0754d;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0553h f76a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f77b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public volatile boolean f78c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public volatile q f79d;
    public final C0754d e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final boolean f80f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public y0 f81g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final V3.d f82h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public volatile long f83i;

    public d(C0553h c0553h, String str) {
        i.e(c0553h, "connectChecker");
        this.f76a = c0553h;
        this.f77b = str;
        this.f79d = new q();
        this.e = new C0754d(c0553h);
        this.f80f = true;
        e eVar = O.f1596a;
        this.f82h = F.b(X3.d.f2437c);
    }

    public abstract Object a(A3.c cVar);

    public final void b(B1.d dVar) {
        if (this.f78c) {
            q qVar = this.f79d;
            qVar.getClass();
            PriorityBlockingQueue priorityBlockingQueue = (PriorityBlockingQueue) qVar.f5711a;
            if (priorityBlockingQueue.size() < 400) {
                try {
                    priorityBlockingQueue.add(dVar);
                    return;
                } catch (IllegalStateException unused) {
                }
            }
            int iOrdinal = dVar.f117c.ordinal();
            if (iOrdinal == 0) {
                Log.i(this.f77b, "Video frame discarded");
            } else {
                if (iOrdinal != 1) {
                    throw new A0.b();
                }
                Log.i(this.f77b, "Audio frame discarded");
            }
        }
    }

    public final void c() {
        C0754d c0754d = this.e;
        c0754d.f6843b = 0L;
        c0754d.f6844c = 0L;
        q qVar = this.f79d;
        ((PriorityBlockingQueue) qVar.f5711a).clear();
        ((PriorityBlockingQueue) qVar.f5712b).clear();
        ((AtomicBoolean) qVar.f5713c).set(false);
        this.f78c = true;
        this.f81g = F.s(this.f82h, null, new b(this, null), 3);
    }

    /* JADX WARN: Code restructure failed: missing block: B:25:0x005e, code lost:
    
        if (r9 == r1) goto L26;
     */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object d(boolean r9, A3.c r10) {
        /*
            r8 = this;
            boolean r0 = r10 instanceof A1.c
            if (r0 == 0) goto L13
            r0 = r10
            A1.c r0 = (A1.c) r0
            int r1 = r0.f75d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f75d = r1
            goto L18
        L13:
            A1.c r0 = new A1.c
            r0.<init>(r8, r10)
        L18:
            java.lang.Object r10 = r0.f73b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f75d
            r3 = 0
            r4 = 0
            w3.i r5 = w3.i.f6729a
            r6 = 2
            r7 = 1
            if (r2 == 0) goto L3c
            if (r2 == r7) goto L36
            if (r2 != r6) goto L2e
            e1.AbstractC0367g.M(r10)
            goto L61
        L2e:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r10 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r10)
            throw r9
        L36:
            boolean r9 = r0.f72a
            e1.AbstractC0367g.M(r10)
            goto L4b
        L3c:
            e1.AbstractC0367g.M(r10)
            r8.f78c = r4
            r0.f72a = r9
            r0.f75d = r7
            r8.e(r9)
            if (r5 != r1) goto L4b
            goto L60
        L4b:
            Q3.y0 r10 = r8.f81g
            if (r10 == 0) goto L61
            r0.f72a = r9
            r0.f75d = r6
            r10.a(r3)
            java.lang.Object r9 = r10.y(r0)
            if (r9 != r1) goto L5d
            goto L5e
        L5d:
            r9 = r5
        L5e:
            if (r9 != r1) goto L61
        L60:
            return r1
        L61:
            r8.f81g = r3
            l3.q r9 = r8.f79d
            java.lang.Object r10 = r9.f5711a
            java.util.concurrent.PriorityBlockingQueue r10 = (java.util.concurrent.PriorityBlockingQueue) r10
            r10.clear()
            java.lang.Object r10 = r9.f5712b
            java.util.concurrent.PriorityBlockingQueue r10 = (java.util.concurrent.PriorityBlockingQueue) r10
            r10.clear()
            java.lang.Object r9 = r9.f5713c
            java.util.concurrent.atomic.AtomicBoolean r9 = (java.util.concurrent.atomic.AtomicBoolean) r9
            r9.set(r4)
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: A1.d.d(boolean, A3.c):java.lang.Object");
    }

    public abstract void e(boolean z4);
}
