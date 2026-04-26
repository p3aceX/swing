package k0;

import B.k;
import D2.C0039n;
import J3.s;
import android.app.Activity;
import android.content.Context;
import androidx.window.extensions.layout.WindowLayoutComponent;
import androidx.window.extensions.layout.WindowLayoutInfo;
import j0.InterfaceC0450a;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.concurrent.locks.ReentrantLock;
import w3.i;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class c implements InterfaceC0450a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final WindowLayoutComponent f5491a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final k f5492b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ReentrantLock f5493c = new ReentrantLock();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final LinkedHashMap f5494d = new LinkedHashMap();
    public final LinkedHashMap e = new LinkedHashMap();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final LinkedHashMap f5495f = new LinkedHashMap();

    public c(WindowLayoutComponent windowLayoutComponent, k kVar) {
        this.f5491a = windowLayoutComponent;
        this.f5492b = kVar;
    }

    @Override // j0.InterfaceC0450a
    public final void a(Context context, V.d dVar, C0039n c0039n) {
        i iVar;
        ReentrantLock reentrantLock = this.f5493c;
        reentrantLock.lock();
        LinkedHashMap linkedHashMap = this.f5494d;
        try {
            f fVar = (f) linkedHashMap.get(context);
            LinkedHashMap linkedHashMap2 = this.e;
            if (fVar != null) {
                fVar.b(c0039n);
                linkedHashMap2.put(c0039n, context);
                iVar = i.f6729a;
            } else {
                iVar = null;
            }
            if (iVar == null) {
                f fVar2 = new f(context);
                linkedHashMap.put(context, fVar2);
                linkedHashMap2.put(c0039n, context);
                fVar2.b(c0039n);
                if (!(context instanceof Activity)) {
                    fVar2.accept(new WindowLayoutInfo(p.f6784a));
                    reentrantLock.unlock();
                    return;
                } else {
                    this.f5495f.put(fVar2, this.f5492b.s(this.f5491a, s.a(WindowLayoutInfo.class), (Activity) context, new b(1, fVar2, f.class, "accept", "accept(Landroidx/window/extensions/layout/WindowLayoutInfo;)V", 0)));
                }
            }
            reentrantLock.unlock();
        } catch (Throwable th) {
            reentrantLock.unlock();
            throw th;
        }
    }

    @Override // j0.InterfaceC0450a
    public final void b(C0039n c0039n) {
        ReentrantLock reentrantLock = this.f5493c;
        reentrantLock.lock();
        LinkedHashMap linkedHashMap = this.e;
        try {
            Context context = (Context) linkedHashMap.get(c0039n);
            if (context == null) {
                return;
            }
            LinkedHashMap linkedHashMap2 = this.f5494d;
            f fVar = (f) linkedHashMap2.get(context);
            if (fVar == null) {
                return;
            }
            ReentrantLock reentrantLock2 = fVar.f5501b;
            reentrantLock2.lock();
            LinkedHashSet linkedHashSet = fVar.f5503d;
            try {
                linkedHashSet.remove(c0039n);
                reentrantLock2.unlock();
                linkedHashMap.remove(c0039n);
                if (linkedHashSet.isEmpty()) {
                    linkedHashMap2.remove(context);
                    f0.d dVar = (f0.d) this.f5495f.remove(fVar);
                    if (dVar != null) {
                        dVar.f4271a.invoke(dVar.f4272b, dVar.f4273c);
                    }
                }
            } catch (Throwable th) {
                reentrantLock2.unlock();
                throw th;
            }
        } finally {
            reentrantLock.unlock();
        }
    }
}
