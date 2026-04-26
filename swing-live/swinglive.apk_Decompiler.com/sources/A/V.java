package A;

import android.os.Build;
import android.view.View;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public class V {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ int f31b = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final X f32a;

    static {
        int i4 = Build.VERSION.SDK_INT;
        (i4 >= 30 ? new M() : i4 >= 29 ? new L() : new J()).b().f33a.a().f33a.b().f33a.c();
    }

    public V(X x4) {
        this.f32a = x4;
    }

    public X a() {
        return this.f32a;
    }

    public X b() {
        return this.f32a;
    }

    public X c() {
        return this.f32a;
    }

    public C0007g e() {
        return null;
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof V)) {
            return false;
        }
        V v = (V) obj;
        return l() == v.l() && k() == v.k() && Objects.equals(i(), v.i()) && Objects.equals(g(), v.g()) && Objects.equals(e(), v.e());
    }

    public t.c f() {
        return i();
    }

    public t.c g() {
        return t.c.e;
    }

    public t.c h() {
        return i();
    }

    public int hashCode() {
        return Objects.hash(Boolean.valueOf(l()), Boolean.valueOf(k()), i(), g(), e());
    }

    public t.c i() {
        return t.c.e;
    }

    public t.c j() {
        return i();
    }

    public boolean k() {
        return false;
    }

    public boolean l() {
        return false;
    }

    public boolean m(int i4) {
        return true;
    }

    public void d(View view) {
    }

    public void n(t.c[] cVarArr) {
    }

    public void o(X x4) {
    }

    public void p(t.c cVar) {
    }
}
