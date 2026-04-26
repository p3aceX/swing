package Q0;

import android.os.IBinder;
import android.os.IInterface;
import android.os.RemoteException;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class B extends w {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ IBinder f1510m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ ServiceConnectionC0116b f1511n;

    public B(ServiceConnectionC0116b serviceConnectionC0116b, IBinder iBinder) {
        this.f1511n = serviceConnectionC0116b;
        this.f1510m = iBinder;
    }

    @Override // Q0.w
    public final void b() {
        c cVar = this.f1511n.f1514a;
        cVar.f1528n = (IInterface) cVar.f1523i.a(this.f1510m);
        cVar.f1517b.b("linkToDeath", new Object[0]);
        try {
            cVar.f1528n.asBinder().linkToDeath(cVar.f1525k, 0);
        } catch (RemoteException e) {
            cVar.f1517b.a(e, "linkToDeath failed", new Object[0]);
        }
        cVar.f1521g = false;
        Iterator it = cVar.f1519d.iterator();
        while (it.hasNext()) {
            ((Runnable) it.next()).run();
        }
        cVar.f1519d.clear();
    }
}
