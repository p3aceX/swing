package I;

import D2.C0039n;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class A implements T3.e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f535a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f536b;

    public /* synthetic */ A(Object obj, int i4) {
        this.f535a = i4;
        this.f536b = obj;
    }

    @Override // T3.e
    public final Object c(Object obj, InterfaceC0762c interfaceC0762c) {
        Object objD;
        switch (this.f535a) {
            case 0:
                Q q4 = (Q) this.f536b;
                boolean z4 = q4.f603n.v() instanceof c0;
                w3.i iVar = w3.i.f6729a;
                return (z4 || (objD = Q.d(q4, true, interfaceC0762c)) != EnumC0789a.f6999a) ? iVar : objD;
            case 1:
                ((J3.r) this.f536b).f832a = obj;
                throw new U3.a(this);
            default:
                ((C0039n) this.f536b).accept(obj);
                return w3.i.f6729a;
        }
    }
}
