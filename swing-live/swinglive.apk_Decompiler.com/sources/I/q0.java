package I;

import e1.AbstractC0367g;
import y3.InterfaceC0765f;
import y3.InterfaceC0766g;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class q0 implements InterfaceC0765f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final q0 f717a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Q f718b;

    public q0(q0 q0Var, Q q4) {
        J3.i.e(q4, "instance");
        this.f717a = q0Var;
        this.f718b = q4;
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h c(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.y(this, interfaceC0766g);
    }

    public final void e(Q q4) {
        if (this.f718b == q4) {
            throw new IllegalStateException("Calling updateData inside updateData on the same DataStore instance is not supported\nsince updates made in the parent updateData call will not be visible to the nested\nupdateData call. See https://issuetracker.google.com/issues/241760537 for details.");
        }
        q0 q0Var = this.f717a;
        if (q0Var != null) {
            q0Var.e(q4);
        }
    }

    @Override // y3.InterfaceC0765f
    public final InterfaceC0766g getKey() {
        return p0.f715a;
    }

    @Override // y3.InterfaceC0767h
    public final Object h(Object obj, I3.p pVar) {
        return pVar.invoke(obj, this);
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.u(this, interfaceC0766g);
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h s(InterfaceC0767h interfaceC0767h) {
        return AbstractC0367g.A(this, interfaceC0767h);
    }
}
