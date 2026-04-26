package A3;

import J3.s;
import J3.t;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public abstract class j extends c implements J3.g {
    private final int arity;

    public j(int i4, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.arity = i4;
    }

    @Override // J3.g
    public int getArity() {
        return this.arity;
    }

    @Override // A3.a
    public String toString() {
        if (getCompletion() != null) {
            return super.toString();
        }
        s.f833a.getClass();
        String strA = t.a(this);
        J3.i.d(strA, "renderLambdaToString(...)");
        return strA;
    }
}
