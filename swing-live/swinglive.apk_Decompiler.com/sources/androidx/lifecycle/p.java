package androidx.lifecycle;

import android.os.Looper;
import com.google.crypto.tink.shaded.protobuf.S;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicReference;
import l.C0517a;
import m.C0539a;
import m.C0541c;

/* JADX INFO: loaded from: classes.dex */
public final class p extends AbstractC0223i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f3075a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0539a f3076b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public EnumC0222h f3077c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final WeakReference f3078d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f3079f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f3080g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final ArrayList f3081h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final T3.q f3082i;

    public p(n nVar) {
        new AtomicReference();
        this.f3075a = true;
        this.f3076b = new C0539a();
        EnumC0222h enumC0222h = EnumC0222h.f3068b;
        this.f3077c = enumC0222h;
        this.f3081h = new ArrayList();
        this.f3078d = new WeakReference(nVar);
        this.f3082i = new T3.q(enumC0222h);
    }

    @Override // androidx.lifecycle.AbstractC0223i
    public final void a(l lVar) {
        Object obj;
        n nVar;
        ArrayList arrayList = this.f3081h;
        d("addObserver");
        EnumC0222h enumC0222h = this.f3077c;
        EnumC0222h enumC0222h2 = EnumC0222h.f3067a;
        if (enumC0222h != enumC0222h2) {
            enumC0222h2 = EnumC0222h.f3068b;
        }
        o oVar = new o();
        int i4 = q.f3083a;
        boolean z4 = lVar instanceof DefaultLifecycleObserver;
        oVar.f3074b = z4 ? new C0216b((DefaultLifecycleObserver) lVar, lVar) : z4 ? new C0216b((DefaultLifecycleObserver) lVar, null) : lVar;
        oVar.f3073a = enumC0222h2;
        C0539a c0539a = this.f3076b;
        C0541c c0541cF = c0539a.f(lVar);
        if (c0541cF != null) {
            obj = c0541cF.f5752b;
        } else {
            HashMap map = c0539a.e;
            C0541c c0541c = new C0541c(lVar, oVar);
            c0539a.f5761d++;
            C0541c c0541c2 = c0539a.f5759b;
            if (c0541c2 == null) {
                c0539a.f5758a = c0541c;
                c0539a.f5759b = c0541c;
            } else {
                c0541c2.f5753c = c0541c;
                c0541c.f5754d = c0541c2;
                c0539a.f5759b = c0541c;
            }
            map.put(lVar, c0541c);
            obj = null;
        }
        if (((o) obj) == null && (nVar = (n) this.f3078d.get()) != null) {
            boolean z5 = this.e != 0 || this.f3079f;
            EnumC0222h enumC0222hC = c(lVar);
            this.e++;
            while (oVar.f3073a.compareTo(enumC0222hC) < 0 && this.f3076b.e.containsKey(lVar)) {
                arrayList.add(oVar.f3073a);
                C0219e c0219e = EnumC0221g.Companion;
                EnumC0222h enumC0222h3 = oVar.f3073a;
                c0219e.getClass();
                J3.i.e(enumC0222h3, "state");
                int iOrdinal = enumC0222h3.ordinal();
                EnumC0221g enumC0221g = iOrdinal != 1 ? iOrdinal != 2 ? iOrdinal != 3 ? null : EnumC0221g.ON_RESUME : EnumC0221g.ON_START : EnumC0221g.ON_CREATE;
                if (enumC0221g == null) {
                    throw new IllegalStateException("no event up from " + oVar.f3073a);
                }
                oVar.a(nVar, enumC0221g);
                arrayList.remove(arrayList.size() - 1);
                enumC0222hC = c(lVar);
            }
            if (!z5) {
                h();
            }
            this.e--;
        }
    }

    @Override // androidx.lifecycle.AbstractC0223i
    public final void b(l lVar) {
        d("removeObserver");
        this.f3076b.g(lVar);
    }

    public final EnumC0222h c(l lVar) {
        HashMap map = this.f3076b.e;
        C0541c c0541c = map.containsKey(lVar) ? ((C0541c) map.get(lVar)).f5754d : null;
        EnumC0222h enumC0222h = c0541c != null ? ((o) c0541c.f5752b).f3073a : null;
        ArrayList arrayList = this.f3081h;
        EnumC0222h enumC0222h2 = arrayList.isEmpty() ? null : (EnumC0222h) arrayList.get(arrayList.size() - 1);
        EnumC0222h enumC0222h3 = this.f3077c;
        J3.i.e(enumC0222h3, "state1");
        if (enumC0222h == null || enumC0222h.compareTo(enumC0222h3) >= 0) {
            enumC0222h = enumC0222h3;
        }
        return (enumC0222h2 == null || enumC0222h2.compareTo(enumC0222h) >= 0) ? enumC0222h : enumC0222h2;
    }

    public final void d(String str) {
        if (this.f3075a) {
            C0517a.c0().f5566c.getClass();
            if (Looper.getMainLooper().getThread() != Thread.currentThread()) {
                throw new IllegalStateException(S.g("Method ", str, " must be called on the main thread").toString());
            }
        }
    }

    public final void e(EnumC0221g enumC0221g) {
        J3.i.e(enumC0221g, "event");
        d("handleLifecycleEvent");
        f(enumC0221g.a());
    }

    public final void f(EnumC0222h enumC0222h) {
        EnumC0222h enumC0222h2 = this.f3077c;
        if (enumC0222h2 == enumC0222h) {
            return;
        }
        EnumC0222h enumC0222h3 = EnumC0222h.f3068b;
        EnumC0222h enumC0222h4 = EnumC0222h.f3067a;
        if (enumC0222h2 == enumC0222h3 && enumC0222h == enumC0222h4) {
            throw new IllegalStateException(("no event down from " + this.f3077c + " in component " + this.f3078d.get()).toString());
        }
        this.f3077c = enumC0222h;
        if (this.f3079f || this.e != 0) {
            this.f3080g = true;
            return;
        }
        this.f3079f = true;
        h();
        this.f3079f = false;
        if (this.f3077c == enumC0222h4) {
            this.f3076b = new C0539a();
        }
    }

    public final void g() {
        EnumC0222h enumC0222h = EnumC0222h.f3069c;
        d("setCurrentState");
        f(enumC0222h);
    }

    /* JADX WARN: Code restructure failed: missing block: B:11:0x0030, code lost:
    
        r12.f3080g = false;
        r12.f3082i.a(r12.f3077c);
     */
    /* JADX WARN: Code restructure failed: missing block: B:12:0x0039, code lost:
    
        return;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void h() {
        /*
            Method dump skipped, instruction units count: 417
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.lifecycle.p.h():void");
    }
}
