package k0;

import D2.C0039n;
import J3.i;
import android.content.Context;
import androidx.window.extensions.core.util.function.Consumer;
import androidx.window.extensions.layout.WindowLayoutInfo;
import i0.j;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.concurrent.locks.ReentrantLock;
import z.InterfaceC0769a;

/* JADX INFO: loaded from: classes.dex */
public final class f implements InterfaceC0769a, Consumer {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5500a;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public j f5502c;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ReentrantLock f5501b = new ReentrantLock();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final LinkedHashSet f5503d = new LinkedHashSet();

    public f(Context context) {
        this.f5500a = context;
    }

    @Override // z.InterfaceC0769a
    /* JADX INFO: renamed from: a, reason: merged with bridge method [inline-methods] */
    public final void accept(WindowLayoutInfo windowLayoutInfo) {
        i.e(windowLayoutInfo, "value");
        ReentrantLock reentrantLock = this.f5501b;
        reentrantLock.lock();
        try {
            this.f5502c = e.b(this.f5500a, windowLayoutInfo);
            Iterator it = this.f5503d.iterator();
            while (it.hasNext()) {
                ((InterfaceC0769a) it.next()).accept(this.f5502c);
            }
        } finally {
            reentrantLock.unlock();
        }
    }

    public final void b(C0039n c0039n) {
        ReentrantLock reentrantLock = this.f5501b;
        reentrantLock.lock();
        try {
            j jVar = this.f5502c;
            if (jVar != null) {
                c0039n.accept(jVar);
            }
            this.f5503d.add(c0039n);
            reentrantLock.unlock();
        } catch (Throwable th) {
            reentrantLock.unlock();
            throw th;
        }
    }
}
