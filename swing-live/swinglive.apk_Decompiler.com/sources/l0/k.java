package l0;

import D2.C0039n;
import android.app.Activity;
import android.content.Context;
import android.os.IBinder;
import android.view.Window;
import android.view.WindowManager;
import io.flutter.plugin.platform.A;
import j0.InterfaceC0450a;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.locks.ReentrantLock;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class k implements InterfaceC0450a {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static volatile k f5585c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final ReentrantLock f5586d = new ReentrantLock();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final i f5587a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final CopyOnWriteArrayList f5588b = new CopyOnWriteArrayList();

    public k(i iVar) {
        this.f5587a = iVar;
        if (iVar != null) {
            iVar.d(new B.k(this, 26));
        }
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // j0.InterfaceC0450a
    public final void a(Context context, V.d dVar, C0039n c0039n) {
        Object next;
        WindowManager.LayoutParams attributes;
        w3.i iVar = null;
        iBinder = null;
        IBinder iBinder = null;
        Activity activity = context instanceof Activity ? (Activity) context : null;
        p pVar = p.f6784a;
        if (activity != null) {
            ReentrantLock reentrantLock = f5586d;
            reentrantLock.lock();
            try {
                i iVar2 = this.f5587a;
                if (iVar2 == null) {
                    c0039n.accept(new i0.j(pVar));
                    return;
                }
                CopyOnWriteArrayList copyOnWriteArrayList = this.f5588b;
                boolean z4 = false;
                if (copyOnWriteArrayList == null || !copyOnWriteArrayList.isEmpty()) {
                    Iterator it = copyOnWriteArrayList.iterator();
                    while (true) {
                        if (!it.hasNext()) {
                            break;
                        } else if (((j) it.next()).f5582a.equals(activity)) {
                            z4 = true;
                            break;
                        }
                    }
                }
                j jVar = new j(activity, dVar, c0039n);
                copyOnWriteArrayList.add(jVar);
                if (z4) {
                    Iterator it2 = copyOnWriteArrayList.iterator();
                    while (true) {
                        if (!it2.hasNext()) {
                            next = null;
                            break;
                        } else {
                            next = it2.next();
                            if (activity.equals(((j) next).f5582a)) {
                                break;
                            }
                        }
                    }
                    j jVar2 = (j) next;
                    i0.j jVar3 = jVar2 != null ? jVar2.f5584c : null;
                    if (jVar3 != null) {
                        jVar.f5584c = jVar3;
                        jVar.f5583b.accept(jVar3);
                    }
                } else {
                    Window window = activity.getWindow();
                    if (window != null && (attributes = window.getAttributes()) != null) {
                        iBinder = attributes.token;
                    }
                    if (iBinder != null) {
                        iVar2.c(iBinder, activity);
                    } else {
                        activity.getWindow().getDecorView().addOnAttachStateChangeListener(new A(iVar2, activity));
                    }
                }
                reentrantLock.unlock();
                iVar = w3.i.f6729a;
            } finally {
                reentrantLock.unlock();
            }
        }
        if (iVar == null) {
            c0039n.accept(new i0.j(pVar));
        }
    }

    @Override // j0.InterfaceC0450a
    public final void b(C0039n c0039n) {
        synchronized (f5586d) {
            try {
                if (this.f5587a == null) {
                    return;
                }
                ArrayList arrayList = new ArrayList();
                for (j jVar : this.f5588b) {
                    if (jVar.f5583b == c0039n) {
                        arrayList.add(jVar);
                    }
                }
                this.f5588b.removeAll(arrayList);
                Iterator it = arrayList.iterator();
                while (it.hasNext()) {
                    Activity activity = ((j) it.next()).f5582a;
                    CopyOnWriteArrayList copyOnWriteArrayList = this.f5588b;
                    if (copyOnWriteArrayList == null || !copyOnWriteArrayList.isEmpty()) {
                        Iterator it2 = copyOnWriteArrayList.iterator();
                        while (it2.hasNext()) {
                            if (((j) it2.next()).f5582a.equals(activity)) {
                                break;
                            }
                        }
                    }
                    i iVar = this.f5587a;
                    if (iVar != null) {
                        iVar.b(activity);
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
