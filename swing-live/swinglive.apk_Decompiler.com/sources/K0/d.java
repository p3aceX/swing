package k0;

import D2.C0039n;
import android.content.Context;
import androidx.window.extensions.layout.WindowLayoutComponent;
import j0.InterfaceC0450a;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.concurrent.locks.ReentrantLock;
import w3.i;

/* JADX INFO: loaded from: classes.dex */
public final class d implements InterfaceC0450a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final WindowLayoutComponent f5496a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ReentrantLock f5497b = new ReentrantLock();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final LinkedHashMap f5498c = new LinkedHashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final LinkedHashMap f5499d = new LinkedHashMap();

    public d(WindowLayoutComponent windowLayoutComponent) {
        this.f5496a = windowLayoutComponent;
    }

    @Override // j0.InterfaceC0450a
    public final void a(Context context, V.d dVar, C0039n c0039n) {
        i iVar;
        ReentrantLock reentrantLock = this.f5497b;
        reentrantLock.lock();
        LinkedHashMap linkedHashMap = this.f5498c;
        try {
            f fVar = (f) linkedHashMap.get(context);
            LinkedHashMap linkedHashMap2 = this.f5499d;
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
                this.f5496a.addWindowLayoutInfoListener(context, fVar2);
            }
            reentrantLock.unlock();
        } catch (Throwable th) {
            reentrantLock.unlock();
            throw th;
        }
    }

    @Override // j0.InterfaceC0450a
    public final void b(C0039n c0039n) {
        ReentrantLock reentrantLock = this.f5497b;
        reentrantLock.lock();
        LinkedHashMap linkedHashMap = this.f5499d;
        try {
            Context context = (Context) linkedHashMap.get(c0039n);
            if (context == null) {
                return;
            }
            LinkedHashMap linkedHashMap2 = this.f5498c;
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
                    this.f5496a.removeWindowLayoutInfoListener(fVar);
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
