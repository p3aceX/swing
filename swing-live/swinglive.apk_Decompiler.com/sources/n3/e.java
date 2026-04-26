package n3;

import Q3.C;
import Q3.C0141m;
import Q3.C0142n;
import Q3.D;
import Q3.F;
import Q3.InterfaceC0137k;
import e1.AbstractC0367g;
import io.ktor.network.sockets.w;
import java.io.Closeable;
import java.io.IOException;
import java.nio.channels.CancelledKeyException;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.ClosedSelectorException;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.spi.AbstractSelector;
import java.nio.channels.spi.SelectorProvider;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Closeable, D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final SelectorProvider f5906a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5907b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5908c;
    private volatile boolean closed;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final AtomicLong f5909d;
    public final B.k e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final m f5910f;
    private volatile boolean inSelect;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final InterfaceC0767h f5911m;
    private volatile Selector selectorRef;

    public e(X3.d dVar) {
        J3.i.e(dVar, "context");
        SelectorProvider selectorProviderProvider = SelectorProvider.provider();
        J3.i.d(selectorProviderProvider, "provider(...)");
        this.f5906a = selectorProviderProvider;
        this.f5909d = new AtomicLong();
        this.e = new B.k(27);
        this.f5910f = new m();
        this.f5911m = AbstractC0367g.A(dVar, new C("selector"));
        F.s(this, null, new C0565a(this, null), 3);
    }

    /* JADX WARN: Code restructure failed: missing block: B:46:0x00e0, code lost:
    
        if (r12 == r1) goto L47;
     */
    /* JADX WARN: Code restructure failed: missing block: B:55:0x00e3, code lost:
    
        if (r12 != r1) goto L48;
     */
    /* JADX WARN: Path cross not found for [B:45:0x00dc, B:46:0x00e0], limit reached: 63 */
    /* JADX WARN: Removed duplicated region for block: B:21:0x0061 A[LOOP:1: B:21:0x0061->B:52:0x00ed, LOOP_START] */
    /* JADX WARN: Removed duplicated region for block: B:30:0x0082  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x0094  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0016  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:30:0x0082 -> B:19:0x005d). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:33:0x009c -> B:19:0x005d). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:35:0x00aa -> B:19:0x005d). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object a(n3.e r9, n3.m r10, java.nio.channels.spi.AbstractSelector r11, A3.c r12) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 245
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: n3.e.a(n3.e, n3.m, java.nio.channels.spi.AbstractSelector, A3.c):java.lang.Object");
    }

    public static void f(AbstractSelector abstractSelector, Throwable th) {
        J3.i.e(abstractSelector, "selector");
        if (th == null) {
            th = new f("Closed selector");
        }
        Set<SelectionKey> setKeys = abstractSelector.keys();
        J3.i.d(setKeys, "keys(...)");
        for (SelectionKey selectionKey : setKeys) {
            try {
                if (selectionKey.isValid()) {
                    selectionKey.interestOps(0);
                }
            } catch (CancelledKeyException unused) {
            }
            Object objAttachment = selectionKey.attachment();
            q qVar = objAttachment instanceof q ? (q) objAttachment : null;
            if (qVar != null) {
                g(qVar, th);
            }
            selectionKey.cancel();
        }
    }

    public static void g(q qVar, Throwable th) {
        J3.i.e(qVar, "attachment");
        r rVar = (r) qVar;
        p.f5925b.getClass();
        for (p pVar : p.f5926c) {
            l lVar = rVar.f5935b;
            lVar.getClass();
            J3.i.e(pVar, "interest");
            InterfaceC0137k interfaceC0137k = (InterfaceC0137k) l.f5917a[pVar.ordinal()].getAndSet(lVar, null);
            if (interfaceC0137k != null) {
                interfaceC0137k.resumeWith(AbstractC0367g.h(th));
            }
        }
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
        this.closed = true;
        this.f5910f.b();
        B.k kVar = this.e;
        w3.i iVar = w3.i.f6729a;
        InterfaceC0762c interfaceC0762c = (InterfaceC0762c) ((AtomicReference) kVar.f104b).getAndSet(null);
        if (interfaceC0762c == null) {
            q();
        } else {
            interfaceC0762c.resumeWith(iVar);
        }
    }

    public final void d(Selector selector, q qVar) {
        J3.i.e(selector, "selector");
        try {
            SelectableChannel selectableChannelR = qVar.r();
            SelectionKey selectionKeyKeyFor = selectableChannelR.keyFor(selector);
            int iB = ((r) qVar).b();
            if (selectionKeyKeyFor == null) {
                if (iB != 0) {
                    selectableChannelR.register(selector, iB, qVar);
                }
            } else if (selectionKeyKeyFor.interestOps() != iB) {
                selectionKeyKeyFor.interestOps(iB);
            }
            if (iB != 0) {
                this.f5907b++;
            }
        } catch (Throwable th) {
            SelectionKey selectionKeyKeyFor2 = qVar.r().keyFor(selector);
            if (selectionKeyKeyFor2 != null) {
                selectionKeyKeyFor2.cancel();
            }
            g(qVar, th);
        }
    }

    public final void h(Set set, Set set2) {
        int size = set.size();
        this.f5907b = set2.size() - size;
        this.f5908c = 0;
        if (size <= 0) {
            return;
        }
        Iterator it = set.iterator();
        while (it.hasNext()) {
            SelectionKey selectionKey = (SelectionKey) it.next();
            J3.i.e(selectionKey, "key");
            try {
                int i4 = selectionKey.readyOps();
                int iInterestOps = selectionKey.interestOps();
                Object objAttachment = selectionKey.attachment();
                q qVar = objAttachment instanceof q ? (q) objAttachment : null;
                if (qVar == null) {
                    selectionKey.cancel();
                    this.f5908c++;
                } else {
                    l lVar = ((r) qVar).f5935b;
                    p.f5925b.getClass();
                    int[] iArr = p.f5927d;
                    int length = iArr.length;
                    for (int i5 = 0; i5 < length; i5++) {
                        if ((iArr[i5] & i4) != 0) {
                            lVar.getClass();
                            InterfaceC0137k interfaceC0137k = (InterfaceC0137k) l.f5917a[i5].getAndSet(lVar, null);
                            if (interfaceC0137k != null) {
                                interfaceC0137k.resumeWith(w3.i.f6729a);
                            }
                        }
                    }
                    int i6 = (~i4) & iInterestOps;
                    if (i6 != iInterestOps) {
                        selectionKey.interestOps(i6);
                    }
                    if (i6 != 0) {
                        this.f5907b++;
                    }
                }
            } catch (Throwable th) {
                selectionKey.cancel();
                this.f5908c++;
                Object objAttachment2 = selectionKey.attachment();
                q qVar2 = objAttachment2 instanceof q ? (q) objAttachment2 : null;
                if (qVar2 != null) {
                    g(qVar2, th);
                    selectionKey.attach(null);
                }
            }
            it.remove();
        }
    }

    public final void i(w wVar) {
        SelectionKey selectionKeyKeyFor;
        g(wVar, new ClosedChannelException());
        Selector selector = this.selectorRef;
        if (selector == null || (selectionKeyKeyFor = wVar.r().keyFor(selector)) == null) {
            return;
        }
        selectionKeyKeyFor.cancel();
        q();
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object l(n3.m r7, A3.c r8) {
        /*
            r6 = this;
            boolean r0 = r8 instanceof n3.C0567c
            if (r0 == 0) goto L13
            r0 = r8
            n3.c r0 = (n3.C0567c) r0
            int r1 = r0.f5901d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5901d = r1
            goto L18
        L13:
            n3.c r0 = new n3.c
            r0.<init>(r6, r8)
        L18:
            java.lang.Object r8 = r0.f5899b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5901d
            r3 = 1
            if (r2 == 0) goto L2e
            if (r2 != r3) goto L26
            n3.m r7 = r0.f5898a
            goto L2e
        L26:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L2e:
            e1.AbstractC0367g.M(r8)
        L31:
            java.lang.Object r8 = r7.d()
            n3.q r8 = (n3.q) r8
            if (r8 == 0) goto L3a
            return r8
        L3a:
            boolean r8 = r6.closed
            r2 = 0
            if (r8 == 0) goto L40
            return r2
        L40:
            r0.f5898a = r7
            r0.f5901d = r3
            B.k r8 = r6.e
            boolean r4 = r7.c()
            if (r4 == 0) goto L89
            boolean r4 = r6.closed
            if (r4 != 0) goto L89
            java.lang.Object r4 = r8.f104b
            java.util.concurrent.atomic.AtomicReference r4 = (java.util.concurrent.atomic.AtomicReference) r4
        L54:
            boolean r5 = r4.compareAndSet(r2, r0)
            if (r5 == 0) goto L7a
            boolean r4 = r7.c()
            if (r4 == 0) goto L65
            boolean r4 = r6.closed
            if (r4 != 0) goto L65
            goto L77
        L65:
            java.lang.Object r8 = r8.f104b
            r5 = r8
            java.util.concurrent.atomic.AtomicReference r5 = (java.util.concurrent.atomic.AtomicReference) r5
        L6a:
            boolean r8 = r5.compareAndSet(r0, r2)
            if (r8 == 0) goto L71
            goto L89
        L71:
            java.lang.Object r8 = r5.get()
            if (r8 == r0) goto L6a
        L77:
            z3.a r2 = z3.EnumC0789a.f6999a
            goto L89
        L7a:
            java.lang.Object r5 = r4.get()
            if (r5 != 0) goto L81
            goto L54
        L81:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "Continuation is already set"
            r7.<init>(r8)
            throw r7
        L89:
            if (r2 != 0) goto L8d
            w3.i r2 = w3.i.f6729a
        L8d:
            z3.a r8 = z3.EnumC0789a.f6999a
            if (r2 != r1) goto L31
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: n3.e.l(n3.m, A3.c):java.lang.Object");
    }

    @Override // Q3.D
    public final InterfaceC0767h n() {
        return this.f5911m;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object o(java.nio.channels.Selector r5, A3.c r6) throws java.io.IOException {
        /*
            r4 = this;
            boolean r0 = r6 instanceof n3.C0568d
            if (r0 == 0) goto L13
            r0 = r6
            n3.d r0 = (n3.C0568d) r0
            int r1 = r0.f5905d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5905d = r1
            goto L18
        L13:
            n3.d r0 = new n3.d
            r0.<init>(r4, r6)
        L18:
            java.lang.Object r6 = r0.f5903b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5905d
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            java.nio.channels.Selector r5 = r0.f5902a
            e1.AbstractC0367g.M(r6)
            goto L41
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L31:
            e1.AbstractC0367g.M(r6)
            r4.inSelect = r3
            r0.f5902a = r5
            r0.f5905d = r3
            java.lang.Object r6 = Q3.F.E(r0)
            if (r6 != r1) goto L41
            return r1
        L41:
            java.util.concurrent.atomic.AtomicLong r6 = r4.f5909d
            long r0 = r6.get()
            r2 = 0
            int r6 = (r0 > r2 ? 1 : (r0 == r2 ? 0 : -1))
            r0 = 0
            if (r6 != 0) goto L57
            r1 = 500(0x1f4, double:2.47E-321)
            int r5 = r5.select(r1)
            r4.inSelect = r0
            goto L62
        L57:
            r4.inSelect = r0
            java.util.concurrent.atomic.AtomicLong r6 = r4.f5909d
            r6.set(r2)
            int r5 = r5.selectNow()
        L62:
            java.lang.Integer r6 = new java.lang.Integer
            r6.<init>(r5)
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: n3.e.o(java.nio.channels.Selector, A3.c):java.lang.Object");
    }

    public final Object p(q qVar, p pVar, A3.c cVar) throws IOException {
        r rVar = (r) qVar;
        int iB = rVar.b();
        if (rVar.f5934a.get()) {
            throw new IOException("Selectable is already closed");
        }
        int i4 = pVar.f5932a;
        if ((iB & i4) == 0) {
            throw new IllegalStateException(("Selectable is invalid state: " + iB + ", " + i4).toString());
        }
        C0141m c0141m = new C0141m(1, e1.k.w(cVar));
        c0141m.r();
        c0141m.t(s.f5936a);
        l lVar = rVar.f5935b;
        lVar.getClass();
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = l.f5917a[pVar.ordinal()];
        while (!atomicReferenceFieldUpdater.compareAndSet(lVar, null, c0141m)) {
            if (atomicReferenceFieldUpdater.get(lVar) != null) {
                throw new IllegalStateException(("Handler for " + pVar.name() + " is already registered").toString());
            }
        }
        boolean z4 = C0141m.f1639m.get(c0141m) instanceof C0142n;
        w3.i iVar = w3.i.f6729a;
        if (!z4) {
            try {
                if (!this.f5910f.a(rVar)) {
                    if (rVar.r().isOpen()) {
                        throw new ClosedSelectorException();
                    }
                    throw new ClosedChannelException();
                }
                InterfaceC0762c interfaceC0762c = (InterfaceC0762c) ((AtomicReference) this.e.f104b).getAndSet(null);
                if (interfaceC0762c != null) {
                    interfaceC0762c.resumeWith(iVar);
                }
                q();
            } catch (Throwable th) {
                g(rVar, th);
            }
        }
        Object objQ = c0141m.q();
        return objQ == EnumC0789a.f6999a ? objQ : iVar;
    }

    public final void q() {
        Selector selector;
        if (this.f5909d.incrementAndGet() == 1 && this.inSelect && (selector = this.selectorRef) != null) {
            selector.wakeup();
        }
    }
}
