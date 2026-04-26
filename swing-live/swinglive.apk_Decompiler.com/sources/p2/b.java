package p2;

import java.util.Iterator;
import n2.EnumC0559b;
import q2.C0635a;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0635a f6194a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f6195b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6196c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0617a f6197d;
    public C0617a e;

    public final short a() {
        Object next;
        Iterator it = this.f6194a.f6263f.iterator();
        while (true) {
            if (!it.hasNext()) {
                next = null;
                break;
            }
            next = it.next();
            EnumC0559b enumC0559b = ((q2.b) next).f6265a;
            if (enumC0559b == EnumC0559b.f5865b || enumC0559b == EnumC0559b.e) {
                break;
            }
        }
        q2.b bVar = (q2.b) next;
        if (bVar != null) {
            return bVar.f6266b;
        }
        return (short) 0;
    }
}
