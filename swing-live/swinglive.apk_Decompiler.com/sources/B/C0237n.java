package b;

import O.E;
import java.util.ListIterator;
import x3.C0725e;

/* JADX INFO: renamed from: b.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0237n extends J3.j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3248a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ u f3249b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ C0237n(u uVar, int i4) {
        super(0);
        this.f3248a = i4;
        this.f3249b = uVar;
    }

    @Override // I3.a
    public final Object a() {
        Object objPrevious;
        switch (this.f3248a) {
            case 0:
                this.f3249b.a();
                break;
            case 1:
                u uVar = this.f3249b;
                E e = uVar.f3265c;
                if (e == null) {
                    C0725e c0725e = uVar.f3264b;
                    ListIterator listIterator = c0725e.listIterator(c0725e.size());
                    while (true) {
                        if (listIterator.hasPrevious()) {
                            objPrevious = listIterator.previous();
                            if (((E) objPrevious).f1209a) {
                            }
                        } else {
                            objPrevious = null;
                        }
                    }
                    e = (E) objPrevious;
                }
                uVar.f3265c = null;
                if (e != null) {
                    e.a();
                }
                break;
            default:
                this.f3249b.a();
                break;
        }
        return w3.i.f6729a;
    }
}
