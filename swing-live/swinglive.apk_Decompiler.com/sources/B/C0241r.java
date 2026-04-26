package b;

import O.E;
import androidx.lifecycle.AbstractC0223i;
import androidx.lifecycle.EnumC0221g;

/* JADX INFO: renamed from: b.r, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0241r implements androidx.lifecycle.l, InterfaceC0226c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0223i f3256a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final E f3257b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public s f3258c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ u f3259d;

    public C0241r(u uVar, AbstractC0223i abstractC0223i, E e) {
        J3.i.e(abstractC0223i, "lifecycle");
        J3.i.e(e, "onBackPressedCallback");
        this.f3259d = uVar;
        this.f3256a = abstractC0223i;
        this.f3257b = e;
        abstractC0223i.a(this);
    }

    @Override // androidx.lifecycle.l
    public final void a(androidx.lifecycle.n nVar, EnumC0221g enumC0221g) {
        if (enumC0221g == EnumC0221g.ON_START) {
            u uVar = this.f3259d;
            E e = this.f3257b;
            J3.i.e(e, "onBackPressedCallback");
            uVar.f3264b.addLast(e);
            s sVar = new s(uVar, e);
            e.f1210b.add(sVar);
            uVar.c();
            e.f1211c = new t(0, uVar, u.class, "updateEnabledCallbacks", "updateEnabledCallbacks()V", 0, 1);
            this.f3258c = sVar;
            return;
        }
        if (enumC0221g != EnumC0221g.ON_STOP) {
            if (enumC0221g == EnumC0221g.ON_DESTROY) {
                cancel();
            }
        } else {
            s sVar2 = this.f3258c;
            if (sVar2 != null) {
                sVar2.cancel();
            }
        }
    }

    @Override // b.InterfaceC0226c
    public final void cancel() {
        this.f3256a.b(this);
        this.f3257b.f1210b.remove(this);
        s sVar = this.f3258c;
        if (sVar != null) {
            sVar.cancel();
        }
        this.f3258c = null;
    }
}
