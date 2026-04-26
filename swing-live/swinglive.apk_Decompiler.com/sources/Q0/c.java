package Q0;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.IInterface;
import android.os.RemoteException;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicInteger;

/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final HashMap f1515o = new HashMap();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f1516a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final v f1517b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f1518c;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f1521g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final Intent f1522h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final A f1523i;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ServiceConnectionC0116b f1527m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public IInterface f1528n;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f1519d = new ArrayList();
    public final HashSet e = new HashSet();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Object f1520f = new Object();

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final x f1525k = new IBinder.DeathRecipient() { // from class: Q0.x
        @Override // android.os.IBinder.DeathRecipient
        public final void binderDied() {
            c cVar = this.f1540a;
            cVar.f1517b.b("reportBinderDeath", new Object[0]);
            if (cVar.f1524j.get() != null) {
                throw new ClassCastException();
            }
            cVar.f1517b.b("%s : Binder has died.", cVar.f1518c);
            Iterator it = cVar.f1519d.iterator();
            while (it.hasNext()) {
                ((w) it.next()).a(new RemoteException(String.valueOf(cVar.f1518c).concat(" : Binder has died.")));
            }
            cVar.f1519d.clear();
            synchronized (cVar.f1520f) {
                cVar.d();
            }
        }
    };

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final AtomicInteger f1526l = new AtomicInteger(0);

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final WeakReference f1524j = new WeakReference(null);

    /* JADX WARN: Type inference failed for: r0v3, types: [Q0.x] */
    public c(Context context, v vVar, String str, Intent intent, A a5) {
        this.f1516a = context;
        this.f1517b = vVar;
        this.f1518c = str;
        this.f1522h = intent;
        this.f1523i = a5;
    }

    public static void b(c cVar, w wVar) {
        IInterface iInterface = cVar.f1528n;
        ArrayList arrayList = cVar.f1519d;
        v vVar = cVar.f1517b;
        if (iInterface != null || cVar.f1521g) {
            if (!cVar.f1521g) {
                wVar.run();
                return;
            } else {
                vVar.b("Waiting to bind to the service.", new Object[0]);
                arrayList.add(wVar);
                return;
            }
        }
        vVar.b("Initiate binding to the service.", new Object[0]);
        arrayList.add(wVar);
        ServiceConnectionC0116b serviceConnectionC0116b = new ServiceConnectionC0116b(cVar);
        cVar.f1527m = serviceConnectionC0116b;
        cVar.f1521g = true;
        if (cVar.f1516a.bindService(cVar.f1522h, serviceConnectionC0116b, 1)) {
            return;
        }
        vVar.b("Failed to bind to the service.", new Object[0]);
        cVar.f1521g = false;
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            ((w) it.next()).a(new d("Failed to bind to the service."));
        }
        arrayList.clear();
    }

    public final Handler a() {
        Handler handler;
        HashMap map = f1515o;
        synchronized (map) {
            try {
                if (!map.containsKey(this.f1518c)) {
                    HandlerThread handlerThread = new HandlerThread(this.f1518c, 10);
                    handlerThread.start();
                    map.put(this.f1518c, new Handler(handlerThread.getLooper()));
                }
                handler = (Handler) map.get(this.f1518c);
            } catch (Throwable th) {
                throw th;
            }
        }
        return handler;
    }

    public final void c(TaskCompletionSource taskCompletionSource) {
        synchronized (this.f1520f) {
            this.e.remove(taskCompletionSource);
        }
        a().post(new z(this, 0));
    }

    public final void d() {
        HashSet hashSet = this.e;
        Iterator it = hashSet.iterator();
        while (it.hasNext()) {
            ((TaskCompletionSource) it.next()).trySetException(new RemoteException(String.valueOf(this.f1518c).concat(" : Binder has died.")));
        }
        hashSet.clear();
    }
}
