package b;

import O.E;
import x3.C0725e;

/* JADX INFO: loaded from: classes.dex */
public final class s implements InterfaceC0226c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final E f3260a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ u f3261b;

    public s(u uVar, E e) {
        J3.i.e(e, "onBackPressedCallback");
        this.f3261b = uVar;
        this.f3260a = e;
    }

    /* JADX WARN: Type inference failed for: r0v2, types: [I3.a, J3.h] */
    @Override // b.InterfaceC0226c
    public final void cancel() {
        u uVar = this.f3261b;
        C0725e c0725e = uVar.f3264b;
        E e = this.f3260a;
        c0725e.remove(e);
        if (J3.i.a(uVar.f3265c, e)) {
            e.a();
            uVar.f3265c = null;
        }
        e.f1210b.remove(this);
        ?? r02 = e.f1211c;
        if (r02 != 0) {
            r02.a();
        }
        e.f1211c = null;
    }
}
