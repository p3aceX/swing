package J3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public abstract class j implements g, Serializable {
    private final int arity;

    public j(int i4) {
        this.arity = i4;
    }

    @Override // J3.g
    public int getArity() {
        return this.arity;
    }

    public String toString() {
        s.f833a.getClass();
        String strA = t.a(this);
        i.d(strA, "renderLambdaToString(...)");
        return strA;
    }
}
