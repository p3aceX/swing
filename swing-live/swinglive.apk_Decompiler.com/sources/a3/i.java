package A3;

import J3.s;
import J3.t;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public abstract class i extends h implements J3.g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f92a;

    public i(InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f92a = 2;
    }

    @Override // J3.g
    public final int getArity() {
        return this.f92a;
    }

    @Override // A3.a
    public final String toString() {
        if (getCompletion() != null) {
            return super.toString();
        }
        s.f833a.getClass();
        String strA = t.a(this);
        J3.i.d(strA, "renderLambdaToString(...)");
        return strA;
    }
}
