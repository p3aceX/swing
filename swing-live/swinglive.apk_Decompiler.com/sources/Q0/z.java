package Q0;

/* JADX INFO: loaded from: classes.dex */
public final class z extends w {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ int f1544m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ Object f1545n;

    public /* synthetic */ z(Object obj, int i4) {
        this.f1544m = i4;
        this.f1545n = obj;
    }

    @Override // Q0.w
    public final void b() {
        switch (this.f1544m) {
            case 0:
                synchronized (((c) this.f1545n).f1520f) {
                    try {
                        if (((c) this.f1545n).f1526l.get() > 0 && ((c) this.f1545n).f1526l.decrementAndGet() > 0) {
                            ((c) this.f1545n).f1517b.b("Leaving the connection open for other ongoing calls.", new Object[0]);
                            return;
                        }
                        c cVar = (c) this.f1545n;
                        if (cVar.f1528n != null) {
                            cVar.f1517b.b("Unbind from service.", new Object[0]);
                            c cVar2 = (c) this.f1545n;
                            cVar2.f1516a.unbindService(cVar2.f1527m);
                            c cVar3 = (c) this.f1545n;
                            cVar3.f1521g = false;
                            cVar3.f1528n = null;
                            cVar3.f1527m = null;
                        }
                        ((c) this.f1545n).d();
                        return;
                    } finally {
                    }
                }
            default:
                c cVar4 = ((ServiceConnectionC0116b) this.f1545n).f1514a;
                cVar4.f1517b.b("unlinkToDeath", new Object[0]);
                cVar4.f1528n.asBinder().unlinkToDeath(cVar4.f1525k, 0);
                cVar4.f1528n = null;
                cVar4.f1521g = false;
                return;
        }
    }
}
