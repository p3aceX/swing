package f0;

import I3.l;
import J3.i;
import e1.AbstractC0367g;

/* JADX INFO: loaded from: classes.dex */
public final class g extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f4277c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f4278d;
    public final C0399a e;

    public g(Object obj, int i4, C0399a c0399a) {
        i.e(obj, "value");
        B1.a.o(i4, "verificationMode");
        this.f4277c = obj;
        this.f4278d = i4;
        this.e = c0399a;
    }

    @Override // e1.AbstractC0367g
    public final AbstractC0367g J(String str, l lVar) {
        Object obj = this.f4277c;
        return ((Boolean) lVar.invoke(obj)).booleanValue() ? this : new f(obj, str, this.e, this.f4278d);
    }

    @Override // e1.AbstractC0367g
    public final Object d() {
        return this.f4277c;
    }
}
