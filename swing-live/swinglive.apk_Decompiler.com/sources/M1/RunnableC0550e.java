package m1;

import T2.t;
import T2.v;
import o.AbstractFutureC0576h;

/* JADX INFO: renamed from: m1.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class RunnableC0550e implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5779a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f5780b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f5781c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Object f5782d;

    public /* synthetic */ RunnableC0550e(Object obj, Object obj2, Object obj3, int i4) {
        this.f5779a = i4;
        this.f5780b = obj;
        this.f5781c = obj2;
        this.f5782d = obj3;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f5779a) {
            case 0:
                ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g = (ScheduledExecutorServiceC0552g) this.f5780b;
                final C0553h c0553h = (C0553h) this.f5782d;
                final Runnable runnable = (Runnable) this.f5781c;
                final int i4 = 0;
                scheduledExecutorServiceC0552g.f5786a.execute(new Runnable() { // from class: m1.c
                    @Override // java.lang.Runnable
                    public final void run() throws Exception {
                        switch (i4) {
                            case 0:
                                try {
                                    runnable.run();
                                    return;
                                } catch (Exception e) {
                                    c0553h.b(e);
                                    throw e;
                                }
                            case 1:
                                try {
                                    runnable.run();
                                    return;
                                } catch (Exception e4) {
                                    c0553h.b(e4);
                                    return;
                                }
                            default:
                                Runnable runnable2 = runnable;
                                C0553h c0553h2 = c0553h;
                                try {
                                    runnable2.run();
                                    j jVar = (j) c0553h2.f5788a;
                                    jVar.getClass();
                                    if (AbstractFutureC0576h.f5952f.e(jVar, null, AbstractFutureC0576h.f5953m)) {
                                        AbstractFutureC0576h.c(jVar);
                                        return;
                                    }
                                    return;
                                } catch (Exception e5) {
                                    c0553h2.b(e5);
                                    return;
                                }
                        }
                    }
                });
                break;
            case 1:
                ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g2 = (ScheduledExecutorServiceC0552g) this.f5780b;
                final C0553h c0553h2 = (C0553h) this.f5782d;
                final Runnable runnable2 = (Runnable) this.f5781c;
                final int i5 = 2;
                scheduledExecutorServiceC0552g2.f5786a.execute(new Runnable() { // from class: m1.c
                    @Override // java.lang.Runnable
                    public final void run() throws Exception {
                        switch (i5) {
                            case 0:
                                try {
                                    runnable2.run();
                                    return;
                                } catch (Exception e) {
                                    c0553h2.b(e);
                                    throw e;
                                }
                            case 1:
                                try {
                                    runnable2.run();
                                    return;
                                } catch (Exception e4) {
                                    c0553h2.b(e4);
                                    return;
                                }
                            default:
                                Runnable runnable22 = runnable2;
                                C0553h c0553h22 = c0553h2;
                                try {
                                    runnable22.run();
                                    j jVar = (j) c0553h22.f5788a;
                                    jVar.getClass();
                                    if (AbstractFutureC0576h.f5952f.e(jVar, null, AbstractFutureC0576h.f5953m)) {
                                        AbstractFutureC0576h.c(jVar);
                                        return;
                                    }
                                    return;
                                } catch (Exception e5) {
                                    c0553h22.b(e5);
                                    return;
                                }
                        }
                    }
                });
                break;
            case 2:
                ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g3 = (ScheduledExecutorServiceC0552g) this.f5780b;
                final C0553h c0553h3 = (C0553h) this.f5782d;
                final Runnable runnable3 = (Runnable) this.f5781c;
                final int i6 = 1;
                scheduledExecutorServiceC0552g3.f5786a.execute(new Runnable() { // from class: m1.c
                    @Override // java.lang.Runnable
                    public final void run() throws Exception {
                        switch (i6) {
                            case 0:
                                try {
                                    runnable3.run();
                                    return;
                                } catch (Exception e) {
                                    c0553h3.b(e);
                                    throw e;
                                }
                            case 1:
                                try {
                                    runnable3.run();
                                    return;
                                } catch (Exception e4) {
                                    c0553h3.b(e4);
                                    return;
                                }
                            default:
                                Runnable runnable22 = runnable3;
                                C0553h c0553h22 = c0553h3;
                                try {
                                    runnable22.run();
                                    j jVar = (j) c0553h22.f5788a;
                                    jVar.getClass();
                                    if (AbstractFutureC0576h.f5952f.e(jVar, null, AbstractFutureC0576h.f5953m)) {
                                        AbstractFutureC0576h.c(jVar);
                                        return;
                                    }
                                    return;
                                } catch (Exception e5) {
                                    c0553h22.b(e5);
                                    return;
                                }
                        }
                    }
                });
                break;
            default:
                ((t) this.f5780b).a(new v(null, (String) this.f5781c, (String) this.f5782d));
                break;
        }
    }
}
