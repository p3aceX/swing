package O;

import a.AbstractC0184a;
import android.os.Handler;
import android.view.View;
import android.view.Window;
import z.InterfaceC0769a;

/* JADX INFO: renamed from: O.y, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0113y extends AbstractC0184a implements r.i, androidx.lifecycle.I, b.v, Y.g, S {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AbstractActivityC0114z f1432b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AbstractActivityC0114z f1433c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Handler f1434d;
    public final N e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ AbstractActivityC0114z f1435f;

    public C0113y(AbstractActivityC0114z abstractActivityC0114z) {
        this.f1435f = abstractActivityC0114z;
        Handler handler = new Handler();
        this.f1432b = abstractActivityC0114z;
        this.f1433c = abstractActivityC0114z;
        this.f1434d = handler;
        this.e = new N();
    }

    @Override // a.AbstractC0184a
    public final View Q(int i4) {
        return this.f1435f.findViewById(i4);
    }

    @Override // a.AbstractC0184a
    public final boolean R() {
        Window window = this.f1435f.getWindow();
        return (window == null || window.peekDecorView() == null) ? false : true;
    }

    @Override // b.v
    public final b.u b() {
        return this.f1435f.b();
    }

    @Override // Y.g
    public final Y.e c() {
        return (Y.e) this.f1435f.e.f2464c;
    }

    @Override // r.i
    public final void d(InterfaceC0769a interfaceC0769a) {
        this.f1435f.d(interfaceC0769a);
    }

    @Override // r.i
    public final void e(InterfaceC0769a interfaceC0769a) {
        this.f1435f.e(interfaceC0769a);
    }

    @Override // androidx.lifecycle.I
    public final androidx.lifecycle.H g() {
        return this.f1435f.g();
    }

    @Override // androidx.lifecycle.n
    public final androidx.lifecycle.p i() {
        return this.f1435f.f1439y;
    }

    @Override // O.S
    public final void a() {
    }
}
