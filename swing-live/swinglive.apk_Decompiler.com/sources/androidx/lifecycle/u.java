package androidx.lifecycle;

import android.os.Looper;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Map;
import l.C0517a;
import m.C0541c;
import m.C0542d;
import m.C0544f;

/* JADX INFO: loaded from: classes.dex */
public class u {

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public static final Object f3089k = new Object();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f3090a = new Object();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0544f f3091b = new C0544f();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f3092c = 0;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f3093d;
    public volatile Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public volatile Object f3094f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f3095g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f3096h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f3097i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final F.b f3098j;

    public u() {
        Object obj = f3089k;
        this.f3094f = obj;
        this.f3098j = new F.b(this, 7);
        this.e = obj;
        this.f3095g = -1;
    }

    public static void a(String str) {
        C0517a.c0().f5566c.getClass();
        if (Looper.getMainLooper().getThread() != Thread.currentThread()) {
            throw new IllegalStateException(S.g("Cannot invoke ", str, " on a background thread"));
        }
    }

    public final void b(t tVar) {
        if (tVar.f3086b) {
            if (!tVar.e()) {
                tVar.b(false);
                return;
            }
            int i4 = tVar.f3087c;
            int i5 = this.f3095g;
            if (i4 >= i5) {
                return;
            }
            tVar.f3087c = i5;
            tVar.f3085a.m(this.e);
        }
    }

    public final void c(t tVar) {
        if (this.f3096h) {
            this.f3097i = true;
            return;
        }
        this.f3096h = true;
        do {
            this.f3097i = false;
            if (tVar != null) {
                b(tVar);
                tVar = null;
            } else {
                C0544f c0544f = this.f3091b;
                c0544f.getClass();
                C0542d c0542d = new C0542d(c0544f);
                c0544f.f5760c.put(c0542d, Boolean.FALSE);
                while (c0542d.hasNext()) {
                    b((t) ((Map.Entry) c0542d.next()).getValue());
                    if (this.f3097i) {
                        break;
                    }
                }
            }
        } while (this.f3097i);
        this.f3096h = false;
    }

    public final void d(n nVar, v vVar) {
        Object obj;
        a("observe");
        if (nVar.i().f3077c == EnumC0222h.f3067a) {
            return;
        }
        s sVar = new s(this, nVar, vVar);
        C0544f c0544f = this.f3091b;
        C0541c c0541cF = c0544f.f(vVar);
        if (c0541cF != null) {
            obj = c0541cF.f5752b;
        } else {
            C0541c c0541c = new C0541c(vVar, sVar);
            c0544f.f5761d++;
            C0541c c0541c2 = c0544f.f5759b;
            if (c0541c2 == null) {
                c0544f.f5758a = c0541c;
                c0544f.f5759b = c0541c;
            } else {
                c0541c2.f5753c = c0541c;
                c0541c.f5754d = c0541c2;
                c0544f.f5759b = c0541c;
            }
            obj = null;
        }
        t tVar = (t) obj;
        if (tVar != null && !tVar.d(nVar)) {
            throw new IllegalArgumentException("Cannot add the same observer with different lifecycles");
        }
        if (tVar != null) {
            return;
        }
        nVar.i().a(sVar);
    }

    public void g(v vVar) {
        a("removeObserver");
        t tVar = (t) this.f3091b.g(vVar);
        if (tVar == null) {
            return;
        }
        tVar.c();
        tVar.b(false);
    }

    public void h(Object obj) {
        a("setValue");
        this.f3095g++;
        this.e = obj;
        c(null);
    }

    public void e() {
    }

    public void f() {
    }
}
